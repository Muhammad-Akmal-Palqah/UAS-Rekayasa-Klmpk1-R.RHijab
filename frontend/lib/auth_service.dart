enum UserRole { customer, admin }

String getRoleLabel(UserRole role) {
  return role == UserRole.admin ? 'Admin' : 'User';
}

class UserAuth {
  final String email;
  final String username;
  final UserRole role;

  UserAuth({
    required this.email,
    required this.username,
    required this.role,
  });
}

class AuthService {
  static const _adminEmail = 'admin@example.com';
  static const _adminUsername = 'admin';
  static const _adminPassword = 'admin123';

  static Future<UserAuth> signIn({
    required String email,
    required String username,
    required String password,
    required UserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (role == UserRole.admin) {
      if (email.toLowerCase() != _adminEmail ||
          username.toLowerCase() != _adminUsername ||
          password != _adminPassword) {
        throw AuthException(
          'Admin login gagal. Gunakan admin@example.com / admin / admin123.',
        );
      }
    } else {
      if (!email.contains('@') || username.trim().length < 3 || password.length < 6) {
        throw AuthException(
          'Login gagal. Periksa email, username, dan password Anda.',
        );
      }
    }

    return UserAuth(email: email, username: username, role: role);
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
