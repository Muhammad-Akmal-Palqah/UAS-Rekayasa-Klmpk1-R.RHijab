import 'dart:convert';
import 'package:flutter/material.dart';
import '../../service/auth_service.dart';
import 'profile_constants.dart';
import 'profile_edit_view.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final photoData = user?.photoData;
    final photoUrl = user?.photoUrl;
    final initials = _getInitials(user?.username ?? 'Pengguna');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Pribadi'),
        backgroundColor: ProfileColors.dominant,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail akun Anda',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lihat informasi nama dan email yang terdaftar. Tekan tombol edit jika Anda ingin mengubahnya.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: photoData != null
                    ? MemoryImage(base64Decode(photoData))
                    : photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child:
                    photoData == null && (photoUrl == null || photoUrl.isEmpty)
                    ? Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ProfileColors.textDark,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'Foto profil Anda',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ProfileColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.username ?? '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ProfileColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No HP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ProfileColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.phone?.isNotEmpty == true ? user!.phone! : '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileEditPage(),
                        ),
                      )
                      .then((_) => setState(() {}));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProfileColors.dominant,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Edit Akun', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
