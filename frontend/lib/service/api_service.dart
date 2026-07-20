import 'dart:convert';
import 'io_stub.dart' if (dart.library.io) 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/comment.dart';
import '../models/order.dart';
import '../models/product.dart';

// ⚠️ Exception class untuk handle API errors dari backend Laravel
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  // 🔐 Global token storage untuk authentication dengan backend Laravel (Sanctum)
  // Disimpan di memory dan di SharedPreferences untuk persist across app sessions
  static String? authToken;

  // 🌐 Environment variable untuk base URL yang bisa di-override saat compile
  static const _envBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: '',
  );

  // 🔑 Helper untuk generate HTTP headers lengkap dengan token authentication
  // Semua request ke API backend harus include headers ini
  // - Content-Type: application/json (backend mengharapkan JSON)
  // - Accept: application/json (backend mengirim JSON)
  // - ngrok-skip-browser-warning: true (jika tunnel ngrok, skip warning page)
  // - Authorization: Bearer {token} (jika withAuth=true dan ada token)
  static Map<String, String> _headers({bool withAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // ✅ Header ini wajib jika backend diakses via ngrok tunnel (agar tidak dapat halaman warning)
      'ngrok-skip-browser-warning': 'true',
    };

    // ✅ Tambahkan Bearer token ke header jika withAuth=true dan ada token di memory
    // Token ini digunakan untuk authenticated endpoints (fetch orders, create order, initiate payment, dll)
    if (withAuth && authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  // 📷 Helper untuk normalize image URLs dari backend
  // Backend mengirim full URLs atau relative paths, method ini pastikan selalu full URL
  static String? normalizeImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }
    // ✅ Jika sudah full URL (http/https), return as-is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    // ✅ Jika relative path, prepend baseUrl
    final prefix = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return imageUrl.startsWith('/') ? '$prefix$imageUrl' : '$prefix/$imageUrl';
  }

  // 🌐 BASE URL untuk backend Laravel unified database
  // Perlu sesuai dengan lokasi backend (IP dan port 8000)
  // ✅ Android Physical Device: http://172.20.10.5:8000 (LAN IP backend server)
  // ✅ Android Emulator: http://127.0.0.1:8000 (loopback ke localhost PC)
  // ✅ Web/iOS: http://127.0.0.1:8000 (loopback)
  static String get baseUrl {
    // 🔄 Priority 1: Check environment variable (untuk override saat compile)
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    // 🔄 Priority 2: Web platform (Flutter web development)
    if (kIsWeb) {
      return 'http://127.0.0.1:8000'; 
    }
    // 🔄 Priority 3: Android (physical device pada LAN yang sama dengan backend server)
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://172.19.144.1:8000' // ✅ Ubah IP jika server pindah ke lokasi berbeda
        : 'http://127.0.0.1:8000';
  }
  
static String get chatEndpoint => '$baseUrl/api/chat';
  
  // 🔐 Ensure token sudah loaded ke memory dari SharedPreferences
  // Jika belum di-load, ambil dari local storage
  static Future<void> _ensureAuthTokenLoaded() async {
    if (authToken == null || authToken!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      // ✅ Ambil token dari SharedPreferences yang disimpan saat login
      authToken = prefs.getString('auth_token');
    }
  }

  // 1️⃣ FETCH PRODUCTS - Get semua produk dari database unified (products table)
  // 🔌 Endpoint: GET /api/products
  // 📊 Data Source: Backend query dari `products` table di database unified (rrhijab_db)
  // Query parameters: min_price, max_price, color, size, kategori, sort
  // Response: { status: "success", data: [Product objects dengan semua field dari products table] }
  static Future<List<Product>> fetchProducts({
    double? minPrice,
    double? maxPrice,
    String? color,
    String? size,
    String? category,
    String? sortBy,
  }) async {
    final queryParameters = <String, String>{};

    // ✅ Filter by min_price dari products.harga >= min_price
    if (minPrice != null) {
      queryParameters['min_price'] = minPrice.toString();
    }
    // ✅ Filter by max_price dari products.harga <= max_price
    if (maxPrice != null) {
      queryParameters['max_price'] = maxPrice.toString();
    }
    // ✅ Filter by color dari products.available_colors (JSON array field di unified database)
    if (color != null && color.isNotEmpty) {
      queryParameters['color'] = color;
    }
    // ✅ Filter by size dari products.available_sizes (JSON array field di unified database)
    if (size != null && size.isNotEmpty) {
      queryParameters['size'] = size;
    }
    // ✅ Filter by kategori dari products.kategori (field baru di unified database)
    if (category != null && category.isNotEmpty) {
      queryParameters['kategori'] = category;
    }
    // ✅ Sort by: newest (created_at DESC), price_low_to_high (harga ASC), popular (is_featured DESC), dll
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParameters['sort'] = sortBy;
    }

    // 📍 Build full URL ke backend endpoint: http://192.168.100.99:8000/api/products?...
    final uri = Uri.parse('$baseUrl/api/products').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    // 🚀 Send GET request dengan 15 detik timeout
    final response = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 15));

    // ⚠️ Handle error: jika status code bukan 200 (OK)
    if (response.statusCode != 200) {
      throw ApiException(
        'Gagal mengambil daftar produk. Status: ${response.statusCode}',
      );
    }

    // 📦 Parse JSON response body
    final body = json.decode(response.body) as Map<String, dynamic>;
    final data = body['data'];

    // ⚠️ Validate response format harus array
    if (data is! List) {
      throw ApiException('Respon produk tidak valid dari server.');
    }

    final products = <Product>[];
    // ✅ Loop setiap product item dari response dan convert ke Product object
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final map = Map<String, dynamic>.from(item);
        final prefix = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;

        // ✅ Normalize image URLs - backend mengirim full URLs atau relative paths
        final rawLinkFoto = map['link_foto'];
        final rawLinkFotos = map['link_fotos'];

        // ✅ Process link_fotos array (multiple images field dari products.link_fotos)
        if (rawLinkFotos != null) {
          if (rawLinkFotos is List) {
            // ✅ Jika array langsung, normalize setiap URL
            map['link_fotos'] = rawLinkFotos.map((e) {
              final s = e?.toString() ?? '';
              if (s.isEmpty) return s;
              if (s.startsWith('http')) return s;
              return s.startsWith('/') ? '$prefix$s' : '$prefix/$s';
            }).toList();
          } else if (rawLinkFotos is String && rawLinkFotos.isNotEmpty) {
            // ✅ Jika string, keep untuk Product.fromJson parse
            map['link_fotos'] = rawLinkFotos;
          }
          // Keep fallback primary image dari array
          if ((map['link_foto'] == null ||
                  map['link_foto'].toString().isEmpty) &&
              map['link_fotos'] is List &&
              (map['link_fotos'] as List).isNotEmpty) {
            map['link_foto'] = (map['link_fotos'] as List).first.toString();
          }
        } else if (rawLinkFoto is String &&
            rawLinkFoto.isNotEmpty &&
            !rawLinkFoto.startsWith('http')) {
          // ✅ Normalize single link_foto jika tidak ada link_fotos
          map['link_foto'] = rawLinkFoto.startsWith('/')
              ? '$prefix$rawLinkFoto'
              : '$prefix/$rawLinkFoto';
        } else if (rawLinkFoto is List) {
          // ✅ Handle legacy format: link_foto sebagai array
          map['link_foto'] = rawLinkFoto.map((e) {
            final s = e?.toString() ?? '';
            if (s.isEmpty) return s;
            if (s.startsWith('http')) return s;
            return s.startsWith('/') ? '$prefix$s' : '$prefix/$s';
          }).toList();
        }

        // ✅ Convert map ke Product object (Product.fromJson handle parsing field dari database)
        products.add(Product.fromJson(map));
      }
    }

    // ✅ Return list of Product objects yang sudah parse dari unified database
    return products;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/login');
    final response = await http
        .post(
          uri,
          headers: _headers(),
          body: json.encode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(
        body['message'] ?? 'Login gagal. Periksa kredensial Anda.',
      );
    }

    final token = body['token']?.toString();
    final loginEmail = body['user']?['email']?.toString() ?? email;
    final loginName = body['user']?['name']?.toString() ?? '';

    if (token != null && token.isNotEmpty) {
      authToken = token; // Masuk ke variabel global memori
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_email', loginEmail);
      await prefs.setString('auth_name', loginName);
    }

    return body;
  }

  // 3. FETCH USER ORDERS (Sudah disatukan & dijamin mengembalikan List<Order>)
  static Future<List<Order>> fetchUserOrders() async {
    await _ensureAuthTokenLoaded();
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('auth_email');

    if (authToken == null || authToken!.isEmpty) {
      throw ApiException(
        'Token otentikasi tidak ditemukan. Silakan login ulang.',
      );
    }

    final uri = Uri.parse('$baseUrl/api/orders').replace(
      queryParameters: email != null && email.isNotEmpty
          ? {'email': email}
          : null,
    );

    final response = await http
        .get(
          uri,
          headers: _headers(withAuth: true), // Mengirimkan Bearer Token aktif
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ApiException(
        'Gagal mengambil pesanan user. Status: ${response.statusCode}',
      );
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final data = body['data'];

    if (data is! List) {
      throw ApiException('Respon pesanan tidak valid dari server.');
    }

    final orders = <Order>[];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        orders.add(Order.fromJson(item));
      }
    }
    return orders;
  }

  static Future<void> deleteOrder(int orderId) async {
    await _ensureAuthTokenLoaded();

    if (authToken == null || authToken!.isEmpty) {
      throw ApiException(
        'Token otentikasi tidak ditemukan. Silakan login ulang.',
      );
    }

    final uri = Uri.parse('$baseUrl/api/orders/$orderId');
    final response = await http
        .delete(uri, headers: _headers(withAuth: true))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final body = json.decode(response.body) as Map<String, dynamic>? ?? {};
    throw ApiException(
      body['message'] ??
          'Gagal menghapus pesanan. Status: ${response.statusCode}',
    );
  }

  static Map<String, dynamic> buildOrderRequestBody({
    required String namaPelanggan,
    required String email,
    required String noWhatsapp,
    required String alamatPengiriman,
    required String ukuran,
    required String metodePengiriman,
    required String catatan,
    String? warna,
    String? metodePembayaran,
    required int jumlahBeli,
    int? totalHarga,
  }) {
    final requestBody = <String, dynamic>{
      'nama_pelanggan': namaPelanggan,
      'email': email,
      'no_whatsapp': noWhatsapp,
      'alamat_pengiriman': alamatPengiriman,
      'ukuran': ukuran,
      'warna': warna,
      'jumlah_beli': jumlahBeli,
      'total_harga': totalHarga,
      'metode_pengiriman': metodePengiriman,
      'catatan': catatan,
    };

    if (metodePembayaran != null) {
      requestBody['metode_pembayaran'] = metodePembayaran;
    }

    if (warna != null) {
      requestBody['warna'] = warna;
    }

    return requestBody;
  }

  // 4. SUBMIT ORDER (Sudah diperbaiki membawa Token Auth agar tercatat di user login)
  static Future<int> submitOrder({
    required String productId,
    required String namaPelanggan,
    required String email,
    required String noWhatsapp,
    required String alamatPengiriman,
    required String ukuran,
    required String metodePengiriman,
    required String catatan,
    String? warna,
    String? metodePembayaran,
    String? buktiFilePath,
    Uint8List? buktiFileBytes,
    String? buktiFileName,
    required int jumlahBeli,
    int? totalHarga,
  }) async {
    final uri = Uri.parse('$baseUrl/api/products/$productId/orders');

    await _ensureAuthTokenLoaded();

    if (authToken == null || authToken!.isEmpty) {
      throw ApiException(
        'Token otentikasi tidak ditemukan. Silakan login ulang sebelum mengirim pesanan.',
      );
    }

    final hasFileUpload =
        (buktiFilePath != null && buktiFilePath.isNotEmpty) ||
        (buktiFileBytes != null && buktiFileName != null);

    if (hasFileUpload) {
      final request = http.MultipartRequest('POST', uri);
      final headers = _headers(withAuth: true);
      headers.remove(
        'Content-Type',
      ); // MultipartRequest akan mengatur sendiri Content-Type
      request.headers.addAll(headers);
      request.fields['nama_pelanggan'] = namaPelanggan;
      request.fields['email'] = email;
      request.fields['no_whatsapp'] = noWhatsapp;
      request.fields['alamat_pengiriman'] = alamatPengiriman;
      request.fields['ukuran'] = ukuran;
      request.fields['jumlah_beli'] = jumlahBeli.toString();
      if (totalHarga != null) {
        request.fields['total_harga'] = totalHarga.toString();
      }
      request.fields['metode_pengiriman'] = metodePengiriman;
      request.fields['catatan'] = catatan;
      if (warna != null) request.fields['warna'] = warna;
      if (metodePembayaran != null) {
        request.fields['metode_pembayaran'] = metodePembayaran;
      }

      if (buktiFileBytes != null && buktiFileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'bukti_pembayaran',
            buktiFileBytes,
            filename: buktiFileName,
          ),
        );
      } else if (buktiFilePath != null && buktiFilePath.isNotEmpty) {
        final file = io.File(buktiFilePath);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'bukti_pembayaran',
              buktiFilePath,
            ),
          );
        }
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 201) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        throw ApiException(body['message'] ?? 'Gagal mengirim pesanan.');
      }
      final body = json.decode(response.body) as Map<String, dynamic>;
      debugPrint('submitOrder multipart response: $body');
      final data = body['data'] as Map<String, dynamic>?;
      // Backend mengembalikan 'order_id', bukan 'id'
      var orderId = data?['order_id'] ?? data?['id'];
      debugPrint('Extracted order ID: $orderId (type: ${orderId.runtimeType})');
      if (orderId is int) {
        return orderId;
      } else if (orderId is String) {
        return int.tryParse(orderId) ?? 0;
      }
      return 0;
    }

    // Data pesanan yang dikirim ke backend untuk disimpan ke database orders.
    final requestBody = buildOrderRequestBody(
      namaPelanggan: namaPelanggan,
      email: email,
      noWhatsapp: noWhatsapp,
      alamatPengiriman: alamatPengiriman,
      ukuran: ukuran,
      metodePengiriman: metodePengiriman,
      catatan: catatan,
      warna: warna,
      metodePembayaran: metodePembayaran,
      jumlahBeli: jumlahBeli,
      totalHarga: totalHarga,
    );

    // Kirim data pesanan ke endpoint backend agar tersimpan di database.
    final response = await http
        .post(
          uri,
          headers: _headers(
            withAuth: true,
          ), // Bawa token autentikasi untuk backend.
          body: json.encode(
            requestBody,
          ), // Data order dikirim dalam format JSON.
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      throw ApiException(body['message'] ?? 'Gagal mengirim pesanan.');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    debugPrint('submitOrder json response: $body');
    final data = body['data'] as Map<String, dynamic>?;
    // Backend mengembalikan 'order_id', bukan 'id'
    var orderId = data?['order_id'] ?? data?['id'];
    debugPrint('Extracted order ID: $orderId (type: ${orderId.runtimeType})');
    if (orderId is int) {
      return orderId;
    } else if (orderId is String) {
      return int.tryParse(orderId) ?? 0;
    }
    return 0;
  }

  static Future<List<int>> submitBulkOrder({
    required String namaPelanggan,
    required String email,
    required String noWhatsapp,
    required String alamatPengiriman,
    required String metodePengiriman,
    required String catatan,
    required String metodePembayaran,
    required List<Map<String, dynamic>> items,
  }) async {
    final uri = Uri.parse('$baseUrl/api/orders/bulk');

    await _ensureAuthTokenLoaded();

    if (authToken == null || authToken!.isEmpty) {
      throw ApiException(
        'Token otentikasi tidak ditemukan. Silakan login ulang sebelum mengirim pesanan.',
      );
    }

    final requestBody = {
      'nama_pelanggan': namaPelanggan,
      'email': email,
      'no_whatsapp': noWhatsapp,
      'alamat_pengiriman': alamatPengiriman,
      'metode_pengiriman': metodePengiriman,
      'catatan': catatan,
      'metode_pembayaran': metodePembayaran,
      'items': items,
    };

    debugPrint('submitBulkOrder request body: $requestBody');

    final response = await http
        .post(
          uri,
          headers: _headers(withAuth: true),
          body: json.encode(requestBody),
        )
        .timeout(const Duration(seconds: 15));

    debugPrint(
      'submitBulkOrder response status=${response.statusCode}, body=${response.body}',
    );

    if (response.statusCode != 201) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      throw ApiException(body['message'] ?? 'Gagal mengirim pesanan.');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    debugPrint('submitBulkOrder json response: $body');
    final data = body['data'] as Map<String, dynamic>?;
    final orderIdsRaw = data?['order_ids'];
    if (orderIdsRaw is List) {
      return orderIdsRaw
          .map<int?>(
            (item) =>
                item is int ? item : int.tryParse(item?.toString() ?? '0'),
          )
          .whereType<int>()
          .toList();
    }
    return [];
  }

  // INITIATE PAYMENT
  static Future<Map<String, dynamic>> initiatePayment({
    required int orderId,
    required String paymentType,
  }) async {
    await _ensureAuthTokenLoaded();

    if (authToken == null || authToken!.isEmpty) {
      throw ApiException(
        'Token otentikasi tidak ditemukan. Silakan login ulang sebelum memulai pembayaran.',
      );
    }

    final uri = Uri.parse('$baseUrl/api/payments/initiate');
    final response = await http
        .post(
          uri,
          headers: _headers(withAuth: true),
          body: json.encode({
            'order_id': orderId,
            'payment_type': paymentType.toLowerCase(),
          }),
        )
        .timeout(const Duration(seconds: 20));

    final body = json.decode(response.body) as Map<String, dynamic>? ?? {};

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(body['message'] ?? 'Gagal memulai pembayaran.');
    }

    final rawData = body['data'];
    final tokenCandidates = <dynamic>[];

    if (rawData is Map<String, dynamic>) {
      tokenCandidates.add(rawData['snap_token']);
      tokenCandidates.add(rawData['token']);
    } else if (rawData is String) {
      tokenCandidates.add(rawData);
    }

    tokenCandidates.add(body['snap_token']);
    tokenCandidates.add(body['token']);

    final snapToken = tokenCandidates
        .firstWhere(
          (value) => value != null && value.toString().isNotEmpty,
          orElse: () => null,
        )
        ?.toString();

    if (snapToken == null || snapToken.isEmpty) {
      throw ApiException('Snap token tidak ditemukan dari server.');
    }

    return {'snap_token': snapToken};
  }

  // CHECK PAYMENT STATUS
  static Future<Map<String, dynamic>> checkPaymentStatus({
    required String orderId,
  }) async {
    await _ensureAuthTokenLoaded();

    if (authToken == null || authToken!.isEmpty) {
      throw ApiException(
        'Token otentikasi tidak ditemukan. Silakan login ulang.',
      );
    }

    final uri = Uri.parse('$baseUrl/api/payments/$orderId/status');

    final response = await http
        .get(uri, headers: _headers(withAuth: true))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['message'] ?? 'Gagal mengecek status pembayaran.',
      );
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    return body;
  }

  // 5. REGISTER & COMMENTS
  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/register');
    final response = await http
        .post(
          uri,
          headers: _headers(),
          body: json.encode({
            'name': name,
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 201 && response.statusCode != 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      throw ApiException(body['message'] ?? 'Registrasi gagal.');
    }
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/forgot-password');
    final response = await http
        .post(
          uri,
          headers: _headers(),
          body: json.encode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw ApiException(decoded['message'] ?? 'Gagal mengubah password.');
    }

    return decoded;
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? password,
    String? photoData,
    String? phone,
  }) async {
    await _ensureAuthTokenLoaded();

    if (authToken == null || authToken!.isEmpty) {
      throw ApiException(
        'Token otentikasi tidak ditemukan. Silakan login ulang.',
      );
    }

    final uri = Uri.parse('$baseUrl/api/user');
    final request = http.MultipartRequest('PATCH', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'Authorization': 'Bearer $authToken',
    });
    request.fields['name'] = name;
    request.fields['email'] = email;
    if (password != null && password.isNotEmpty) {
      request.fields['password'] = password;
    }
    if (phone != null) {
      request.fields['phone'] = phone;
    }
    if (photoData != null && photoData.isNotEmpty) {
      final imageBytes = base64Decode(photoData);
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          imageBytes,
          filename: 'profile_photo.jpg',
        ),
      );
    }

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );
    final responseBody = await streamedResponse.stream.bytesToString();

    final decoded = json.decode(responseBody) as Map<String, dynamic>;
    if (streamedResponse.statusCode != 200) {
      throw ApiException(decoded['message'] ?? 'Gagal memperbarui profil.');
    }
    return decoded;
  }

  static List<Comment> parseCommentsResponse(dynamic decoded) {
    final rawItems = <dynamic>[];

    if (decoded is List) {
      rawItems.addAll(decoded);
    } else if (decoded is Map) {
      final map = Map<String, dynamic>.from(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
      final payload = map['data'];
      if (payload is List) {
        rawItems.addAll(payload);
      } else if (payload is Map) {
        rawItems.add(payload);
      }
    }

    final comments = <Comment>[];
    for (final item in rawItems) {
      // Kita buat map yang aman untuk dibaca
      final Map<String, dynamic> data = (item is Map<String, dynamic>)
          ? Map<String, dynamic>.from(item)
          : Map<String, dynamic>.from((item as Map).cast<String, dynamic>());

      final profileImageCandidates = [
        data['profile_image_url']?.toString(),
        data['profile_photo_url']?.toString(),
        data['user_photo_url']?.toString(),
        data['photo_url']?.toString(),
        data['avatar_url']?.toString(),
        data['avatar']?.toString(),
        data['user_photo']?.toString(),
        data['profile_photo']?.toString(),
      ];

      String? normalizedProfileImageUrl;
      for (final candidate in profileImageCandidates) {
        if (candidate != null && candidate.isNotEmpty) {
          normalizedProfileImageUrl = normalizeImageUrl(candidate);
          break;
        }
      }

      if (normalizedProfileImageUrl != null) {
        data['profile_image_url'] = normalizedProfileImageUrl;
      } else if (data['user_photo'] != null &&
          data['user_photo'].toString().isNotEmpty) {
        data['profile_image_url'] = normalizeImageUrl(
          data['user_photo'].toString(),
        );
      }

      final userMap = data['user'];
      if (userMap is Map) {
        final userData = Map<String, dynamic>.from(
          userMap.cast<String, dynamic>(),
        );
        final userPhotoUrl =
            [
              userData['profile_image_url']?.toString(),
              userData['profile_photo_url']?.toString(),
              userData['photo_url']?.toString(),
              userData['avatar_url']?.toString(),
              userData['avatar']?.toString(),
              userData['photo']?.toString(),
            ].firstWhere(
              (value) => value != null && value.toString().isNotEmpty,
              orElse: () => null,
            );
        if (userPhotoUrl != null) {
          data['user'] = {
            ...userData,
            'profile_image_url': normalizeImageUrl(userPhotoUrl.toString()),
          };
        }
      }

      comments.add(Comment.fromJson(data));
    }
    return comments;
  }

  static Future<List<Comment>> fetchComments(String productId) async {
    await _ensureAuthTokenLoaded();

    final uri = Uri.parse('$baseUrl/api/products/$productId/comments');
    final response = await http
        .get(uri, headers: _headers(withAuth: true))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw ApiException('Gagal memuat komentar.');
    }

    final decoded = json.decode(response.body);
    if (decoded is! List && decoded is! Map) {
      throw ApiException(
        'Respon server tidak valid: format komentar tidak dikenal.',
      );
    }

    return parseCommentsResponse(decoded);
  }

  static Future<bool> checkCommentStatus(String productId) async {
    await _ensureAuthTokenLoaded();

    final uri = Uri.parse('$baseUrl/api/products/$productId/comments/status');
    final response = await http
        .get(uri, headers: _headers(withAuth: true))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 401) {
      return false;
    }

    if (response.statusCode != 200) {
      throw ApiException('Gagal memeriksa status ulasan.');
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Respon server tidak valid.');
    }

    return decoded['has_commented'] == true;
  }

  static Future<Comment> postComment({
    required String productId,
    required String komentar,
    required int rating,
    String? imagePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final uri = Uri.parse('$baseUrl/api/products/$productId/comments');

    await _ensureAuthTokenLoaded();

    if (authToken == null || authToken!.isEmpty) {
      throw ApiException(
        'Token otentikasi tidak ditemukan. Silakan login ulang sebelum mengirim komentar.',
      );
    }

    // Buat request multipart untuk mengirim komentar beserta file jika ada.
    final request = http.MultipartRequest('POST', uri);
    final headers = _headers(withAuth: true);
    headers.remove('Content-Type');
    headers['Accept'] = 'application/json';
    request.headers.addAll(headers);
    // Data komentar yang dikirim ke backend untuk disimpan ke database comments.
    request.fields['komentar'] = komentar; // Isi komentar dari pengguna.
    request.fields['rating'] = rating
        .toString(); // Nilai rating yang dipilih pengguna.

    if (imageBytes != null &&
        imageFileName != null &&
        imageFileName.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFileName,
        ),
      );
    } else if (imagePath != null && imagePath.isNotEmpty && !kIsWeb) {
      final file = io.File(imagePath);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }
    }

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Respon server tidak valid.');
    }
    if (response.statusCode != 201) {
      throw ApiException(decoded['message'] ?? 'Gagal mengirim komentar.');
    }
    final rawData = decoded['data'];
    if (rawData == null || rawData is! Map) {
      throw ApiException('Respon data komentar tidak ditemukan.');
    }
    final data = Map<String, dynamic>.from(rawData.cast<String, dynamic>());
    data['image_url'] = normalizeImageUrl(data['image_url']?.toString());
    return Comment.fromJson(data);
  }
}
