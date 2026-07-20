# RR Hijab Integration

## Profil Project

RR Hijab Integration adalah project monorepo untuk aplikasi toko online hijab yang terdiri dari:

- Frontend mobile berbasis Flutter untuk pengalaman belanja pelanggan
- Backend API berbasis Laravel untuk autentikasi, katalog produk, pesanan, pembayaran, dan manajemen admin
- Infrastruktur pendukung seperti Docker, MySQL, Redis, dan phpMyAdmin

Project ini dirancang untuk mendukung alur belanja digital dari awal sampai akhir, mulai dari melihat produk, menambahkan ke keranjang, melakukan checkout, pembayaran, hingga pemantauan order oleh admin.

---

## Gambaran Umum Aplikasi

Aplikasi ini menggabungkan dua sisi utama:

1. Sisi pelanggan
   - Login dan registrasi
   - Melihat katalog produk
   - Membuka detail produk
   - Menyimpan produk favorit
   - Menambahkan produk ke keranjang
   - Melakukan checkout dan pembayaran
   - Melihat riwayat pesanan
   - Mengakses profil pengguna

2. Sisi admin
   - Mengelola produk
   - Mengelola pengguna
   - Mengelola komentar/ulasan pelanggan
   - Memverifikasi pembayaran
   - Mengatur jam operasional
   - Mengelola konten halaman utama

---

## Fungsi Utama Aplikasi

### 1. Autentikasi Pengguna
- Registrasi akun pelanggan
- Login pengguna
- Lupa password
- Session management menggunakan token

### 2. Katalog Produk
- Menampilkan produk aktif
- Detail produk beserta warna, ukuran, dan stok
- Fitur pencarian dan filter produk
- Tampilan produk berdasarkan section homepage yang dipilih admin

### 3. Belanja dan Checkout
- Menambahkan produk ke keranjang
- Mengatur jumlah pembelian
- Menampilkan ringkasan belanja
- Proses checkout dengan alamat pengiriman

### 4. Pembayaran
- Integrasi pembayaran Midtrans
- Dukungan metode pembayaran GoPay dan QRIS
- Pengecekan status transaksi

### 5. Riwayat Pesanan
- Pelanggan dapat melihat status pesanan mereka
- Admin dapat melihat daftar order dan mengubah status pembayaran

### 6. Komentar dan Rating
- Pelanggan dapat memberikan ulasan produk
- Admin dapat melihat dan mengelola komentar

### 7. Asisten Chat AI
- Tersedia fitur chat sederhana yang terhubung ke backend
- Memberikan respons berbasis aturan dan data produk

### 8. Panel Admin
- Dashboard admin
- Manajemen admin, pengguna, produk, komentar, dan pembayaran
- Pengaturan jam operasional toko

---

## Tampilan Aplikasi

Aplikasi frontend dibuat dengan desain mobile-first menggunakan Flutter. Beberapa bagian utama tampilan yang tersedia antara lain:

- Halaman login dan sign up
- Beranda dengan banner dan section produk terpilih
- Halaman katalog produk
- Halaman detail produk
- Halaman keranjang belanja
- Halaman checkout
- Halaman profil pengguna
- Halaman favorit dan riwayat pesanan
- Halaman chat AI

Secara visual, aplikasi menggunakan gaya warna soft pink, hijau muda, dan biru pastel yang konsisten di seluruh antarmuka.

---

## Alur Penggunaan

### Untuk Pelanggan
1. Jalankan aplikasi Flutter
2. Daftar akun atau login
3. Jelajahi katalog produk
4. Pilih produk dan lihat detail
5. Tambahkan ke keranjang
6. Lakukan checkout
7. Pilih metode pembayaran
8. Konfirmasi transaksi dan pantau status pesanan

### Untuk Admin
1. Login ke panel admin
2. Akses dashboard
3. Kelola produk, pengguna, pembayaran, komentar, dan jam operasional
4. Verifikasi pembayaran pelanggan
5. Update status pemesanan jika diperlukan

---

## Arsitektur dan Infrastruktur

### Frontend
- Framework: Flutter
- Bahasa: Dart
- Tujuan: aplikasi mobile pelanggan
- Lokasi: [frontend](frontend)

### Backend
- Framework: Laravel
- Bahasa: PHP
- Tujuan: API, autentikasi, bisnis logic, integrasi pembayaran, dan panel admin
- Lokasi: [rr-hijab-backend](rr-hijab-backend)

### Basis Data
- Direkomendasikan: MySQL melalui Docker
- Opsional: SQLite untuk pengembangan sederhana

### Cache & Layanan Pendukung
- Redis untuk kebutuhan cache dan layanan pendukung
- phpMyAdmin untuk administrasi database

### Container / Dev Environment
- Docker Compose tersedia di [docker_baru](docker_baru)
- Menyediakan:
  - MySQL
  - Redis
  - phpMyAdmin

---

## Struktur Repository

- [frontend](frontend) : kode aplikasi mobile Flutter
- [rr-hijab-backend](rr-hijab-backend) : kode backend Laravel
- [docker_baru](docker_baru) : konfigurasi Docker Compose
- [tests](tests) : pengujian end-to-end
- [playwright.config.ts](playwright.config.ts) : konfigurasi Playwright

---

## Teknologi yang Digunakan

### Frontend
- Flutter
- Material Design
- HTTP client
- Shared Preferences
- Image Picker
- URL Launcher
- Cached Network Image
- Flutter Map
- Midtrans SDK

### Backend
- Laravel 13
- Sanctum untuk API authentication
- Eloquent ORM
- Middleware role-based access
- Midtrans PHP SDK
- Queue / artisan commands

---

## Prasyarat Instalasi

Pastikan perangkat Anda sudah memiliki:

- PHP 8.3+
- Composer
- Flutter SDK
- Node.js dan npm
- Docker Desktop (opsional, tetapi direkomendasikan)
- MySQL / Redis (jika tidak memakai Docker)

---

## Panduan Instalasi Teknis

## 1. Clone Repository

```bash
git clone <repository-url>
cd rr-hijab-integration
```

---

## 2. Menjalankan Database dengan Docker

Masuk ke folder Docker:

```bash
cd docker_baru
docker compose up -d
```

Layanan yang akan berjalan:
- MySQL di port 3307
- Redis di port 6380
- phpMyAdmin di port 8081

Akses phpMyAdmin melalui:

```text
http://localhost:8081
```

Kredensial default:
- Username: root
- Password: rootpassword

---

## 3. Setup Backend Laravel

Masuk ke folder backend:

```bash
cd ../rr-hijab-backend
composer install
cp .env.example .env
php artisan key:generate
```

### Konfigurasi database

Untuk penggunaan Docker MySQL, isi file .env dengan contoh berikut:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3307
DB_DATABASE=rrhijab_db
DB_USERNAME=root
DB_PASSWORD=rootpassword
```

Jika ingin memakai SQLite untuk pengembangan cepat, Anda dapat menyesuaikan .env menjadi:

```env
DB_CONNECTION=sqlite
```

Lalu jalankan migrasi dan seeder:

```bash
php artisan migrate --seed
php artisan storage:link
```

Jalankan backend:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

Backend biasanya tersedia di:

```text
http://127.0.0.1:8000
```

### Konfigurasi pembayaran Midtrans

Jika ingin mengaktifkan pembayaran real, tambahkan konfigurasi Midtrans pada file .env backend:

```env
MIDTRANS_SERVER_KEY=your_server_key
MIDTRANS_CLIENT_KEY=your_client_key
MIDTRANS_IS_PRODUCTION=false
```

---

## 4. Setup Frontend Flutter

Masuk ke folder frontend:

```bash
cd ../frontend
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run
```

### Jika menjalankan pada device fisik
Karena frontend mengakses backend lewat URL tertentu, pastikan base URL backend benar. Jika dijalankan di device fisik, gunakan IP lokal komputer Anda, misalnya:

```bash
flutter run --dart-define=BACKEND_URL=http://192.168.1.10:8000
```

Jika dijalankan di emulator atau browser, URL default biasanya sudah cukup.

---

## 5. Menjalankan Test

### Playwright (end-to-end)

Di root repository:

```bash
npx playwright test
```

### Laravel test

Di folder backend:

```bash
php artisan test
```

---

## 6. Perintah Umum yang Sering Dipakai

### Docker
```bash
docker compose up -d
docker compose ps
docker compose down
```

### Backend Laravel
```bash
php artisan migrate
php artisan migrate:fresh --seed
php artisan serve
```

### Frontend Flutter
```bash
flutter pub get
flutter clean
flutter run
```

---

## Catatan Pengembangan

- Untuk development lokal, pastikan backend dan frontend berjalan pada host yang dapat saling terhubung.
- Jika aplikasi frontend tidak bisa mengakses backend, cek IP host, port, dan konfigurasi URL API.
- Untuk environment Docker, pastikan port 3307, 6380, dan 8081 tidak dipakai oleh layanan lain.
- Jika ingin menjalankan project secara penuh, pastikan MySQL dan Redis aktif terlebih dahulu sebelum menjalankan backend.

---

## Kesimpulan

RR Hijab Integration adalah solusi e-commerce hijab yang menggabungkan frontend mobile modern, backend API yang kuat, dan infrastruktur pendukung yang siap digunakan untuk pengembangan maupun deployment. Project ini cocok untuk kebutuhan toko online yang ingin memiliki alur belanja pelanggan, pembayaran terintegrasi, dan manajemen admin yang terstruktur.
