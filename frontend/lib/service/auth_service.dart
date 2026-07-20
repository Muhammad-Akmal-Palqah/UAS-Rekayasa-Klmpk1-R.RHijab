import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { customer, admin }

String getRoleLabel(UserRole role) {
  return role == UserRole.admin ? 'Admin' : 'Pelanggan';
}

class UserAuth {
  final String email;
  final String username;
  final UserRole role;
  final String? token;
  final String? photoData;
  final String? photoUrl;
  final String? phone;

  UserAuth({
    required this.email,
    required this.username,
    required this.role,
    this.token,
    this.photoData,
    this.photoUrl,
    this.phone,
  });
}

class AuthService {
  static UserAuth? currentUser;

  static Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final email = prefs.getString('auth_email');
    final name = prefs.getString('auth_name');

    if (token != null &&
        token.isNotEmpty &&
        email != null &&
        email.isNotEmpty) {
      ApiService.authToken = token;
      final storedPhotoUrl = prefs.getString('auth_photo_url');
      final normalizedPhotoUrl =
          storedPhotoUrl != null && storedPhotoUrl.isNotEmpty
          ? ApiService.normalizeImageUrl(storedPhotoUrl)
          : null;
      currentUser = UserAuth(
        email: email,
        username: name?.isNotEmpty == true ? name! : email.split('@').first,
        role: UserRole.customer,
        token: token,
        photoData: prefs.getString('auth_photo'),
        photoUrl: normalizedPhotoUrl,
        phone: prefs.getString('auth_phone'),
      );
      return;
    }

    currentUser = null;
    ApiService.authToken = null;
  }

  static Future<void> signOut() async {
    currentUser = null;
    ApiService.authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_email');
    await prefs.remove('auth_name');
    await prefs.remove('auth_photo');
    await prefs.remove('auth_photo_url');
  }

  static Future<UserAuth> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final body = await ApiService.login(email: email, password: password);

    if (body['success'] == false) {
      throw AuthException(body['message']?.toString() ?? 'Login gagal.');
    }

    final userData = body['user'] as Map<String, dynamic>?;
    if (userData == null) {
      throw AuthException('Respon login tidak valid dari server.');
    }

    final token = body['token']?.toString();
    ApiService.authToken = token;

    final displayName = userData['name']?.toString() ?? email;
    final rawPhotoUrl =
        userData['photo']?.toString() ??
        userData['photo_url']?.toString() ??
        userData['image_url']?.toString();
    final photoUrl = rawPhotoUrl != null && rawPhotoUrl.isNotEmpty
        ? ApiService.normalizeImageUrl(rawPhotoUrl)
        : null;
    final user = UserAuth(
      email: email,
      username: displayName,
      role: role,
      token: token,
      photoUrl: photoUrl?.isNotEmpty == true ? photoUrl : null,
      photoData: null,
      phone: userData['phone']?.toString().isNotEmpty == true
          ? userData['phone'].toString()
          : null,
    );

    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    if (token != null && token.isNotEmpty) {
      await prefs.setString('auth_token', token);
    }
    await prefs.setString('auth_email', email);
    await prefs.setString('auth_name', displayName);
    if (user.photoUrl != null) {
      await prefs.setString('auth_photo_url', user.photoUrl!);
    }
    if (userData['phone'] != null) {
      await prefs.setString('auth_phone', userData['phone'].toString());
    } else {
      await prefs.remove('auth_phone');
    }

    return user;
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await ApiService.register(name: name, email: email, password: password);
  }

  static Future<UserAuth> updateProfile({
    required String name,
    required String email,
    String? password,
    String? photoData,
    String? photoUrl,
    String? phone,
  }) async {
    final body = await ApiService.updateProfile(
      name: name,
      email: email,
      password: password,
      photoData: photoData,
      phone: phone,
    );
    final userData = body['user'] as Map<String, dynamic>?;
    if (userData == null) {
      throw AuthException('Respon update profil tidak valid dari server.');
    }

    final photoUrlFromServer = userData['photo']?.toString();
    final phoneFromServer = userData['phone']?.toString();
    final updatedUser = UserAuth(
      email: userData['email']?.toString() ?? email,
      username: userData['name']?.toString() ?? name,
      role: currentUser?.role ?? UserRole.customer,
      token: currentUser?.token,
      photoData: photoData ?? currentUser?.photoData,
      photoUrl: (photoUrlFromServer != null && photoUrlFromServer.isNotEmpty)
          ? photoUrlFromServer
          : (photoUrl ?? currentUser?.photoUrl),
      phone: phoneFromServer?.isNotEmpty == true ? phoneFromServer : null,
    );

    currentUser = updatedUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_email', updatedUser.email);
    await prefs.setString('auth_name', updatedUser.username);
    if (updatedUser.photoData != null) {
      await prefs.setString('auth_photo', updatedUser.photoData!);
    }
    if (updatedUser.photoUrl != null) {
      await prefs.setString('auth_photo_url', updatedUser.photoUrl!);
    }
    if (updatedUser.phone != null && updatedUser.phone!.isNotEmpty) {
      await prefs.setString('auth_phone', updatedUser.phone!);
    } else {
      await prefs.remove('auth_phone');
    }

    return updatedUser;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
