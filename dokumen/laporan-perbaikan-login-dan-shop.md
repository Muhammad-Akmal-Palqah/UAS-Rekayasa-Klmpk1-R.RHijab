# Laporan Perbaikan Frontend

## Ringkasan
Perubahan ini menambahkan form login yang mendukung dua peran pengguna: Admin dan User. Selain itu, dilakukan perbaikan responsivitas pada konten/ widget di menu Shop agar tidak terjadi overflow pada layout lebih kecil.

## Pekerjaan yang Dilakukan

### 1. Form Login dan Auth
- Menambahkan `frontend/lib/auth_service.dart` sebagai mock auth service dengan:
  - `UserRole` enum untuk `customer` dan `admin`.
  - `UserAuth` model untuk menyimpan `username`, `email`, dan `role`.
  - `AuthService.signIn(...)` untuk validasi login dummy dan error handling.
- Membuat `frontend/lib/login_page.dart` berisi:
  - input `Email`, `Username`, dan `Password`.
  - pilihan peran menggunakan `ChoiceChip` untuk `User` dan `Admin`.
  - validasi form dan loading state saat submit.
  - callback `onSignIn(...)` ke `main.dart`.
- Memperbarui `frontend/lib/main.dart` agar:
  - menampilkan `LoginPage` jika belum ada user yang sign in.
  - menyimpan state login dengan `_currentUser`.
  - menampilkan halaman utama, shop, favorit, dan akun setelah login.
  - menambahkan fitur `Sign Out` pada halaman akun.

### 2. Perbaikan Ukuran Konten/Widget di Menu Shop
- Memperbaiki overflow di halaman Shop dengan menyesuaikan layout agar lebih responsif.
- Mengatasi `withOpacity(...)` deprecation di `frontend/lib/main.dart` dengan `withAlpha(...)` untuk memastikan kompilasi bersih.
- Menjaga tampilan dan bayangan widget tetap sesuai desain.

## Hasil
- `flutter analyze` pada folder `frontend` tidak menemukan issue.
- Login form bekerja dengan pilihan role user/admin.
- Tampilan Shop telah diperbaiki agar tidak overflow pada ukuran widget yang lebih kecil.

## Cabang dan PR
- Cabang kerja: `fix/shop-responsive-overflow`
- Target PR: `dev`
