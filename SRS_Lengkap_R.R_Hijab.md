# Software Requirements Specification (SRS)
## Sistem Manajemen Pesanan R.R Hijab

**Versi:** 1.0  
**Tanggal:** 2026-06-11  
**Status:** Draft Final  
**Author:** Kelompok 1 - UAS

---

## 1. PENDAHULUAN

### 1.1 Tujuan Dokumen
Dokumen ini mendefinisikan persyaratan perangkat lunak lengkap untuk Sistem Manajemen Pesanan R.R Hijab yang mencakup aplikasi web admin, aplikasi mobile Flutter, dan integrasi dengan sistem pihak ketiga (WhatsApp Gateway).

### 1.2 Cakupan Sistem
Sistem ini mencakup:
- **Aplikasi Web Admin**: Untuk pengelolaan pesanan, validasi pembayaran, dan manajemen produk
- **Aplikasi Mobile (Flutter)**: Untuk pelanggan untuk melihat katalog dan membuat pesanan
- **Database MySQL**: Untuk penyimpanan data terpusat
- **WhatsApp Gateway**: Untuk notifikasi otomatis kepada pelanggan

### 1.3 Daftar Stakeholder
1. **Owner/Manajemen**: Pemilik usaha R.R Hijab
2. **Admin/Pengelola**: Operator web untuk validasi pembayaran
3. **Pelanggan**: Pengguna aplikasi mobile untuk berbelanja
4. **Tim Development**: Pengembang web dan mobile
5. **Tim Operations**: Maintenance dan monitoring sistem

### 1.4 Definisi, Akronim, dan Singkatan
| Singkatan | Definisi |
|-----------|----------|
| API | Application Programming Interface |
| CRUD | Create, Read, Update, Delete |
| JWT | JSON Web Token |
| ERD | Entity Relationship Diagram |
| WIB | Waktu Indonesia Barat |
| HTTPS | HyperText Transfer Protocol Secure |
| CSRF | Cross-Site Request Forgery |
| XSS | Cross-Site Scripting |
| SQL | Structured Query Language |
| FCM | Firebase Cloud Messaging |
| Redis | Remote Dictionary Server |
| TTL | Time To Live |

---

## 2. DESKRIPSI UMUM SISTEM

### 2.1 Perspektif Produk
Sistem Manajemen Pesanan R.R Hijab adalah platform e-commerce yang mengelola penjualan jilbab secara online. Sistem terdiri dari tiga komponen utama:

1. **Frontend Web Admin**: Interface web untuk pengelola toko
2. **Frontend Mobile Flutter**: Aplikasi mobile untuk pelanggan
3. **Backend API**: Server yang mengelola logika bisnis dan data

### 2.2 Fungsi Produk Utama
1. **Manajemen Katalog Produk**: Penambahan, editing, dan penghapusan produk
2. **Proses Pemesanan**: Pelanggan membuat pesanan melalui aplikasi mobile
3. **Validasi Pembayaran**: Admin memvalidasi bukti transfer dari pelanggan
4. **Notifikasi Real-time**: Update status pesanan langsung ke pelanggan
5. **Manajemen Stok**: Sistem otomatis mengelola ketersediaan produk
6. **Sistem Autentikasi Aman**: Login dengan enkripsi password bcrypt

### 2.3 Karakteristik Pengguna
| Tipe Pengguna | Karakteristik | Kebutuhan |
|---------------|----------------|-----------|
| Admin | Pengetahuan teknis menengah | Validasi pembayaran, manajemen produk |
| Pelanggan | Berbagai latar belakang teknis | Browsing, pesan, lacak status |
| Guest | Tanpa akun | Melihat katalog produk |

### 2.4 Batasan Umum
1. **Waktu Operasional**: Validasi pembayaran hanya 08:00-17:00 WIB
2. **Batas Waktu Pembayaran**: 24 jam dari pembuatan pesanan
3. **Batas Stok Produk**: Maksimal 10,000 unit per produk
4. **Timeout Idle**: 30 menit untuk web, 8 jam untuk mobile
5. **Konektivitas**: Sistem memerlukan koneksi internet yang stabil

---

## 3. REQUIREMENTS FUNGSIONAL

### 3.1 Modul Autentikasi & Otorisasi

#### 3.1.1 Login Web Admin
- Sistem harus menyediakan halaman login untuk admin dengan form username dan password
- Sistem harus memvalidasi credentials admin terhadap database dengan menggunakan enkripsi bcrypt
- Sistem harus menerapkan rate limiting maksimal 5 failed login attempts dalam 15 menit dari IP yang sama
- Sistem harus menghasilkan session ID unik minimal 32 karakter untuk setiap login sukses
- Sistem harus menyimpan session di Redis atau Database dengan TTL sesuai durasi session
- Sistem harus menerapkan CSRF token protection pada setiap halaman login
- Session harus di-expire otomatis setelah:
  - 30 menit idle time (tanpa aktivitas)
  - 8 jam absolute timeout (maksimal durasi session)
  - Atau 30 hari jika admin memilih "Remember Me"
- Sistem harus menggunakan HTTPS untuk semua komunikasi login
- Sistem harus menyimpan session cookie dengan flags: Secure, HttpOnly, SameSite=Strict

#### 3.1.2 Login Mobile Admin
- Aplikasi mobile harus menyediakan login screen dengan input username dan password
- Sistem harus generate JWT token untuk autentikasi mobile dengan payload berisi: admin_id, username, email, issued_at, expiration
- JWT token harus di-sign menggunakan algoritma HS256 dengan secret key yang disimpan aman di server
- Sistem harus menyimpan JWT token di secure storage (Keystore Android/Keychain iOS)
- Aplikasi mobile harus menyediakan auto-login jika token masih valid dan belum expired
- Aplikasi mobile harus melakukan token validation ke server setiap kali aplikasi dibuka
- Sistem harus support refresh token untuk memperpanjang session tanpa login ulang

#### 3.1.3 Logout
- Admin harus dapat melakukan logout dari sistem web maupun mobile
- Sistem harus menghapus session/token dari storage saat logout
- Sistem harus redirect ke halaman login setelah logout sukses

#### 3.1.4 Password Management
- Sistem harus encrypt password menggunakan bcrypt dengan salt rounds minimal 10
- Password tidak boleh disimpan dalam bentuk plain text di database
- Sistem harus menyediakan fitur "Forgot Password" untuk reset password admin
- Reset password harus melalui link unik yang dikirim ke email admin
- Reset password link harus expire dalam 1 jam

### 3.2 Modul Manajemen Produk

#### 3.2.1 Katalog Produk
- Sistem harus menampilkan daftar semua produk jilbab di aplikasi mobile
- Setiap produk harus memiliki atribut: ID, Nama, Deskripsi, Kategori, Harga, Link Foto, Status, Stok
- Sistem harus menampilkan produk berdasarkan status Aktif (stok > 0) atau Tidak Aktif (stok = 0)
- Aplikasi mobile harus mendukung pencarian produk berdasarkan nama dan kategori
- Aplikasi mobile harus menampilkan katalog dalam waktu kurang dari 3 detik
- Sistem harus cache data katalog untuk meningkatkan performa (Redis atau Memcached)

#### 3.2.2 Manajemen Produk di Web Admin
- Admin harus dapat menambahkan produk baru dengan input: nama, deskripsi, kategori, harga, foto
- Admin harus dapat mengedit informasi produk yang sudah ada
- Admin harus dapat mengubah status produk (Aktif/Tidak Aktif)
- Admin harus dapat melihat stok produk real-time di dashboard
- Sistem harus mencatat siapa (admin ID) dan kapan perubahan produk dilakukan di log_aktivitas
- Setiap perubahan katalog produk harus langsung tersinkronisasi ke aplikasi mobile

### 3.3 Modul Pemesanan

#### 3.3.1 Membuat Pesanan
- Pelanggan harus dapat membuat pesanan melalui aplikasi mobile dengan memilih produk dan menginput data
- Data pesanan yang wajib diinput: nama pelanggan, nomor WhatsApp, pilihan produk, jumlah
- Sistem harus validasi stok produk sebelum membuat pesanan (stok >= jumlah yang dipesan)
- Sistem harus mengurangi stok produk sebesar jumlah yang dipesan saat pesanan berhasil dibuat
- Sistem harus generate nomor invoice unik untuk setiap pesanan
- Status awal pesanan harus "Menunggu Pembayaran"
- Sistem harus catat waktu pembuatan pesanan (timestamp)
- Sistem harus menyimpan pesanan ke database MySQL
- Sistem harus return nomor invoice dan tautan WhatsApp Gateway ke aplikasi mobile
- Pelanggan dapat membuat pesanan kapan saja (24 jam), termasuk di luar jam kerja

#### 3.3.2 Riwayat Pesanan
- Pelanggan harus dapat melihat riwayat semua pesanan mereka di aplikasi mobile
- Riwayat pesanan harus menampilkan: nomor invoice, tanggal, status, total harga, produk
- Aplikasi mobile harus menampilkan countdown timer 24 jam untuk setiap pesanan yang berstatus "Menunggu Pembayaran"

#### 3.3.3 Pembatalan Pesanan
- Pelanggan harus dapat membatalkan pesanan selama status masih "Menunggu Pembayaran"
- Sistem harus mengembalikan stok produk ke inventory saat pesanan dibatalkan
- Status pesanan harus berubah menjadi "Dibatalkan Pelanggan" saat pembatalan dilakukan
- Sistem harus kirim notifikasi WhatsApp ke pelanggan saat pembatalan pesanan

### 3.4 Modul Validasi Pembayaran

#### 3.4.1 Proses Validasi
- Admin harus dapat mengakses halaman validasi pembayaran di web admin
- Halaman validasi harus menampilkan daftar pesanan dengan status "Menunggu Pembayaran"
- Admin harus dapat mencari pesanan berdasarkan nomor invoice
- Untuk setiap pesanan, admin harus dapat melihat: nomor invoice, nama pelanggan, total harga, nomor WhatsApp, waktu pembuatan
- Admin harus dapat mengklik tombol "Validasi Pembayaran" untuk mulai proses validasi
- Sistem harus validasi:
  - Pesanan ditemukan di database
  - Status pesanan = "Menunggu Pembayaran"
  - Waktu pembuatan < 24 jam
  - Tidak ada duplikasi validasi sebelumnya
- Jika semua validasi lolos, sistem harus update status menjadi "Diproses"
- Sistem harus catat waktu pembayaran (kapan admin melakukan validasi)
- Sistem harus update timestamp "diubah_pada" saat perubahan status
- Semua operasi database harus dibungkus dalam transaction (BEGIN-COMMIT-ROLLBACK)

#### 3.4.2 Pembatalan Otomatis
- Sistem harus menjalankan scheduled job setiap 5 menit untuk mengecek pesanan yang sudah melewati 24 jam
- Pesanan yang sudah > 24 jam tanpa pembayaran harus otomatis diubah status menjadi "Dibatalkan Sistem"
- Saat pembatalan otomatis, sistem harus:
  - Update status pesanan
  - Kembalikan stok produk
  - Kirim notifikasi WhatsApp ke pelanggan
  - Catat di log_aktivitas
  - Update UI di aplikasi mobile real-time
- Sistem harus catat jumlah pesanan yang dibatalkan dalam log_scheduled_job untuk monitoring

### 3.5 Modul Notifikasi

#### 3.5.1 Validasi WhatsApp Gateway
- Sistem harus validasi nomor WhatsApp sebelum mengirim pesan:
  - Nomor tidak boleh kosong
  - Hanya angka 0-9
  - Format internasional Indonesia (62...)
  - Minimal 10 digit setelah kode negara
- Sistem harus format nomor ke standar internasional:
  - Ganti "0" di awal dengan "62"
  - Jika sudah "62", biarkan seperti itu
  - Hapus "+62" menjadi "62..."

#### 3.5.2 Template Pesan
- Sistem harus mendukung template pesan berdasarkan tipe notifikasi:
  - Pembayaran Divalidasi
  - Pesanan Dibatalkan Timeout
  - Pesanan Dikirim
  - Pesanan Selesai
- Setiap template harus berisi informasi yang relevan: nama pelanggan, nomor invoice, total harga, status

#### 3.5.3 Pengiriman WhatsApp
- Sistem harus kirim notifikasi WhatsApp ke pelanggan saat:
  - Admin validasi pembayaran (status menjadi "Diproses")
  - Pesanan dibatalkan karena timeout
  - Pesanan sedang dikirim
  - Pesanan sudah diterima
- Sistem harus kirim WhatsApp message melalui WhatsApp Gateway API menggunakan HTTP POST
- Sistem harus catat setiap pengiriman WhatsApp di log_whatsapp_notification dengan status: SENT, PENDING, FAILED
- Jika pengiriman gagal, sistem harus retry otomatis maksimal 3 kali dengan exponential backoff:
  - Retry 1: 5 detik
  - Retry 2: 25 detik
  - Retry 3: 125 detik
- Notifikasi WhatsApp hanya boleh dikirim pada jam kerja (08:00-17:00 WIB), diluar jam kerja harus di-delay

#### 3.5.4 Real-time Updates ke Mobile
- Sistem harus trigger update real-time ke aplikasi mobile saat status pesanan berubah
- Sistem harus menggunakan salah satu channel: WebSocket, Push Notification (FCM), atau Message Queue
- Priority channel pengiriman:
  1. WebSocket (jika aplikasi aktif)
  2. Push Notification FCM (jika aplikasi background)
  3. Message Queue (fallback jika kedua gagal)
- Aplikasi mobile harus menerima dan meng-update status pesanan secara real-time
- Aplikasi mobile harus hentikan countdown timer saat status berubah dari "Menunggu Pembayaran"

### 3.6 Modul Manajemen Stok

#### 3.6.1 Pengembalian Stok
- Saat pesanan dibatalkan, sistem harus mengembalikan stok produk ke inventory
- Formula pengembalian stok: Stok Baru = Stok Lama + Quantity Pesanan yang Dibatalkan
- Sistem harus tentukan status produk berdasarkan stok baru:
  - Stok > 0: Status "Aktif"
  - Stok = 0: Status "Tidak Aktif"
  - Stok < 0: Error (tidak boleh terjadi)
- Sistem harus validasi stok tidak melebihi batas maksimal 10,000 unit per produk
- Sistem harus update cache (Redis) setelah perubahan stok
- Sistem harus catat setiap perubahan stok di log_stok untuk audit trail
- Perubahan stok harus trigger update katalog ke aplikasi mobile secara real-time

### 3.7 Modul Countdown Timer (Mobile)

#### 3.7.1 Timer Display
- Aplikasi mobile harus menampilkan countdown timer 24 jam untuk setiap pesanan "Menunggu Pembayaran"
- Timer harus ditampilkan dalam format HH:MM:SS dengan padding 0 di depan (contoh: 23:45:30)
- Timer harus update setiap detik
- Timer harus menggunakan device timestamp dan data waktu pembuatan pesanan dari server

#### 3.7.2 Visual Indicator
- Sistem harus menentukan warna timer berdasarkan sisa waktu:
  - HIJAU: > 1 jam (> 3600 detik)
  - ORANGE: 10 menit - 1 jam (600-3600 detik)
  - MERAH: < 10 menit (< 600 detik)
- Sistem harus menampilkan progress bar visual untuk menunjukkan progress countdown

#### 3.7.3 Sinkronisasi dengan Server
- Setiap 1 menit, aplikasi mobile harus sync dengan server untuk mengecek status pesanan terbaru
- Sync endpoint: GET /api/orders/{invoiceID}/status
- Jika status berubah menjadi "Diproses", hentikan timer dan tampilkan success message
- Jika status berubah menjadi "Dibatalkan", hentikan timer dan tampilkan error message
- Jika network error, aplikasi harus retry pada sync 1 menit berikutnya tanpa mengganggu UX

#### 3.7.4 Cleanup
- Saat timer selesai, aplikasi harus cleanup resources:
  - Hentikan timer loop
  - Cancel pending HTTP requests
  - Remove event listeners
  - Clear memory

### 3.8 Modul Database

#### 3.8.1 Struktur Database
- Database harus menggunakan MySQL atau PostgreSQL
- Database harus memiliki tabel minimal:
  - admin (menyimpan data admin)
  - produk (menyimpan data produk)
  - pesanan (menyimpan data pesanan)
  - feedback (menyimpan ulasan pelanggan)
  - log_aktivitas (menyimpan log semua aksi)
  - log_stok (menyimpan log perubahan stok)
  - log_whatsapp_notification (menyimpan log pengiriman WhatsApp)
  - login_history (menyimpan riwayat login)
  - sessions (menyimpan session admin web)
- Setiap tabel harus memiliki Primary Key yang unik dan auto-increment
- Foreign Key harus di-setup untuk relasi antar tabel
- Tabel admin harus memiliki kolom: id_admin, username (unique), password_hash, email, status, created_at, updated_at
- Tabel pesanan harus memiliki kolom: id_pesanan (invoice), id_produk (FK), nama_pelanggan, nomor_whatsapp, status, total_harga, quantity, created_at, updated_at
- Tabel produk harus memiliki kolom: id_produk, nama_produk, deskripsi, kategori, harga, link_foto, stok, status, created_at, updated_at

#### 3.8.2 Indexing
- Database harus memiliki index pada kolom yang sering di-query:
  - id_pesanan (primary key)
  - status_pesanan
  - waktu_pembuatan
  - username (untuk login)
  - id_produk
- Index harus meningkatkan performa query minimal 50%

#### 3.8.3 Data Sanitization
- Semua input user harus di-sanitize sebelum masuk database
- Sistem harus menggunakan parameterized queries untuk prevent SQL injection
- Data sensitif (password, nomor WhatsApp) harus di-encrypt di database

### 3.9 Modul API

#### 3.9.1 API Umum
- Semua API harus menggunakan standar RESTful atau GraphQL yang konsisten
- API response harus dalam format JSON dengan struktur: { status, message, data, errors }
- Setiap API harus memiliki dokumentasi lengkap (Swagger/OpenAPI)
- API harus mengembalikan HTTP status code yang sesuai:
  - 200 OK
  - 201 Created
  - 400 Bad Request
  - 401 Unauthorized
  - 403 Forbidden
  - 404 Not Found
  - 429 Too Many Requests
  - 5xx Server Error

#### 3.9.2 Authentication Header
- Mobile app harus mengirimkan JWT token di Authorization header: "Bearer {token}"
- Web admin harus mengirimkan session cookie otomatis dengan setiap request
- Server harus validasi token/session pada setiap protected endpoint

#### 3.9.3 API Endpoint Kritis
- POST /api/admin/login - Login admin (web & mobile)
- POST /api/admin/logout - Logout admin
- GET /api/products - Mendapatkan daftar produk (mobile)
- POST /api/orders - Membuat pesanan baru (mobile)
- GET /api/orders/{invoiceID}/status - Mengecek status pesanan (mobile)
- POST /api/orders/{invoiceID}/validate-payment - Validasi pembayaran (web admin)
- POST /api/orders/{invoiceID}/cancel - Batalkan pesanan (mobile & web)
- GET /api/admin/dashboard - Dashboard admin (web)

---

## 4. REQUIREMENTS NON-FUNGSIONAL

### 4.1 Performance
- Response time untuk list produk: < 3 detik
- Response time untuk validasi pembayaran: < 2 detik
- Response time untuk login: < 2 detik
- Sistem harus support minimal 1000 concurrent users
- Database query harus optimize dengan index dan caching
- Cache expiration time: 1 jam untuk katalog, 5 menit untuk stok

### 4.2 Keamanan
- Semua komunikasi harus menggunakan HTTPS/SSL encryption
- Password harus di-hash menggunakan bcrypt dengan minimal 10 salt rounds
- JWT token harus signed dengan algoritma HS256 atau RS256
- Rate limiting: maksimal 5 failed login attempts per 15 menit per IP
- Session timeout: 30 menit idle, 8 jam absolute
- CSRF token protection pada semua form submit
- Input validation dan sanitization pada semua endpoint
- XSS protection dengan Content-Security-Policy headers
- Clickjacking protection dengan X-Frame-Options headers

### 4.3 Availability
- Sistem harus available 24/7 dengan uptime minimal 99.5%
- Database backup harus dilakukan setiap hari
- Disaster recovery plan harus ada untuk business continuity
- Server harus redundancy dengan load balancing

### 4.4 Scalability
- Sistem harus scalable untuk mendukung pertumbuhan transaksi 100% per tahun
- Database harus support sharding untuk distribusi data
- Backend harus dapat di-scale horizontally dengan multiple server instances

### 4.5 Usability
- Interface harus user-friendly dan intuitif untuk admin dan pelanggan
- Response time yang cepat untuk meningkatkan user experience
- Aplikasi mobile harus responsive di semua ukuran layar
- Error messages harus jelas dan informatif

### 4.6 Reliability
- Database transaction harus atomicity untuk menjaga consistency
- Retry mechanism untuk failed operations (exponential backoff)
- Logging dan monitoring untuk detect dan resolve issues
- Audit trail untuk semua aksi penting (compliance)

### 4.7 Compatibility
- Web browser yang di-support: Chrome, Firefox, Safari, Edge (latest 2 versions)
- Mobile OS yang di-support: Android 8.0+, iOS 12.0+
- API harus backward compatible untuk versioning

### 4.8 Maintainability
- Code harus mengikuti best practices dan coding standards
- Code documentation harus lengkap dengan comments dan docstrings
- API documentation harus up-to-date dan comprehensive
- Database schema harus well-documented

### 4.9 Compliance
- Sistem harus comply dengan regulasi privasi data (GDPR-like)
- Customer data harus secure dan tidak diekspos ke publik
- Audit trail harus tersedia untuk compliance dan investigation

---

## 5. DATA FLOW & ARCHITECTURE

### 5.1 Arsitektur Sistem
```
┌─────────────────────────────────────────────────────────────────┐
│                     USER INTERFACE LAYER                         │
├────────────────────┬────────────────────────────────────────┤
│   Web Admin        │     Mobile Application (Flutter)      │
│   - Dashboard      │     - Katalog Produk                 │
│   - Validasi       │     - Riwayat Pesanan                │
│   - Manajemen      │     - Checkout                        │
└────────────────────┴────────────────────────────────────────┤
                                                                │
┌─────────────────────────────────────────────────────────────┐
│                    API GATEWAY / LOAD BALANCER               │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                   APPLICATION SERVER                         │
│  ├─ Authentication Service                                   │
│  ├─ Product Management Service                               │
│  ├─ Order Management Service                                 │
│  ├─ Payment Validation Service                               │
│  └─ Notification Service                                     │
└─────────────────────────────────────────────────────────────┘
        │                           │                 │
        ▼                           ▼                 ▼
    ┌────────┐              ┌─────────────┐    ┌──────────────┐
    │ MySQL  │              │    Redis    │    │  WhatsApp    │
    │Database│              │   Cache     │    │  Gateway     │
    └────────┘              └─────────────┘    └──────────────┘
```

### 5.2 Flow Diagram Validasi Pembayaran
```
Admin Login
    │
    ▼
Dashboard Validasi Pembayaran
    │
    ▼
Pilih Pesanan
    │
    ▼
System Validasi:
- Invoice ada?
- Status = "Menunggu Pembayaran"?
- Waktu < 24 jam?
    │
    ├─ Gagal ──> Error Message
    │
    └─ Sukses ──> Update Status = "Diproses"
                    │
                    ├─> Reset Stok (jika ada pembatalan)
                    ├─> Log Aktivitas
                    ├─> Kirim WhatsApp Notification
                    ├─> Update Mobile Real-time
                    └─> Success Message
```

### 5.3 Flow Diagram Countdown Timer (Mobile)
```
Buka Pesanan
    │
    ▼
Ambil Waktu Pembuatan dari Server
    │
    ▼
Hitung Sisa Waktu: 24 Jam - (Sekarang - Waktu Pembuatan)
    │
    ▼
Update UI setiap 1 detik
    │
    ├─ Sisa > 1 jam: HIJAU
    ├─ Sisa 10 menit-1 jam: ORANGE
    └─ Sisa < 10 menit: MERAH
    │
    ▼ (Setiap 1 menit)
Sync Status dengan Server
    │
    ├─ Status = "Diproses" ──> Hentikan Timer, Success
    ├─ Status = "Dibatalkan" ──> Hentikan Timer, Error
    └─ Status = "Menunggu Pembayaran" ──> Lanjut
    │
    ▼
Sisa Waktu <= 0?
    │
    ├─ YA ──> Pesanan Kadaluwarsa
    │
    └─ TIDAK ──> Lanjut
```

---

## 6. ENTITAS & RELASI DATABASE

### 6.1 Entity Relationship Diagram (ERD)

#### Tabel Admin
| Kolom | Tipe | Constraint | Deskripsi |
|-------|------|-----------|-----------|
| id_admin | INT | PK, AUTO_INCREMENT | ID unik admin |
| username | VARCHAR(50) | UNIQUE, NOT NULL | Username untuk login |
| password_hash | VARCHAR(255) | NOT NULL | Password ter-hash bcrypt |
| email | VARCHAR(100) | UNIQUE, NOT NULL | Email admin |
| status | ENUM | NOT NULL (Aktif/Tidak Aktif) | Status akun |
| failed_login_attempts | INT | DEFAULT 0 | Jumlah gagal login |
| locked_until | TIMESTAMP | NULL | Kapan account di-unlock |
| last_login | TIMESTAMP | NULL | Waktu login terakhir |
| last_login_ip | VARCHAR(50) | NULL | IP login terakhir |
| created_at | TIMESTAMP | NOT NULL | Waktu dibuat |
| updated_at | TIMESTAMP | NOT NULL | Waktu diupdate |

#### Tabel Produk
| Kolom | Tipe | Constraint | Deskripsi |
|-------|------|-----------|-----------|
| id_produk | INT | PK, AUTO_INCREMENT | ID unik produk |
| id_admin | INT | FK (admin) | Admin yang membuat produk |
| nama_produk | VARCHAR(255) | NOT NULL | Nama jilbab |
| deskripsi | TEXT | NOT NULL | Deskripsi detail |
| kategori | VARCHAR(100) | NOT NULL | Kategori produk |
| harga | DECIMAL(10,2) | NOT NULL | Harga jual |
| link_foto | VARCHAR(500) | NOT NULL | URL foto produk |
| stok | INT | NOT NULL (DEFAULT 0) | Jumlah stok |
| status | ENUM | NOT NULL (Aktif/Tidak Aktif) | Status produk |
| created_at | TIMESTAMP | NOT NULL | Waktu dibuat |
| updated_at | TIMESTAMP | NOT NULL | Waktu diupdate |

#### Tabel Pesanan
| Kolom | Tipe | Constraint | Deskripsi |
|-------|------|-----------|-----------|
| id_pesanan | VARCHAR(20) | PK, UNIQUE | Nomor invoice |
| id_produk | INT | FK (produk) | Produk yang dipesan |
| nama_pelanggan | VARCHAR(255) | NOT NULL | Nama pembeli |
| nomor_whatsapp | VARCHAR(20) | NOT NULL | Nomor WA pelanggan |
| status | ENUM | NOT NULL | Status pesanan |
| total_harga | DECIMAL(10,2) | NOT NULL | Total harga |
| quantity | INT | NOT NULL | Jumlah dipesan |
| created_at | TIMESTAMP | NOT NULL | Waktu pembuatan |
| updated_at | TIMESTAMP | NOT NULL | Waktu update |
| validated_by | INT | FK (admin) | Admin yang validasi |
| validated_at | TIMESTAMP | NULL | Waktu validasi |

#### Tabel Feedback
| Kolom | Tipe | Constraint | Deskripsi |
|-------|------|-----------|-----------|
| id_feedback | INT | PK, AUTO_INCREMENT | ID feedback |
| id_pesanan | VARCHAR(20) | FK (pesanan) | Pesanan terkait |
| nama_pengirim | VARCHAR(255) | NOT NULL | Nama pemberi ulasan |
| isi_komentar | TEXT | NOT NULL | Isi ulasan |
| created_at | TIMESTAMP | NOT NULL | Waktu dibuat |

#### Tabel Log_Aktivitas
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| id_log | INT | ID log (PK) |
| id_pesanan | VARCHAR(20) | Pesanan terkait |
| id_admin | INT | Admin yang melakukan aksi |
| aksi | VARCHAR(255) | Aksi yang dilakukan |
| waktu | TIMESTAMP | Waktu aksi |
| keterangan | TEXT | Keterangan aksi |
| ip_address | VARCHAR(50) | IP address admin |
| user_agent | VARCHAR(500) | User agent |

#### Tabel Log_Stok
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| id_log_stok | INT | ID log stok (PK) |
| id_produk | INT | Produk terkait |
| stok_lama | INT | Stok sebelumnya |
| stok_baru | INT | Stok setelah perubahan |
| jenis_perubahan | VARCHAR(100) | Jenis perubahan |
| keterangan | TEXT | Keterangan |
| waktu | TIMESTAMP | Waktu perubahan |

#### Tabel Sessions
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| session_id | VARCHAR(255) | ID session (PK) |
| admin_id | INT | Admin yang login |
| ip_address | VARCHAR(50) | IP address |
| user_agent | VARCHAR(500) | User agent |
| created_at | TIMESTAMP | Waktu dibuat |
| last_activity | TIMESTAMP | Aktivitas terakhir |
| expires_at | TIMESTAMP | Waktu expire |
| remember_me | BOOLEAN | Flag remember me |

### 6.2 Relasi Antar Tabel
1. **Admin - Produk**: One to Many (1:N)
   - Satu admin dapat mengelola banyak produk
   
2. **Admin - Pesanan**: One to Many (1:N)
   - Satu admin dapat memvalidasi banyak pesanan
   
3. **Produk - Pesanan**: One to Many (1:N)
   - Satu produk dapat dipesan berkali-kali
   
4. **Pesanan - Feedback**: One to One (1:1)
   - Satu pesanan dapat memiliki maksimal satu ulasan

---

## 7. INTERFACE SPECIFICATION

### 7.1 Web Admin Interface
#### Login Page
- Username input field
- Password input field
- Login button
- "Forgot Password" link
- "Remember Me" checkbox
- CSRF token (hidden)
- Security headers (SSL/TLS)

#### Dashboard
- Order summary (total pending, processed, completed)
- List of pending orders
- Search/filter by invoice number
- Validate payment button per order
- Settings page

#### Product Management
- Add new product form
- Edit product form
- Delete product option
- Product list table
- Stock management

### 7.2 Mobile Flutter Interface
#### Login Screen
- Username input field
- Password input field
- Login button
- "Forgot Password" button
- "Remember Me" checkbox
- Loading indicator
- Error message display

#### Product Catalog
- Product list with images
- Product name, price, category
- Search functionality
- Filter by category
- "Order" button per product
- Loading indicator (< 3 seconds)

#### Order Detail Screen
- Product image and info
- Quantity input
- Total price calculation
- "Confirm Order" button
- Customer info form (name, WhatsApp)
- Loading indicator

#### Order History Screen
- List of all customer orders
- Invoice number, date, status, total price
- Countdown timer for pending orders (HH:MM:SS)
- Color indicator (Green/Orange/Red)
- Order detail button
- Cancel order button (if status "Menunggu Pembayaran")

---

## 8. TESTING REQUIREMENTS

### 8.1 Unit Testing
- Coverage: Minimal 80% code coverage
- Framework: Jest, PHPUnit, atau sesuai bahasa
- Test Cases: Setiap function/method harus ada unit test

### 8.2 Integration Testing
- Scope: Test flow end-to-end dari login sampai konfirmasi pembayaran
- Database: Gunakan test database yang terpisah
- External Services: Mock WhatsApp Gateway API

### 8.3 Load Testing
- Tool: JMeter, Locust, atau Apache Bench
- Target: Simulate 1000 concurrent users
- Metrics: Response time, throughput, error rate

### 8.4 Security Testing
- SQL Injection: Penetration test pada semua endpoints
- XSS: Test input validation dan sanitization
- CSRF: Verify CSRF token protection
- Authentication: Test rate limiting dan account lockout

### 8.5 UAT (User Acceptance Testing)
- Participants: Admin, pelanggan, owner
- Scope: Test semua use cases dengan data real
- Feedback: Collect feedback dan improvement suggestions

---

## 9. DEPLOYMENT & OPERATIONS

### 9.1 Environment
- Development: Local development server
- Staging: Pre-production environment untuk testing
- Production: Live server untuk real users

### 9.2 Deployment Strategy
- Version Control: Git dengan branching strategy (main, develop, feature branches)
- CI/CD: Automated deployment using GitHub Actions / Jenkins
- Rollback Plan: Quick rollback untuk critical issues

### 9.3 Monitoring & Logging
- Application Logs: Log level (DEBUG, INFO, WARNING, ERROR)
- Database Logs: Query logs untuk troubleshooting
- Server Logs: Server errors, access logs
- Monitoring Tools: NewRelic, Datadog, atau ELK Stack

### 9.4 Backup & Recovery
- Database Backup: Daily backup, retention 30 days
- Backup Location: Off-site backup untuk disaster recovery
- Recovery Test: Monthly recovery drill

### 9.5 Maintenance Window
- Scheduled: Setiap bulan, 1-2 jam downtime jika perlu
- Communication: Notify users 1 minggu sebelumnya
- Emergency Maintenance: Out of schedule jika ada critical issue

---

## 10. DEPENDENCIES & TECH STACK

### 10.1 Backend Stack
- Language: PHP 8.0+, Node.js 14+, atau Python 3.8+
- Framework: Laravel, Express, Django, FastAPI
- Database: MySQL 8.0+ atau PostgreSQL 12+
- Cache: Redis 6.0+
- API Documentation: Swagger/OpenAPI
- Message Queue: RabbitMQ atau Redis Queue

### 10.2 Frontend Web
- Framework: React, Vue.js, atau Angular
- UI Library: Material-UI, Bootstrap, atau Tailwind
- State Management: Redux, Vuex, atau Context API
- HTTP Client: Axios atau Fetch API

### 10.3 Mobile Flutter
- Language: Dart 2.14+
- Framework: Flutter 2.8+
- State Management: Provider, GetX, atau BLoC
- Local Database: SQLite untuk local caching
- HTTP Client: Dio untuk API calls
- Secure Storage: flutter_secure_storage

### 10.4 External Services
- WhatsApp Gateway: Third-party gateway API
- Firebase: FCM untuk push notifications
- Email Service: SendGrid atau AWS SES

### 10.5 DevOps Tools
- Version Control: GitHub, GitLab, atau Bitbucket
- CI/CD: GitHub Actions, GitLab CI, atau Jenkins
- Container: Docker untuk containerization
- Orchestration: Kubernetes untuk production scaling
- Monitoring: Prometheus, Grafana, ELK Stack

---

## 11. APPENDIX

### 11.1 Glossary
| Term | Definisi |
|------|----------|
| Invoice | Nomor transaksi unik untuk setiap pesanan |
| Session | Keadaan login admin yang persisten di server |
| JWT Token | Token untuk autentikasi mobile app |
| Payload | Data yang dikirim dalam HTTP request/response |
| Query | Permintaan data dari database |
| Cache | Penyimpanan data temporary untuk performa |
| Rate Limiting | Pembatasan jumlah request dalam periode waktu |
| Transaction | Operasi database yang atomic |
| Rollback | Pembatalan operasi database jika error |
| Audit Trail | Log mencatat semua aktivitas untuk compliance |

### 11.2 Referensi Dokumen
1. algoritma_konfirmasi_pembayaran_Version2 (1).md
2. alur_integrasi_whatsapp_gateway.md
3. aturan_batas_waktu_dan_operasional.md
4. menentukan_database_dan_membuat_api.md
5. merancang_sistem_login_aman_Version2 (1).md
6. penjelasan_komponen_erd.md

### 11.3 Sign-Off
| Role | Nama | Tanggal | Signature |
|------|------|---------|-----------|
| Project Manager | [TBD] | [TBD] | ____________ |
| Business Analyst | [TBD] | [TBD] | ____________ |
| Technical Lead | [TBD] | [TBD] | ____________ |
| Client/Owner | [TBD] | [TBD] | ____________ |

---

## 12. CHANGELOG

| Versi | Tanggal | Deskripsi Perubahan |
|-------|---------|-------------------|
| 1.0 | 2026-06-11 | Initial SRS document creation |
| 1.1 | 2026-06-11 | Removed FR/NFR codes, kept titles and descriptions |

---

**Document Status**: DRAFT - Ready for Review  
**Last Updated**: 2026-06-11  
**Next Review Date**: 2026-06-25

