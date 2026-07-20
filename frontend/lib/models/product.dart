import 'dart:convert';
import 'package:flutter/material.dart';

class Product {
  // ✅ ID produk unik dari database unified (tabel products.id_produk - PRIMARY KEY)
  final String id;

  // ✅ Nama produk dari products.nama_produk
  final String title;

  // ✅ Harga dalam format string "Rp150000" dari products.harga (konversi dari double)
  final String price;

  // ✅ Deskripsi produk dari products.deskripsi
  final String description;

  // ✅ Gambar utama dari products.link_foto (URL lengkap atau path yang akan dinormalisasi)
  final String imageUrl;

  // ✅ Daftar semua gambar dari products.link_fotos (JSON array di database unified)
  // Format dapat berupa array, JSON string, atau comma/pipe separated string
  final List<String> imageUrls;

  // ✅ Kategori produk dari products.kategori (baru di unified database, contoh: Hijab, Mukena, dll)
  final String category;

  // ⚠️ Rating integer (legacy field, gunakan averageRating untuk rating modern)
  final int rating;

  // ✅ Rating rata-rata dari comments table (ROUND(AVG(rating), 1)) - dihitung di backend
  final double averageRating;

  // ✅ Jumlah review/komentar dari COUNT(comments) - dihitung di backend
  final int reviewCount;

  // 🔖 Badge untuk menandai produk khusus (contoh: "10%" untuk diskon, atau null)
  final String? badge;

  // ✅ Sumber produk (selalu "database" setelah merge, sebelumnya ada "flutter" vs "main")
  final String source;

  // ❤️ Apakah produk ini di-favorite oleh user (bukan dari database, local app state)
  final bool isFavorite;

  // 🎨 Warna untuk UI chip/badge (generated dari product ID hash)
  final Color color;

  // ✅ Harga dalam format double untuk kalkulasi (dari products.harga)
  final double priceValue;

  // ✅ Persentase promo dari products.promo (baru di unified database, contoh: 10.0)
  final double? promoPercent;

  // ✅ Harga setelah diskon dihitung dari: harga * (1 - promo/100)
  final double? promoPrice;

  // ✅ Apakah produk ini adalah featured product dari products.is_featured (boolean)
  final bool isFeatured;

  // ✅ Tanggal pembuatan produk dari products.created_at (untuk sorting newest)
  final DateTime? createdAt;

  // ✅ Bagian di home page dari products.home_section (contoh: "featured", "new_arrival", dll)
  final String? homeSection;

  // ✅ Daftar ukuran tersedia dari products.available_sizes (JSON array di database unified)
  // Contoh: ["M", "L", "XL"]
  final List<String> availableSizes;

  // ✅ Daftar warna tersedia dari products.available_colors (JSON array di database unified)
  // Contoh: ["Black", "White", "Pink"]
  final List<String> availableColors;

  // ✅ Stock untuk setiap ukuran dari products.available_size_stocks (JSON map di database unified)
  // Contoh: {"M": 10, "L": 5, "XL": 0}
  final Map<String, int> availableSizeStocks;

  // ✅ Stock untuk setiap warna dari products.available_color_stocks (JSON map di database unified)
  // Contoh: {"Black": 8, "White": 5, "Pink": 2}
  final Map<String, int> availableColorStocks;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.priceValue,
    required this.description,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.category,
    required this.rating,
    required this.averageRating,
    required this.reviewCount,
    this.badge,
    this.source = 'database',
    this.isFavorite = false,
    required this.color,
    required this.isFeatured,
    this.promoPercent,
    this.promoPrice,
    this.createdAt,
    this.homeSection,
    this.availableSizes = const [],
    this.availableColors = const [],
    this.availableSizeStocks = const {},
    this.availableColorStocks = const {},
  });

  Product applyVariantPurchase({
    required String size,
    required String color,
    required int quantity,
  }) {
    if (quantity <= 0) {
      return this;
    }

    final updatedSizeStocks = Map<String, int>.from(availableSizeStocks);
    final updatedColorStocks = Map<String, int>.from(availableColorStocks);

    final normalizedSize = size.trim();
    final normalizedColor = color.trim();

    if (normalizedSize.isNotEmpty) {
      final current = updatedSizeStocks[normalizedSize] ?? 0;
      updatedSizeStocks[normalizedSize] = (current - quantity).clamp(0, 999999);
    }

    if (normalizedColor.isNotEmpty) {
      final current = updatedColorStocks[normalizedColor] ?? 0;
      updatedColorStocks[normalizedColor] = (current - quantity).clamp(
        0,
        999999,
      );
    }

    return Product(
      id: id,
      title: title,
      price: price,
      priceValue: priceValue,
      description: description,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      category: category,
      rating: rating,
      averageRating: averageRating,
      reviewCount: reviewCount,
      badge: badge,
      source: source,
      isFavorite: isFavorite,
      color: this.color,
      isFeatured: isFeatured,
      promoPercent: promoPercent,
      promoPrice: promoPrice,
      createdAt: createdAt,
      homeSection: homeSection,
      availableSizes: availableSizes,
      availableColors: availableColors,
      availableSizeStocks: updatedSizeStocks,
      availableColorStocks: updatedColorStocks,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // ✅ Parse ID produk dari database field 'id_produk' (PRIMARY KEY dari products table)
    final id = json['id_produk']?.toString() ?? '';

    // ✅ Parse harga dari database field 'harga' (numeric value di unified database products table)
    final rawPriceValue = json['harga'];
    final priceValue = rawPriceValue is num
        ? rawPriceValue.toDouble()
        : double.tryParse(rawPriceValue?.toString() ?? '') ?? 0.0;

    // 💰 Format harga ke string dengan format Rupiah "Rp150000"
    final price = 'Rp${priceValue.toStringAsFixed(0)}';

    // ✅ Parse daftar gambar produk dari database field 'link_fotos'
    // Format di database bisa: JSON array, JSON string, atau comma/pipe separated
    // Field 'link_fotos' adalah field baru dari unified database products table
    final rawLinks = json['link_fotos'] ?? json['link_foto'];

    // Support multiple format dari backend untuk menerima berbagai format image list:
    // - raw array dalam `link_fotos`
    // - JSON encoded array string
    // - comma atau pipe separated string
    // - fallback single image string dalam `link_foto`
    List<String> images = [];
    if (rawLinks is List) {
      // ✅ Jika backend mengirim array langsung
      images = rawLinks
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (rawLinks is String) {
      final s = rawLinks.trim();
      // ✅ Coba parse jika berbentuk JSON string
      if (s.startsWith('[') && s.endsWith(']')) {
        try {
          final parsed = List<dynamic>.from(jsonDecode(s));
          images = parsed
              .map((e) => e?.toString() ?? '')
              .where((x) => x.isNotEmpty)
              .toList();
        } catch (_) {
          // ignore dan fall back ke splitting
        }
      }
      // ✅ Jika masih kosong, coba split dengan pipe atau comma separator
      if (images.isEmpty && s.isNotEmpty) {
        if (s.contains('|')) {
          images = s
              .split('|')
              .map((e) => e.trim())
              .where((x) => x.isNotEmpty)
              .toList();
        } else if (s.contains(',')) {
          images = s
              .split(',')
              .map((e) => e.trim())
              .where((x) => x.isNotEmpty)
              .toList();
        } else {
          images = [s];
        }
      }
    }

    // ✅ Ambil gambar pertama dari list sebagai primary image
    final imageUrl = images.isNotEmpty ? images.first : '';

    // ✅ Parse promo/diskon dari database field 'promo' (string dengan format "10%" atau "10")
    // Field ini adalah field baru dari unified database products table
    final badge = json['promo']?.toString();

    // Konversi badge string ke persentase double (contoh: "10%" -> 10.0)
    final promoPercent = badge != null && badge.isNotEmpty
        ? double.tryParse(badge.replaceAll('%', '').trim()) ?? 0.0
        : null;

    // Hitung harga setelah diskon: harga * (1 - persentase/100)
    final promoPrice = promoPercent != null
        ? priceValue * (1 - promoPercent / 100)
        : null;

    // 🏗️ Construct Product object dengan field dari unified database
    return Product(
      id: id,
      // ✅ Nama produk dari database field 'nama_produk'
      title: json['nama_produk']?.toString() ?? 'Produk R.R Hijab',
      price: price,
      priceValue: priceValue,
      // ✅ Deskripsi dari database field 'deskripsi'
      description: json['deskripsi']?.toString() ?? 'Deskripsi tidak tersedia.',
      // ✅ Kategori dari database field 'kategori' (baru dari unified database)
      category: json['kategori']?.toString() ?? 'Umum',
      imageUrl: imageUrl,
      imageUrls: images,
      // ✅ Rating dari database field 'rating' (legacy, gunakan averageRating)
      rating: json['rating'] is num
          ? (json['rating'] as num).toInt()
          : int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      // ✅ Rating rata-rata dari backend calculation (ROUND(AVG(rating), 1)) dari comments table
      averageRating: json['avg_rating'] is num
          ? (json['avg_rating'] as num).toDouble()
          : double.tryParse(json['avg_rating']?.toString() ?? '') ??
                (json['rating'] is num
                    ? (json['rating'] as num).toDouble()
                    : double.tryParse(json['rating']?.toString() ?? '') ?? 0.0),
      // ✅ Jumlah review/comments dari backend calculation COUNT(*) dari comments table
      reviewCount: json['review_count'] is num
          ? (json['review_count'] as num).toInt()
          : int.tryParse(json['review_count']?.toString() ?? '') ?? 0,
      badge: badge?.isNotEmpty == true ? badge : null,
      // ✅ Sumber data (selalu "flutter" atau "database" setelah merge ke unified database)
      source: json['source']?.toString() ?? 'database',
      isFavorite: false,
      color: _colorFromId(id),
      // ✅ Apakah produk featured dari database field 'is_featured' (boolean - baru di unified database)
      isFeatured: (json['is_featured'] is bool)
          ? json['is_featured'] as bool
          : (json['is_featured'] != null &&
                json['is_featured'].toString() != '0'),
      promoPercent: promoPercent,
      promoPrice: promoPrice,
      // ✅ Tanggal created dari database field 'created_at'
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      // ✅ Home section dari database field 'home_section' (baru di unified database - untuk UI home page)
      homeSection: json['home_section']?.toString(),
      // ✅ Available sizes dari database field 'available_sizes' (JSON array - baru di unified database)
      availableSizes: _parseOptionList(json['available_sizes']),
      // ✅ Available colors dari database field 'available_colors' (JSON array - baru di unified database)
      availableColors: _parseOptionList(json['available_colors']),
      // ✅ Size stocks dari database field 'available_size_stocks' (JSON map - baru di unified database)
      availableSizeStocks: _parseStockMap(json['available_size_stocks']),
      // ✅ Color stocks dari database field 'available_color_stocks' (JSON map - baru di unified database)
      availableColorStocks: _parseStockMap(json['available_color_stocks']),
    );
  }

  // 🔧 Helper method: Parse option list (sizes/colors) dari berbagai format di database unified
  // Database menyimpan sebagai JSON array, tapi bisa dikirim dalam berbagai format
  // Input bisa: List, CSV string, atau space-separated string
  // Output: List<String> deduplicated (set → toList)
  static List<String> _parseOptionList(dynamic rawValue) {
    // ✅ Jika null, return empty list (tidak ada size/color available)
    if (rawValue == null) {
      return [];
    }

    // ✅ Jika sudah List format dari JSON array di database
    if (rawValue is List) {
      return rawValue
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toSet() // Deduplicate items (e.g., ["M", "L", "M"] -> ["M", "L"])
          .toList();
    }

    // ✅ Jika String format dari database (CSV atau comma-separated)
    final value = rawValue.toString();
    return value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toSet() // Deduplicate
        .toList();
  }

  // 🔧 Helper method: Parse stock map (available_size_stocks / available_color_stocks) dari database
  // Database menyimpan sebagai JSON object, tapi bisa dikirim dalam berbagai format
  // Input bisa: Map (JSON object), atau string format "size1:qty1,size2:qty2"
  // Output: Map<String, int> dengan quantity per size/color
  static Map<String, int> _parseStockMap(dynamic rawValue) {
    // ✅ Jika null, return empty map (tidak ada stock info)
    if (rawValue == null) {
      return {};
    }

    // ✅ Jika sudah Map format dari JSON object di database (contoh: {"M": 10, "L": 5})
    if (rawValue is Map) {
      return rawValue.map((key, value) {
        // ✅ Parse value ke integer (bisa String atau Number dari database)
        final qty = value is num
            ? value.toInt()
            : int.tryParse(value.toString()) ?? 0;
        // Negative quantities jadi 0 (safety check)
        return MapEntry(key.toString().trim(), qty < 0 ? 0 : qty);
      });
    }

    // ✅ Jika String format dari database (pair-value format: "M:10,L:5,XL:0")
    final value = rawValue.toString();
    final parts = value.split(',');
    final Map<String, int> result = {};

    for (final part in parts) {
      // Split each pair by colon (e.g., "M:10")
      final pair = part.split(':');
      if (pair.length != 2) {
        // ✅ Skip invalid format
        continue;
      }
      final key = pair[0].trim();
      final qty = int.tryParse(pair[1].trim()) ?? 0;
      if (key.isNotEmpty) {
        result[key] = qty < 0 ? 0 : qty;
      }
    }
    return result;
  }

  // 🎨 Helper method: Generate warna unik untuk setiap produk berdasarkan ID
  // Warna digunakan untuk UI chip/badge di product card (bukan dari database)
  static Color _colorFromId(String id) {
    // ✅ Hash ID menjadi integer
    final hash = id.hashCode;
    // ✅ Extract RGB channels dari hash bits (30-bit color space)
    final red = 180 + (hash & 0x1F);
    final green = 180 + ((hash >> 5) & 0x1F);
    final blue = 180 + ((hash >> 10) & 0x1F);
    // ✅ Construct warna dengan clamping RGB values ke 0-255 range
    return Color.fromARGB(
      255,
      red.clamp(0, 255),
      green.clamp(0, 255),
      blue.clamp(0, 255),
    );
  }
}

List<Product> productCatalog = [];
