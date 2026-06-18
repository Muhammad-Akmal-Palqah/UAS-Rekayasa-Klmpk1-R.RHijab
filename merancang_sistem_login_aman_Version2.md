# Merancang Sistem Login Aman dengan Enkripsi Password Admin

Dokumen ini mendeskripsikan desain dan implementasi sistem login yang aman untuk aplikasi web admin dan aplikasi mobile Flutter R.R Hijab dengan fokus pada enkripsi password dan best practices keamanan.

---

## 1. Pendahuluan Sistem Login Aman

### 1.1 Definisi Sistem Login Aman

Sistem login aman adalah mekanisme autentikasi yang melindungi akun admin dari unauthorized access melalui kombinasi validasi username, password yang ter-enkripsi, session management, dan mekanisme keamanan lainnya. Sistem ini diimplementasikan di dua platform: web admin dan aplikasi mobile Flutter.

### 1.2 Aktor yang Terlibat

1. Admin/Pengelola: User yang ingin login ke sistem melalui web atau aplikasi mobile
2. Web Browser: Interface yang digunakan admin untuk login di web
3. Mobile Application (Flutter): Interface yang digunakan admin untuk login di mobile
4. Web Server: Menerima request login dari browser atau mobile app
5. Database: Menyimpan data admin dan password yang ter-enkripsi
6. Session Storage: Menyimpan session admin setelah login berhasil di web
7. Token Storage: Menyimpan token admin di mobile
8. Security Module: Menangani enkripsi, hashing, dan validasi

### 1.3 Tujuan Sistem Login Aman

1. Memastikan hanya admin yang sah yang dapat mengakses sistem
2. Melindungi password admin dari exposure atau theft
3. Mencegah brute force attack dan unauthorized login attempts
4. Mengelola session dan token secara aman dengan timeout mechanism
5. Mencatat semua login attempts untuk audit dan security monitoring
6. Memberikan recovery mechanism jika admin lupa password
7. Implementasikan fitur login yang sama dan secure di web dan mobile

---

## 2. Arsitektur Sistem Login Aman

### 2.1 Komponen Utama Sistem Login

#### 2.1.1 Komponen di Sisi Web Admin

1. Login Interface (UI)
   Halaman form login tempat admin memasukkan username dan password

2. Authentication Service (Frontend)
   Service di web yang menangani komunikasi dengan backend untuk login

3. Session Storage
   Menyimpan session data di server (Redis atau Database)

4. Session Cookie Management
   Browser menerima dan menyimpan session cookie

5. Protected Routes
   Routes yang hanya bisa diakses jika admin sudah authenticated

#### 2.1.2 Komponen di Sisi Mobile Flutter

1. Login Screen (UI)
   Halaman form login tempat admin memasukkan username dan password

2. Authentication Service (Mobile)
   Service di mobile yang menangani komunikasi dengan backend untuk login

3. Secure Local Storage
   Menyimpan authentication token di secure storage (Keystore/Keychain)

4. Protected Screens
   Screens yang hanya bisa diakses jika admin sudah authenticated

5. Auto-login Mechanism
   Fitur otomatis login jika token masih valid

#### 2.1.3 Komponen Backend (Shared)

1. Authentication API Endpoint
   /api/admin/login untuk handle login requests dari web dan mobile

2. Password Hashing Module
   Module yang menangani hashing dan verification password

3. Session Management (Web)
   Mengelola session admin setelah login sukses di web

4. Token Generation (Mobile)
   Menghasilkan JWT token untuk mobile app

5. Database
   Menyimpan data admin dan credentials yang ter-enkripsi

6. Audit Logger
   Mencatat semua login attempts dan activities

---

## 3. Proses Login Web Admin

### 3.1 Alur Login Web Admin Secara Keseluruhan

Proses login web admin melibatkan beberapa tahap yang terkoordinasi antara browser, server, dan database. Alur ini dirancang untuk memastikan keamanan maksimal dan mencegah berbagai jenis attack.

### 3.2 Langkah 1: Admin Membuka Halaman Login Web

1. Admin membuka browser web
2. Admin menavigasi ke URL halaman login (https://domain.com/login)
3. Server menerima request HTTP GET ke halaman login
4. Server menghasilkan halaman login HTML dengan fitur keamanan

### 3.3 Langkah 2: Server Kirim Halaman Login dengan Fitur Keamanan

Server mengirimkan halaman login yang sudah dilengkapi dengan fitur-fitur keamanan:

1. CSRF Token (Cross-Site Request Forgery Prevention)
   a. Server generate token unik untuk setiap halaman login yang diload
   b. Token ini di-embed dalam form sebagai hidden field
   c. Saat admin submit form, token ini akan dikirim kembali ke server
   d. Server memverifikasi token untuk memastikan request berasal dari form yang legitimate
   e. Jika token tidak valid atau tidak ada, server menolak login

2. SSL/TLS Encryption
   a. Halaman login harus selalu diakses via HTTPS bukan HTTP
   b. URL harus https://domain.com/login
   c. Ini memastikan semua komunikasi antara browser dan server terenkripsi

3. Security Headers
   a. Content-Security-Policy: Mencegah inline script dan protect dari XSS
   b. X-Frame-Options: Prevent clickjacking
   c. X-Content-Type-Options: Prevent MIME sniffing
   d. Strict-Transport-Security: Force HTTPS

4. Password Field Security
   a. Input field untuk password harus type="password"
   b. Password tidak terlihat di layar saat diketik (ditampilkan sebagai dots/bullets)
   c. Browser tidak auto-complete password field dari browser history

### 3.4 Langkah 3: Browser Menampilkan Form Login

1. Browser menerima halaman HTML dari server
2. Browser render halaman login untuk ditampilkan kepada admin
3. Halaman login menampilkan:
   a. Text input field untuk username
   b. Password input field untuk password
   c. Tombol "Login"
   d. Tombol "Forgot Password" (optional)
   e. Checkbox "Remember Me" (optional untuk persistent session)
   f. Links untuk help atau contact support

### 3.5 Langkah 4: Admin Masukkan Credentials

1. Admin memasukkan username di field username
2. Admin memasukkan password di field password
3. Password yang diketik tidak terlihat di layar (hanya dots/bullets)
4. Admin bisa optional check "Remember Me" jika ingin session lebih lama
5. Admin mengklik tombol "Login"

### 3.6 Langkah 5: Browser Lakukan Client-Side Validation

Sebelum mengirim request ke server, browser melakukan validasi di sisi client:

1. Cek apakah username tidak kosong
   a. Jika kosong, tampilkan error message di UI
   b. Jangan kirim request ke server

2. Cek apakah password tidak kosong
   a. Jika kosong, tampilkan error message di UI
   b. Jangan kirim request ke server

3. Cek format username
   a. Username hanya boleh mengandung alphanumeric dan underscore
   b. Panjang username minimal 3 dan maksimal 50 karakter
   c. Jika format invalid, tampilkan error dan jangan kirim

4. Cek format password
   a. Password minimal 8 karakter
   b. Jika terlalu pendek, tampilkan error dan jangan kirim

5. Cek apakah CSRF token ada di form
   a. Token harus ada sebelum submit
   b. Jika tidak ada, tampilkan error

Client-side validation ini untuk meningkatkan UX dan mengurangi unnecessary request ke server.
Namun server tetap harus melakukan validation lagi (never trust client-side validation).

### 3.7 Langkah 6: Browser Kirim HTTP POST Request Login

Setelah validasi client-side lolos, browser membuat dan mengirim HTTP POST request:

1. Method: POST
2. URL: https://domain.com/api/admin/login (atau /login)
3. Headers:
   a. Content-Type: application/json atau application/x-www-form-urlencoded
   b. User-Agent: Informasi browser (OS, browser type, versi)
   c. Referer: URL halaman login (untuk CSRF validation)
   d. Origin: Domain asal request (untuk CSRF validation)

4. Request Body (data yang dikirim):
   a. username: Username yang dimasukkan admin
   b. password: Password yang dimasukkan admin (plain text)
   c. csrf_token: Token CSRF yang di-embed di form
   d. remember_me: Boolean apakah admin memilih "Remember Me"

5. Request dikirim via HTTPS (encrypted in transit)
   a. Semua data dalam payload terenkripsi oleh SSL/TLS
   b. Tidak ada yang bisa dilihat saat transmisi

### 3.8 Langkah 7: Server Menerima Request Login

1. Server menerima HTTP POST request ke endpoint /api/admin/login
2. Server extract data dari request:
   a. Username
   b. Password
   c. CSRF token
   d. Remember me flag
   e. Request headers (User-Agent, IP address, dll)

3. Server melakukan initial checks

### 3.9 Langkah 8: Server Validasi CSRF Token

Server melakukan validasi CSRF token untuk mencegah CSRF attack:

1. Ambil CSRF token dari request body
2. Cek apakah token ada di session server yang corresponding
3. Bandingkan CSRF token dari request dengan token di server session
4. Jika token tidak sesuai atau tidak ada:
   a. Reject request
   b. Tampilkan error "Invalid CSRF token" atau generic error
   c. Log security warning untuk monitoring
   d. Hentikan proses login

5. Jika token sesuai:
   a. Token validation passed
   b. Lanjut ke step berikutnya

CSRF token ini memastikan bahwa request login benar-benar berasal dari form di halaman login yang legitimate,
bukan dari website lain yang mencoba submit form login tanpa persetujuan admin.

### 3.10 Langkah 9: Server Validasi Input

Server melakukan validasi terhadap input username dan password:

1. Validasi username:
   a. Cek apakah username tidak kosong
   b. Cek panjang username (minimal 3, maksimal 50 karakter)
   c. Cek format username (hanya alphanumeric dan underscore)
   d. Jika ada yang invalid, return error response ke browser

2. Validasi password:
   a. Cek apakah password tidak kosong
   b. Cek panjang password (minimal 8, maksimal 128 karakter)
   c. Jika ada yang invalid, return error response ke browser

3. Input sanitization:
   a. Trim whitespace dari input (jika ada space di depan/belakang)
   b. Escape special characters untuk prevent injection

Jika ada validasi yang gagal:
1. Return error response dengan message yang spesifik
2. Hentikan proses login
3. Browser menampilkan error message kepada admin

### 3.11 Langkah 10: Server Cek Rate Limiting

Server melakukan cek rate limiting untuk mencegah brute force attack:

1. Query untuk melihat berapa kali failed login dari IP address yang sama
2. Data yang dicek:
   a. Jumlah failed login attempts dari IP address ini
   b. Waktu failed login attempt terakhir
   c. Apakah IP address sudah di-block

3. Rate limiting rules:
   a. Maksimal 5 failed attempts dalam 15 menit dari IP yang sama
   b. Jika sudah 5 failed attempts, block IP tersebut
   c. Block duration: 15 menit

4. Jika rate limit exceeded:
   a. Return error "Terlalu banyak percobaan login gagal. Coba lagi dalam 15 menit"
   b. Jangan lanjutkan validasi username dan password
   c. Log security event untuk monitoring

5. Jika rate limit tidak exceeded:
   a. Lanjut ke step berikutnya

Rate limiting ini melindungi dari brute force attack di mana attacker mencoba ratusan password secara otomatis.

### 3.12 Langkah 11: Server Query Database untuk Username

Server melakukan query ke database untuk mencari admin dengan username yang sesuai:

1. Query statement:
   a. SELECT admin data FROM admin table
   b. WHERE username = parameter (query yang diinput)
   c. AND status = 'Aktif' (hanya admin aktif yang bisa login)

2. Menggunakan parameterized query:
   a. Parameter dikirim terpisah dari SQL statement
   b. Ini prevent SQL injection attack

3. Data yang diambil dari database:
   a. id_admin: ID unik admin
   b. username: Username admin
   c. password_hash: Password yang sudah di-hash
   d. email: Email admin
   e. status: Status admin (Aktif/Tidak Aktif)
   f. failed_login_attempts: Jumlah failed login attempts
   g. locked_until: Timestamp kapan account di-unlock (jika terkunci)

4. Hasil query:
   a. Jika admin ditemukan (1 row): Lanjut ke step berikutnya
   b. Jika admin tidak ditemukan (0 rows): Handle failed login

Jika admin tidak ditemukan:
1. Increment failed login counter untuk IP address ini
2. Log login attempt dengan status FAILED
3. Tampilkan error response dengan generic message "Username atau password salah"
4. JANGAN tampilkan error spesifik seperti "Username tidak ditemukan"
5. Alasan menggunakan generic error: Untuk tidak memberikan informasi kepada attacker apakah username ada atau tidak

### 3.13 Langkah 12: Server Cek Account Lockout

Setelah admin ditemukan, server cek apakah account sedang di-lock:

1. Check field locked_until di database
2. Jika locked_until tidak NULL dan masih belum waktunya expired:
   a. Account masih dalam kondisi locked
   b. Tampilkan error "Account terkunci. Coba lagi nanti"
   c. Hentikan proses login
   d. Jangan melakukan password verification

3. Jika locked_until sudah expired atau NULL:
   a. Account tidak terkunci
   b. Lanjut ke step berikutnya

Account lockout mechanism ini untuk mencegah brute force attack. Setelah N failed attempts,
account akan di-lock sementara sehingga attacker tidak bisa mencoba terus-menerus.

### 3.14 Langkah 13: Server Ambil Password Hash

Server mengambil password hash yang tersimpan di database untuk admin tersebut:

1. Password hash adalah password yang sudah di-hash dengan algoritma bcrypt
2. Password hash ini TIDAK bisa di-reverse ke password asli (one-way function)
3. Yang disimpan di database adalah HASH, BUKAN password plain text

Mengapa menggunakan hash bukan plain text?
1. Jika database di-hack, attacker tidak bisa langsung tahu password asli
2. Attacker hanya tahu password hash, yang tidak bisa di-reverse
3. Attacker butuh brute force semua kemungkinan password (sangat lama dengan bcrypt)

### 3.15 Langkah 14: Server Verifikasi Password

Server membandingkan password yang dimasukkan admin dengan password hash di database:

1. Ambil password plain text dari request (yang diketik admin)
2. Ambil password_hash dari database
3. Gunakan fungsi bcrypt verify untuk membandingkan:
   a. Fungsi ini akan hash password plain text dengan salt yang sama dari password_hash
   b. Bandingkan hasil hash dengan password_hash di database
   c. Return true jika match, false jika tidak match

Proses verifikasi bcrypt:
1. Password hash di database sudah include salt di dalamnya
2. Bcrypt extract salt dari hash tersebut
3. Bcrypt hash password input dengan salt yang di-extract
4. Bcrypt bandingkan hasil dengan password hash di database
5. Jika sama, password benar

Hasil verifikasi:
1. Jika password benar (match):
   a. Lanjut ke step berikutnya
   b. Reset failed login counter

2. Jika password salah (tidak match):
   a. Increment failed_login_attempts counter
   b. Check apakah failed_login_attempts sudah mencapai threshold (5 attempts)
   c. Jika sudah 5 attempts, lock account sampai 15 menit
   d. Log login attempt dengan status FAILED
   e. Return error response dengan generic message "Username atau password salah"
   f. Hentikan proses login

### 3.16 Langkah 15: Server Reset Failed Login Counter

Jika password benar, server melakukan reset untuk persiapan session baru:

1. Update failed_login_attempts menjadi 0 (reset counter)
2. Update locked_until menjadi NULL (unlock account jika sebelumnya terkunci)
3. Tujuan: Memastikan counter bersih untuk login attempt berikutnya

### 3.17 Langkah 16: Server Generate Session ID

Server generate session ID yang unik untuk admin yang baru login:

1. Session ID adalah string random yang unik dan tidak predictable
2. Panjang Session ID minimum 32 karakter
3. Menggunakan cryptographically secure random generator
4. Session ID harus unique di antara semua session yang aktif
5. Contoh Session ID: "4e6a5b3c2d1f8a9e7b6c5d4e3f2a1b0c9d8e7f6a5b4c3d2e1f0a9b8c7d6e5f"

### 3.18 Langkah 17: Server Buat Session Data

Server membuat session data yang akan disimpan untuk tracking dan validation:

1. Session data berisi informasi lengkap tentang session admin:
   a. session_id: ID session yang unik
   b. admin_id: ID admin yang login
   c. username: Username admin yang login
   d. email: Email admin
   e. ip_address: IP address dari mana admin login
   f. user_agent: User agent string dari browser (untuk browser identification)
   g. created_at: Timestamp saat session dibuat
   h. last_activity: Timestamp activity terakhir (awalnya sama dengan created_at)
   i. expires_at: Timestamp saat session akan expire
   j. remember_me: Boolean apakah admin memilih "Remember Me"

2. Session lifetime:
   a. Jika remember_me = false (default):
      - Idle timeout: 30 menit (logout otomatis jika tidak aktif 30 menit)
      - Absolute timeout: 8 jam (logout otomatis setelah 8 jam sejak login)

   b. Jika remember_me = true:
      - Absolute timeout: 30 hari (session lama, persistent)
      - Idle timeout tetap 30 menit

### 3.19 Langkah 18: Server Simpan Session ke Storage

Server menyimpan session data ke session storage (Redis atau Database):

1. Storage di Redis (Recommended untuk performance):
   a. Key: "session:{session_id}"
   b. Value: JSON string berisi session data lengkap
   c. TTL (Time To Live): Set sesuai dengan expires_at
   d. Contoh: SET session:4e6a5b3c2d1f8a9e7b6c5d4e3f2a1b0c "{...session_data...}" EX 1800
   e. Redis akan otomatis delete key setelah TTL expired

2. Atau storage di Database:
   a. INSERT ke tabel sessions dengan semua session data
   b. Database akan handle TTL dengan background job yang menghapus expired sessions
   c. Background job jalankan setiap 5 menit atau 1 jam

Alasan menyimpan session di server:
1. Keamanan: Data session disimpan di server, client tidak bisa manipulasi
2. Session invalidation: Saat logout, bisa langsung delete session dari storage
3. Audit trail: Server bisa track semua session yang aktif

### 3.20 Langkah 19: Server Update Login History

Server mencatat login attempt ke database untuk audit dan security monitoring:

1. INSERT ke tabel login_history dengan data:
   a. admin_id: ID admin yang login
   b. username: Username admin
   c. ip_address: IP address dari mana login terjadi
   d. user_agent: User agent string (OS, browser type, versi)
   e. login_time: Timestamp saat login terjadi
   f. status: "SUCCESS"
   g. device_info: Informasi device (extracting dari user_agent)

2. UPDATE admin table:
   a. last_login: Timestamp saat ini (untuk track kapan admin terakhir login)
   b. last_login_ip: IP address login terbaru

Login history ini penting untuk:
1. Audit trail: Tracking siapa login kapan dari IP berapa
2. Security monitoring: Detect unusual login patterns
3. Compliance: For regulatory requirements

### 3.21 Langkah 20: Server Generate Session Cookie

Server membuat HTTP cookie yang akan dikirim ke browser dan disimpan di client:

1. Cookie attributes:
   a. Name: "ADMIN_SESSION"
   b. Value: Session ID yang telah di-generate
   c. Domain: Domain aplikasi (contoh: domain.com)
   d. Path: "/" (accessible di semua halaman di domain)
   e. Secure: true (hanya dikirim via HTTPS)
   f. HttpOnly: true (tidak accessible via JavaScript)
   g. SameSite: "Strict" (prevent CSRF attack dari situs lain)
   h. Max-Age atau Expires: sesuai dengan session duration

2. Penjelasan cookie attributes:
   a. Secure flag: Cookie hanya dikirim via HTTPS, tidak pernah via HTTP plain text
   b. HttpOnly flag: JavaScript code (termasuk malicious script) tidak bisa access cookie
      - Ini mengurangi XSS (Cross-Site Scripting) attack vulnerability
   c. SameSite flag: Browser tidak akan include cookie jika request berasal dari website lain
      - Ini prevent CSRF (Cross-Site Request Forgery) attack

### 3.22 Langkah 21: Server Kirim Response Login Sukses

Server mengirimkan response ke browser dengan status success:

1. HTTP Status Code: 200 OK
2. Response Headers:
   a. Set-Cookie: Berisi session cookie yang telah di-generate dengan semua attributes
   b. Content-Type: application/json

3. Response Body (JSON):
   a. status: "success"
   b. message: "Login berhasil"
   c. redirect_url: "/dashboard" (URL untuk redirect browser)
   d. username: Username admin (untuk display di UI)
   e. email: Email admin (optional untuk display)

Contoh response:
```
HTTP/1.1 200 OK
Set-Cookie: ADMIN_SESSION=4e6a5b3c2d1f8a9e7b6c5d4e3f2a1b0c; Domain=domain.com; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=1800

{
  "status": "success",
  "message": "Login berhasil",
  "redirect_url": "/dashboard",
  "username": "admin1",
  "email": "admin1@example.com"
}
```

### 3.23 Langkah 22: Browser Menerima Response

Browser menerima response dari server dan melakukan proses:

1. Menerima Set-Cookie header
   a. Browser melihat Set-Cookie header di response
   b. Browser simpan session cookie ke cookie storage
   c. Cookie akan otomatis dikirim ke server di setiap request berikutnya ke domain yang sama

2. Parse response body JSON
   a. JavaScript parse response JSON
   b. Extract status, message, redirect_url
   c. Check apakah status = "success"

3. Tampilkan success message (optional)
   a. Show toast notification atau snackbar "Login berhasil"
   b. Tampilkan nama admin di UI

4. Redirect ke dashboard
   a. JavaScript redirect browser ke redirect_url yang diberikan server (/dashboard)
   b. Browser navigate ke halaman dashboard

### 3.24 Langkah 23: Browser Request Dashboard Page

1. Browser membuat request HTTP GET ke /dashboard
2. Sertakan session cookie di request headers
3. Request dikirim ke server

### 3.25 Langkah 24: Server Validasi Session untuk Dashboard Page

1. Server menerima request ke /dashboard
2. Server extract session ID dari cookie
3. Server query session dari storage
4. Server validasi:
   a. Session exist di storage
   b. Session belum expired
   c. IP address sama (security check)
   d. User agent sama atau similar (security check)

5. Jika validasi lulus:
   a. Session valid
   b. Admin authenticated
   c. Server render dashboard page

6. Jika validasi gagal:
   a. Delete session cookie dari browser
   b. Redirect ke login page
   c. Tampilkan message "Session expired, please login again"

### 3.26 Langkah 25: Server Update Last Activity

Saat setiap request ke halaman yang protected:

1. Server update timestamp last_activity di session storage
2. Tujuan: Untuk idle timeout tracking
3. Jika admin tidak aktif 30 menit, session otomatis expired

### 3.27 Langkah 26: Admin Berhasil Login dan Akses Dashboard

1. Browser menampilkan dashboard page
2. Admin dapat melihat dashboard dengan data yang tepat
3. Session tetap valid dan aktif
4. Admin dapat menggunakan sistem untuk manage pesanan, produk, dll
5. Session akan expire jika:
   a. Admin logout manually
   b. Idle 30 menit tanpa activity
   c. Sudah 8 jam sejak login

---

## 4. Proses Login Aplikasi Mobile Flutter

### 4.1 Alur Login Mobile Flutter Secara Keseluruhan

Proses login mobile Flutter serupa dengan web, namun dengan perbedaan penting:
1. Menggunakan JWT token sebagai authentication method (bukan session cookie)
2. Token disimpan di secure storage di device
3. Token di-attach ke setiap API request di Authorization header
4. Auto-login mechanism saat aplikasi dibuka

### 4.2 Langkah 1: Admin Membuka Aplikasi Flutter

1. Admin tap icon aplikasi R.R Hijab Admin di home screen
2. Operating system (Android atau iOS) launch aplikasi
3. Aplikasi melakukan initialization:
   a. Load semua packages dan dependencies
   b. Initialize database connections
   c. Load configuration dari assets atau server
   d. Check local storage untuk data yang sudah disimpan sebelumnya

### 4.3 Langkah 2: Aplikasi Cek Auto-login

Aplikasi melakukan cek untuk auto-login jika ada token yang belum expired:

1. Aplikasi query secure storage untuk mencari token tersimpan
   a. Key yang dicari: "admin_auth_token"
   b. Secure storage adalah encrypted storage di device

2. Hasil query:
   a. Jika token ditemukan:
      - Aplikasi lanjut ke langkah 3
      - Coba validate token dengan server
   b. Jika token tidak ditemukan:
      - Aplikasi navigate ke login screen
      - Admin harus login

### 4.4 Langkah 3: Aplikasi Validasi Token dengan Server

Aplikasi mengirim request ke server untuk validate token yang tersimpan:

1. Aplikasi kirim HTTP request ke server:
   a. Method: GET
   b. Endpoint: /api/admin/profile atau /api/admin/me
   c. Headers include Authorization header dengan token
   d. Format: Authorization: Bearer {token}

2. Server validasi token:
   a. Extract token dari Authorization header
   b. Validate signature token (memastikan token tidak di-tamper)
   c. Check apakah token sudah expired
   d. Query database untuk admin dengan ID dari token
   e. Return admin profile data jika valid

3. Hasil validasi:
   a. Jika token valid (response 200):
      - Load admin profile data
      - Navigate ke dashboard screen
      - Admin tidak perlu login lagi (auto-login)
   b. Jika token invalid (response 401):
      - Delete token dari secure storage
      - Navigate ke login screen
      - Admin harus login ulang

### 4.5 Langkah 4: Aplikasi Tampilkan Login Screen

Jika auto-login gagal atau token tidak ada, aplikasi tampilkan login screen:

1. Aplikasi navigate ke login screen
2. Login screen menampilkan:
   a. Text input field untuk username
   b. Text input field untuk password (type password)
   c. Tombol "Login" (initially enabled)
   d. Tombol "Forgot Password" (optional)
   e. Checkbox "Remember Me" (optional)
   f. Loading indicator (initially hidden)

3. Screen initialization:
   a. Password field obscured (password tidak terlihat)
   b. Input fields kosong (ready untuk input)
   c. Error message area (initially empty)

### 4.6 Langkah 5: Admin Masukkan Credentials Mobile

1. Admin memasukkan username di field username
   a. Username text field menerima input
   b. Keyboard otomatis show sesuai input type (text keyboard)
   c. Input text bersifat case-insensitive atau case-sensitive sesuai design

2. Admin memasukkan password di field password
   a. Password field menerima input
   b. Password tidak terlihat di layar (hanya dots atau bullets)
   c. Admin bisa tap icon "show/hide password" untuk toggle visibility

3. Admin optional check "Remember Me"
   a. Checkbox untuk persistent login
   b. Jika di-check, session/token akan lebih lama

4. Admin mengklik tombol "Login"

### 4.7 Langkah 6: Aplikasi Mobile Lakukan Client-Side Validation

Sebelum mengirim request ke server, aplikasi validasi di sisi client:

1. Validasi username:
   a. Cek apakah username tidak kosong
   b. Cek panjang username (minimal 3 karakter)
   c. Cek format username (alphanumeric dan underscore only)
   d. Jika invalid, tampilkan error message di UI

2. Validasi password:
   a. Cek apakah password tidak kosong
   b. Cek panjang password (minimal 8 karakter)
   c. Jika invalid, tampilkan error message di UI

3. Jika ada validasi yang gagal:
   a. Tampilkan snackbar atau dialog dengan error message
   b. Disable tombol login
   c. Jangan kirim request ke server

4. Jika semua validasi lolos:
   a. Enable tombol login
   b. Lanjut ke langkah berikutnya

### 4.8 Langkah 7: Aplikasi Mobile Tampilkan Loading Indicator

1. Tampilkan loading dialog atau progress bar
2. Disable tombol login sehingga tidak bisa di-tap multiple times
3. Tampilkan message "Authenticating..." atau "Logging in..."

### 4.9 Langkah 8: Aplikasi Mobile Kirim Request Login ke Server

Aplikasi membuat HTTP POST request ke server backend:

1. Endpoint: https://api.domain.com/api/admin/login
2. Method: POST
3. Headers:
   a. Content-Type: application/json
   b. User-Agent: Informasi aplikasi dan device
      - Format: AdminApp/1.0 (Android 12; Samsung Galaxy S21)
   c. X-Device-ID: Device ID unik (untuk tracking device)
   d. X-App-Version: Versi aplikasi (untuk compatibility checking)

4. Request Body (JSON):
   a. username: Username yang diinput admin
   b. password: Password yang diinput admin (plain text)
   c. remember_me: Boolean apakah admin memilih "Remember Me"
   d. device_token: Firebase device token (untuk push notifications)
   e. device_name: Nama device (contoh: "Samsung Galaxy S21")
   f. device_os: Tipe OS (Android atau iOS)
   g. app_version: Versi aplikasi

5. Request Configuration:
   a. Timeout: 30 detik
   b. HTTPS validation: Validate SSL certificate
   c. Retry policy: Retry jika network error (max 2 retries)

6. Request dikirim via HTTPS (encrypted in transit)

### 4.10 Langkah 9: Server Terima Request dari Mobile

1. Server menerima HTTP POST request dari aplikasi mobile
2. Server extract data dari request:
   a. Username, password
   b. Remember me flag
   c. Device token, device name, device OS
   d. Request headers (User-Agent, X-Device-ID, dll)

3. Server melakukan initial checks seperti di web login

### 4.11 Langkah 10-15: Server Proses Login dari Mobile

Proses di server sama seperti login dari web (langkah 8-13 di web login):

1. Validasi CSRF (tidak ada untuk mobile, HTTPS validation sudah cukup)
2. Validasi input username dan password
3. Cek rate limiting (brute force protection)
4. Query database untuk username
5. Cek account lockout status
6. Verifikasi password dengan bcrypt

Perbedaan untuk mobile:
1. Tidak menggunakan session cookie (stateless)
2. Menggunakan JWT token sebagai authentication method
3. Simpan device_token di database untuk push notifications
4. Simpan device info (OS, device ID) untuk security tracking

### 4.12 Langkah 16: Server Generate JWT Token untuk Mobile

Untuk mobile, server menggunakan JWT (JSON Web Token) alih-alih session cookie:

1. Definisi JWT Token:
   a. JWT adalah token terenkripsi yang berisi informasi admin
   b. Format: Header.Payload.Signature (3 parts separated by dots)
   c. Token bersifat stateless (server tidak perlu store state)
   d. Token dapat di-validate oleh server menggunakan secret key

2. Struktur JWT:
   a. Header (Part 1):
      - Berisi informasi algoritma (HS256, RS256, dll)
      - Berisi token type (JWT)
      - Di-encode dalam Base64
   b. Payload (Part 2):
      - Berisi data/claims tentang admin
      - Contoh: admin_id, username, email, issued_at, expiration
      - Di-encode dalam Base64
   c. Signature (Part 3):
      - Dibuat dengan: HMAC(Header + Payload + Secret Key)
      - Untuk verify bahwa token belum di-tamper

3. JWT Generation:
   a. Server membuat payload berisi admin info:
      - admin_id: ID admin
      - username: Username admin
      - email: Email admin
      - iat (issued at): Timestamp saat token dibuat
      - exp (expiration): Timestamp saat token expire
      - iss (issuer): "R.R Hijab Admin"

   b. Server encode Header dan Payload dalam Base64
   c. Server sign dengan Secret Key menggunakan algoritma HS256
   d. Hasil: JWT token yang siap dikirim ke mobile

4. Token Expiration:
   a. Jika remember_me = false:
      - Token expire dalam 8 jam
   b. Jika remember_me = true:
      - Token expire dalam 30 hari

5. Token Security:
   a. Secret Key disimpan aman di server (environment variable atau key management service)
   b. Secret Key tidak pernah dikirim ke client
   c. Mobile tidak bisa forge token karena tidak punya secret key

### 4.13 Langkah 17: Server Generate Refresh Token (Optional)

Untuk enhanced security, server bisa generate refresh token:

1. Refresh Token:
   a. Token terpisah yang hanya untuk refresh access token
   b. Durasi lebih panjang (contoh: 30 hari)
   c. Jika access token expire, mobile bisa use refresh token untuk get token baru
   d. Tanpa perlu login ulang

2. Implementasi:
   a. Generate refresh token saat login
   b. Simpan refresh token di secure storage di mobile
   c. Saat access token expire, send refresh token ke server
   d. Server validate refresh token dan generate access token baru
   e. Mobile mendapat access token baru tanpa perlu login lagi

### 4.14 Langkah 18: Server Simpan Device Info ke Database

Server menyimpan informasi device untuk tracking dan security:

1. Update admin table atau create device_sessions table:
   a. device_token: Firebase token untuk push notifications
   b. device_name: Nama device (contoh: Samsung Galaxy S21)
   c. device_os: Tipe OS (Android atau iOS)
   d. device_id: Unique device identifier
   e. app_version: Versi aplikasi
   f. last_login: Timestamp login terakhir
   g. is_active: Boolean apakah device session masih aktif

2. Tujuan menyimpan device info:
   a. Push notifications: Send notification ke device tertentu
   b. Security tracking: Monitor device mana yang login
   c. Multi-device support: Admin bisa login dari multiple devices
   d. Device management: Admin bisa logout dari device lain remotely

### 4.15 Langkah 19: Server Kirim Response Login Sukses ke Mobile

Server mengirimkan response ke aplikasi mobile dengan JWT token:

1. HTTP Status Code: 200 OK
2. Response Body (JSON):
   a. status: "success"
   b. message: "Login berhasil"
   c. data:
      - token: JWT token untuk authentication
      - admin_id: ID admin
      - username: Username admin
      - email: Email admin
      - expires_in: Waktu token expire (dalam detik)
      - token_type: "Bearer"
      - refresh_token: Refresh token (optional)

Contoh response:
```json
{
  "status": "success",
  "message": "Login berhasil",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhZG1pbl9pZCI6MSwiIm...",
    "admin_id": 1,
    "username": "admin1",
    "email": "admin1@example.com",
    "expires_in": 28800,
    "token_type": "Bearer",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyZWZyZXNoX3Rva2VuIj..."
  }
}
```

### 4.16 Langkah 20: Aplikasi Mobile Terima Response

Aplikasi menerima response dari server:

1. Check HTTP status code:
   a. 200 OK: Login sukses
   b. 401 Unauthorized: Username atau password salah
   c. 429 Too Many Requests: Rate limit exceeded
   d. 5xx: Server error

2. Parse response JSON:
   a. Extract status, message
   b. Extract token dan user data dari response.data
   c. Check apakah status = "success"

3. Jika status success:
   a. Lanjut ke step berikutnya (simpan token)
   b. Close loading dialog

4. Jika status error:
   a. Close loading dialog
   b. Tampilkan error message ke UI
   c. Enable tombol login
   d. Jangan lanjutkan

### 4.17 Langkah 21: Aplikasi Mobile Simpan JWT Token ke Secure Storage

Aplikasi menyimpan JWT token ke secure storage (Keystore di Android, Keychain di iOS):

1. Secure storage locations:
   a. Android: Android Keystore (encrypted)
   b. iOS: iOS Keychain (encrypted)
   c. Data di-encrypt dan hanya accessible oleh aplikasi yang punya credentials

2. Data yang disimpan:
   a. Key: "admin_auth_token"
   b. Value: JWT token yang diterima
   c. TTL: Expire sesuai token expiration time

3. Tujuan secure storage:
   a. Jangan simpan token di plain text
   b. Protect dari unauthorized access oleh aplikasi lain
   c. Protect dari reverse engineering

### 4.18 Langkah 22: Aplikasi Mobile Simpan User Info ke Local Storage

Aplikasi menyimpan informasi admin ke local storage untuk quick access:

1. Local storage (bukan secure):
   a. Menggunakan SharedPreferences atau similar
   b. Data tidak ter-encrypt (tidak untuk sensitive data)

2. Data yang disimpan:
   a. admin_id: ID admin
   b. admin_username: Username admin
   c. admin_email: Email admin
   d. token_expires_at: Timestamp saat token expire
   e. remember_me: Boolean apakah "Remember Me" di-check

3. Tujuan local storage:
   a. Quick access tanpa query database
   b. Display nama admin di UI
   c. Check token expiration tanpa decode token
   d. Resume data saat aplikasi di-minimize dan di-maximize

### 4.19 Langkah 23: Aplikasi Mobile Dismiss Loading

1. Close loading dialog
2. Hide loading indicator
3. Enable tombol login
4. Clear password text field (optional)
5. Show success message (optional) "Login berhasil"

### 4.20 Langkah 24: Aplikasi Mobile Redirect ke Dashboard

Aplikasi melakukan navigation ke dashboard screen:

1. Navigation method: Push replacement (destroy login screen, push dashboard)
2. Dashboard screen akan:
   a. Read JWT token dari secure storage
   b. Use token untuk authenticate API requests
   c. Load admin data dan dashboard content
   d. Display dashboard UI

### 4.21 Langkah 25: Dashboard Validasi Token

Dashboard screen atau main screen validasi token:

1. Read token dari secure storage
2. Decode token payload (tanpa verify signature, hanya read)
3. Check apakah token sudah expired:
   a. Decode timestamp exp (expiration)
   b. Compare dengan current timestamp
   c. Jika exp <= now: Token expired, navigate ke login
   d. Jika exp > now: Token valid, proceed

4. Token validation setiap kali aplikasi buka atau resume dari background

### 4.22 Langkah 26: Admin Berhasil Login dan Akses Dashboard

1. Dashboard screen menampilkan content
2. Admin dapat melihat data dan melakukan aksi
3. Setiap API request akan include JWT token di Authorization header
4. Backend validate token di setiap request
5. Session/token akan expire jika:
   a. Admin logout manually
   b. Token sudah expired by time
   c. Admin revoke session dari web admin panel

---

## 5. Enkripsi dan Hashing Password

### 5.1 Perbedian Antara Encryption dan Hashing

#### 5.1.1 Encryption (Enkripsi)

1. Definisi: Proses mengubah data plain text menjadi cipher text yang tidak readable menggunakan encryption key

2. Karakteristik:
   a. Reversible: Data yang ter-encrypt bisa di-decrypt kembali ke plain text jika punya key
   b. Memerlukan key: Decryption memerlukan encryption key yang sama
   c. Deterministic: Input yang sama akan selalu menghasilkan output yang sama (jika key sama)

3. Use cases:
   a. Encrypt file atau database fields yang sensitive dan perlu di-recover
   b. Encrypt komunikasi (SSL/TLS)
   c. Encrypt sensitive data seperti nomor kartu kredit

4. Algoritma umum:
   a. AES (Advanced Encryption Standard): Symmetric encryption, sangat aman
   b. RSA: Asymmetric encryption, untuk key exchange
   c. DES: Symmetric encryption, sudah deprecated

#### 5.1.2 Hashing (One-way Encryption)

1. Definisi: Proses mengubah data plain text menjadi fixed-length string (hash) menggunakan hash function

2. Karakteristik:
   a. Non-reversible: Hash tidak bisa di-reverse ke plain text
   b. Tidak memerlukan key: Hash dapat di-verify tanpa key
   c. Deterministic: Input yang sama akan selalu menghasilkan output hash yang sama
   d. Collision resistance: Sangat sulit menemukan 2 input yang berbeda dengan hash yang sama

3. Use cases:
   a. Password storage: Hash password di database
   b. Data integrity verification: Verify data belum di-tamper
   c. Digital signatures: Sign data secara digital

4. Algoritma umum untuk password:
   a. bcrypt: Recommended, slow hashing, dengan salt
   b. Argon2: Modern, memory-hard, resistant to attacks
   c. scrypt: Memory-hard hashing
   d. SHA-256, SHA-512: General purpose, NOT recommended untuk password

#### 5.1.3 Kesimpulan Perbedaan

| Aspek | Encryption | Hashing |
|-------|-----------|---------|
| Reversible | Ya | Tidak |
| Memerlukan Key | Ya | Tidak |
| Use Case | Decrypt data | Verify password |
| Password Storage | Tidak | Ya |
| Speed | Cepat | Slow (untuk password) |

### 5.2 Mengapa Password Harus Di-HASH Bukan Di-ENCRYPT

1. Password tidak perlu di-recover: Kami tidak perlu tahu password asli, hanya perlu verify apakah password yang diinput match dengan password asli

2. Hash adalah one-way: Bahkan jika database di-hack, attacker tidak bisa recover password asli dari hash

3. Brute force resistance: Hash yang baik (seperti bcrypt) deliberately slow sehingga brute force attack menjadi tidak praktis

4. No key management: Hash tidak memerlukan key management (tidak perlu jaga encryption key)

5. Standardization: Password hashing adalah standard best practice di industri

### 5.3 Algoritma Hashing Password yang Aman

#### 5.3.1 Bcrypt (Recommended)

1. Definisi: Hashing algorithm yang didesain khusus untuk password hashing, pemenang Password Hashing Competition 2013

2. Kelebihan bcrypt:
   a. Slow hashing: Deliberately lambat (0.1-0.5 detik per hash) untuk mencegah brute force
   b. Salt included: Setiap hash automatically include unique salt
   c. Adaptive cost: Cost factor dapat di-adjust seiring kemampuan hardware meningkat
   d. Widely adopted: Banyak digunakan dan well-tested di production
   e. Proven secure: Tidak ada known vulnerability yang significant

3. Cost factor:
   a. Menentukan berapa banyak iterations untuk hashing
   b. Default: 10 (recommended untuk 2024)
   c. Range: 4-31 (lebih tinggi = lebih lambat)
   d. Semakin tinggi cost, semakin resistant terhadap brute force
   e. Trade-off antara security dan performance

4. Contoh bcrypt hash:
   a. Password: "MyPassword123"
   b. Hash: "$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUxWXoDi8ByMK5FzFm"
   c. Format breakdown:
      - "$2b$" = bcrypt algorithm identifier
      - "10" = cost factor
      - "N9qo8uLOickgx2ZMRZoMye" = salt (22 characters)
      - "IjZAgcg7b3XeKeUxWXoDi8ByMK5FzFm" = hash (31 characters)

5. Karakteristik:
   a. Output fixed length: Always 60 characters
   b. Salt included: Setiap password punya salt yang berbeda
   c. Deterministic: Same password + same salt = same hash (for verification)

#### 5.3.2 Argon2 (Modern Alternative)

1. Definisi: Password hashing algorithm yang lebih modern, pemenang Password Hashing Competition 2015

2. Kelebihan Argon2:
   a. Memory-hard: Memerlukan significant memory untuk compute hash
   b. Time-hard: Memerlukan waktu yang lama
   c. Resistant to attacks: Resistant terhadap GPU dan ASIC attacks
   d. Tunable: Dapat di-tune untuk different scenarios (time, memory, parallelism)

3. Kekurangan Argon2:
   a. Lebih kompleks: Lebih kompleks untuk implementasi
   b. Library support: Library support belum sebanyak bcrypt
   c. Adoption: Belum se-widely adopted seperti bcrypt

4. Kapan gunakan Argon2:
   a. Jika ada requirement khusus untuk memory-hard hashing
   b. Jika ingin future-proofing dengan algorithm yang lebih modern
   c. Jika performance bukan critical issue

#### 5.3.3 SHA-256 atau SHA-512 (NOT RECOMMENDED untuk Password)

1. Definisi: General-purpose cryptographic hash function

2. Kekurangan untuk password:
   a. Fast hashing: Hashing sangat cepat (microseconds), memudahkan attacker untuk brute force
   b. Tidak include salt: Vulnerable terhadap rainbow table attacks
   c. Tidak adaptive: Tidak bisa adjust difficulty seiring hardware berkembang
   d. Designed untuk: Data integrity verification, bukan password storage

3. Kesimpulan: JANGAN gunakan SHA-256 atau SHA-512 untuk password hashing

### 5.4 Proses Hashing Password saat Admin Registrasi atau Buat Akun

#### 5.4.1 Langkah 1: Super Admin Masukkan Password Baru

1. Super admin memasukkan password untuk admin baru melalui form
2. Password ini adalah temporary password yang akan diberikan ke admin baru
3. Password dikirim via HTTPS (encrypted in transit)

#### 5.4.2 Langkah 2: Server Validasi Format Password

Server melakukan validasi terhadap format password:

1. Validasi panjang:
   a. Minimal 8 karakter
   b. Maksimal 128 karakter
   c. Jika invalid length, return error

2. Validasi character requirements:
   a. Harus mengandung huruf besar (A-Z): Minimal 1
   b. Harus mengandung huruf kecil (a-z): Minimal 1
   c. Harus mengandung angka (0-9): Minimal 1
   d. Harus mengandung special character (!@#$%^&*): Minimal 1
   e. Jika ada requirement yang tidak terpenuhi, return error

3. Password policy tujuan:
   a. Mencegah weak passwords yang mudah di-crack
   b. Ensure password complexity yang sufficient
   c. Industry standard: OWASP, NIST recommendations

4. Contoh password yang valid:
   a. "SecurePass123!" - OK (uppercase, lowercase, digit, special char)
   b. "AdminPass@2024" - OK
   c. "123456" - NOT OK (hanya digit)
   d. "password123" - NOT OK (tidak ada uppercase dan special char)

#### 5.4.3 Langkah 3: Server Generate Salt

Server generate salt yang unik untuk password hashing ini:

1. Salt adalah random string yang akan dikombinasikan dengan password sebelum hashing

2. Karakteristik salt:
   a. Panjang minimum: 16 karakter (bcrypt internally handle salt, aplikasi tidak perlu atur)
   b. Cryptographically random: Menggunakan secure random generator, bukan simple random
   c. Unique untuk setiap password: Setiap password hash punya salt yang berbeda

3. Tujuan salt:
   a. Prevent rainbow table attacks: Hash dari password yang sama akan berbeda jika salt berbeda
   b. Unique hashes: 2 admin dengan password sama akan punya hash yang berbeda
   c. Increase security: Membuat hash cracking lebih sulit

4. Contoh:
   a. Admin 1 password: "SecurePass123!" + salt1 = hash1
   b. Admin 2 password: "SecurePass123!" + salt2 = hash2
   c. hash1 != hash2 meskipun password sama

#### 5.4.4 Langkah 4: Server Hash Password dengan Bcrypt

Server melakukan hashing password menggunakan bcrypt:

1. Input ke bcrypt:
   a. Password plain text: "SecurePass123!"
   b. Cost factor: 10 (atau configurable)

2. Proses bcrypt:
   a. Generate salt secara internal
   b. Lakukan iterations sebanyak cost factor (2^10 = 1024 iterations)
   c. Kombinasikan password dengan salt
   d. Hash dengan Blowfish algorithm
   e. Output: Fixed-length hash (60 characters)

3. Waktu hashing:
   a. Dengan cost factor 10: Sekitar 100-200 milliseconds per password
   b. Deliberate slow untuk prevent brute force
   c. Trade-off: Security vs. Performance

4. Output dari bcrypt:
   a. Format: "$2b$10$...60 characters total..."
   b. Include algorithm identifier, cost factor, salt, dan hash
   c. Bisa di-verify tanpa additional salt storage

#### 5.4.5 Langkah 5: Server Simpan Password Hash ke Database

Server menyimpan password hash ke database, BUKAN password plain text:

1. Data yang disimpan:
   a. id_admin: ID unique untuk admin
   b. username: Username admin
   c. email: Email admin
   d. password_hash: Password hash yang telah di-generate oleh bcrypt
   e. status: Status admin ("Aktif")
   f. created_at: Timestamp saat admin dibuat
   g. created_by: ID admin yang membuat admin baru

2. Yang TIDAK disimpan:
   a. Password plain text: JANGAN simpan
   b. Password encryption key: TIDAK ada encryption, hanya hashing

3. Keamanan database:
   a. Password plain text HANYA ada di memory saat proses hashing
   b. Setelah hash selesai, password plain text di-clear dari memory
   c. Di database hanya ada hash, attacker tidak bisa recover password asli

#### 5.4.6 Langkah 6: Server Kirim Email ke Admin Baru

Server mengirimkan email ke admin baru dengan informasi akun:

1. Alternatif 1: Kirim temporary password
   a. Subject: "Akun Admin R.R Hijab Telah Dibuat"
   b. Body:
      - Greeting dengan nama admin
      - Username untuk login
      - Temporary password yang sudah di-generate
      - Link untuk login
      - Instruksi untuk change password pada login pertama
   c. Catatan: Email tidak aman, jadi temporary password akan segera di-replace

2. Alternatif 2: Kirim magic link
   a. Subject: "Setup Akun Admin R.R Hijab"
   b. Body:
      - Greeting dengan nama admin
      - Link unique untuk setup password
      - Link expire dalam 24 jam
      - Instruksi untuk click link dan set password baru
   c. Lebih aman: Admin set password sendiri, tidak ada password dikirim via email

3. Pilihan yang disarankan:
   a. Alternatif 2 (magic link) lebih aman dan modern
   b. Admin tidak perlu change password saat login pertama
   c. Admin create password yang mereka inginkan

### 5.5 Proses Verifikasi Password saat Login

#### 5.5.1 Langkah 1: Terima Password Input dari Login Form

Admin memasukkan password di form login (web atau mobile).
Password dikirim via HTTPS (encrypted in transit).

#### 5.5.2 Langkah 2: Query Password Hash dari Database

Server mengambil password hash yang tersimpan untuk admin dengan username yang sesuai:

1. Query dari database:
   a. SELECT password_hash FROM admin WHERE username = ?
   b. Menggunakan parameterized query untuk prevent SQL injection

2. Data yang diambil:
   a. password_hash: Password hash yang tersimpan (format bcrypt)

#### 5.5.3 Langkah 3: Verifikasi Password dengan Bcrypt Compare

Server menggunakan fungsi bcrypt compare untuk membandingkan password:

1. Input ke bcrypt compare:
   a. password_plain: Password yang diinput admin (plain text)
   b. password_hash: Password hash dari database

2. Proses bcrypt compare:
   a. Extract salt dari password_hash di database
   b. Hash password_plain menggunakan salt yang di-extract
   c. Bandingkan hasil hash dengan password_hash di database
   d. Return true jika match, false jika tidak match

3. Keamanan bcrypt compare:
   a. Tidak reveal berapa karakter yang benar
   b. Timing attack resistant: Waktu compare sama regardless match atau tidak
   c. Constant-time comparison: Prevent timing attacks

#### 5.5.4 Langkah 4: Handle Hasil Verifikasi

Hasil dari bcrypt compare:

1. Jika password benar (match = true):
   a. Password verification passed
   b. Reset failed login counter
   c. Lanjutkan proses login (create session atau token)

2. Jika password salah (match = false):
   a. Increment failed_login_attempts counter
   b. Check apakah sudah mencapai threshold (5 attempts)
   c. Jika sudah 5 attempts, lock account
   d. Log login attempt dengan status FAILED
   e. Return error response dengan generic message "Username atau password salah"
   f. Hentikan proses login

### 5.6 Best Practices Password Hashing

1. Algoritma:
   a. Gunakan bcrypt atau Argon2
   b. JANGAN gunakan SHA-256, SHA-512, atau MD5 untuk password
   c. Review algoritma setiap 2-3 tahun (technology evolves)

2. Cost Factor (untuk bcrypt):
   a. Minimum: 10 (recommended untuk 2024)
   b. Update ke 12-14 saat hardware lebih cepat (setiap 2-3 tahun)
   c. Monitor hashing time, target 100-500ms per password

3. Salt:
   a. Setiap password harus punya unique salt
   b. Salt minimum 16 bytes
   c. Gunakan cryptographically secure random generator
   d. Bcrypt internally handle salt, tidak perlu manual

4. Storage:
   a. Jangan pernah simpan password plain text di database
   b. Jangan pernah log password (bahkan di error logs)
   c. Jangan pernah transmit password (kecuali via HTTPS)

5. Handling:
   a. Hash password di server side, bukan client side
   b. Clear password plain text dari memory setelah hashing
   c. Jangan cache password di local storage atau cookies

6. Security:
   a. Implement rate limiting untuk prevent brute force
   b. Implement account lockout setelah N failed attempts
   c. Notify admin saat ada suspicious login attempts
   d. Implement password reset mechanism yang aman

7. Compliance:
   a. Follow OWASP guidelines
   b. Follow NIST password guidelines
   c. Regular security audits

---

## 6. Session Management dan Token Authentication

### 6.1 Perbedaan Session vs Token Authentication

#### 6.1.1 Session-based Authentication (untuk Web)

1. Definisi: Authentication method yang menyimpan session state di server

2. Flow:
   a. Client (browser) login dengan username dan password
   b. Server validate credentials
   c. Server create session dan store session di server storage
   d. Server kirim session cookie ke browser
   e. Browser store session cookie
   f. Setiap request browser sertakan session cookie
   g. Server validate session dari cookie
   h. Saat logout, server delete session

3. Kelebihan session:
   a. Server-side control: Server can invalidate session anytime
   b. Secure: Session data di server, client tidak bisa manipulasi
   c. Instant logout: Session dapat langsung dihapus dari server
   d. Traditional: Well-known dan established pattern

4. Kekurangan session:
   a. Not scalable: Butuh session sharing antar servers (kompleks)
   b. Stateful: Server harus maintain session state
   c. Cookie dependency: Rely pada HTTP cookie (limited di mobile apps)
   d. CORS issues: CORS dapat complicated dengan session cookies

#### 6.1.2 Token-based Authentication (untuk Mobile dan API)

1. Definisi: Authentication method yang menggunakan token (biasanya JWT) tanpa server-side state

2. Flow:
   a. Client login dengan username dan password
   b. Server validate credentials
   c. Server generate JWT token
   d. Server send token ke client
   e. Client store token di local storage atau secure storage
   f. Setiap request client sertakan token di Authorization header
   g. Server validate token (verify signature, check expiration)
   h. Saat logout, client delete token dari local storage

3. Kelebihan token:
   a. Stateless: Server tidak perlu maintain state, scalable
   b. Cross-domain: Token dapat digunakan cross-domain
   c. Mobile friendly: Cocok untuk mobile apps dan APIs
   d. Scalable: Dapat scale horizontal tanpa session sharing

4. Kekurangan token:
   a. Cannot revoke instantly: Token tidak dapat di-revoke sebelum expire
   b. Token leakage: Jika token di-steal, attacker bisa akses
   c. Larger payload: Token size lebih besar dari session cookie
   d. Complex: Lebih kompleks untuk implement refresh token logic

#### 6.1.3 Kesimpulan Pilihan

1. Untuk Web Admin: Gunakan session-based (lebih secure)
2. Untuk Mobile App: Gunakan token-based (JWT) (stateless, scalable)
3. Untuk API: Gunakan token-based (JWT) (standard untuk REST APIs)

### 6.2 Session Management untuk Web Admin

#### 6.2.1 Session Storage Options

1. Redis (Recommended):
   a. In-memory data store
   b. Kecepatan: Microseconds latency
   c. TTL support: Automatic expiration
   d. Distributed: Dapat shared antar multiple servers
   e. Persistence: Optional persistence untuk recovery

2. Database (SQL atau NoSQL):
   a. Persistent storage
   b. Kecepatan: Milliseconds (slower than Redis)
   c. Scalable: Unlimited storage
   d. Reliable: Data persist di disk
   e. Cleanup: Perlu background job untuk delete expired sessions

3. In-memory (Not Recommended untuk Production):
   a. Application memory
   b. Kecepatan: Nanoseconds
   c. Kekurangan: Session tidak shared antar servers, data loss saat restart

### 6.2.2 Session Timeout Strategy

1. Idle Timeout:
   a. Definisi: Session expire jika tidak ada activity selama waktu tertentu
   b. Duration: 30 menit (typical)
   c. Implementation: Update last_activity timestamp setiap request
   d. Check: Saat receive request, check (current_time - last_activity) > idle_timeout
   e. Effect: Admin auto-logout jika idle 30 menit

2. Absolute Timeout:
   a. Definisi: Session expire setelah waktu tertentu sejak dibuat, regardless of activity
   b. Duration: 8 jam (typical)
   c. Implementation: Set expires_at = created_at + 8 hours
   d. Check: Saat receive request, check current_time > expires_at
   e. Effect: Admin must login lagi setelah 8 jam meskipun terus aktif

3. Combined Strategy (Recommended):
   a. Idle timeout: 30 menit (force logout jika tidak aktif)
   b. Absolute timeout: 8 jam (force logout setelah 8 jam)
   c. Behavior:
      - Admin dapat aktif terus selama di bawah 8 jam (session keep extending via idle timeout reset)
      - Admin auto-logout jika tidak aktif 30 menit
      - Admin must login ulang setelah 8 jam regardless of activity

#### 6.2.3 Session Validation di Setiap Request

Setiap kali admin membuat request (page navigation, API call, dll), server melakukan validation:

1. Extract session ID dari session cookie
2. Query session dari storage
3. Validate session existence:
   a. Session ada di storage?
   b. Jika tidak ada: Invalid session, logout admin
4. Validate session expiration:
   a. Idle timeout: (current_time - last_activity) <= idle_timeout?
   b. Absolute timeout: current_time < expires_at?
   c. Jika salah satu exceeded: Session expired, logout admin
5. Validate security properties:
   a. IP address sama? (optional, dapat false positive jika network change)
   b. User agent sama? (optional, dapat false positive jika browser update)
   c. Jika tidak match: Suspicious activity, log warning
6. Update last_activity:
   a. Update session.last_activity = current_time
   b. Untuk idle timeout tracking
7. Proceed:
   a. Semua validation lolos
   b. Admin authenticated
   c. Process request

### 6.3 JWT Token Management untuk Mobile

#### 6.3.1 JWT Token Structure

JWT terdiri dari 3 parts yang di-separate dengan dot (.):

1. Header (Part 1):
   a. Informasi tentang token
   b. Algoritma yang digunakan: HS256, RS256, PS256, dll
   c. Token type: "JWT"
   d. Di-encode dalam Base64URL format
   e. Contoh header: {"alg": "HS256", "typ": "JWT"}

2. Payload (Part 2):
   a. Data/claims tentang user
   b. Standard claims:
      - iss (issuer): Siapa yang issue token (contoh: "R.R Hijab Admin")
      - sub (subject): Subject dari token (contoh: admin ID)
      - aud (audience): Siapa yang bisa use token (contoh: "admin")
      - iat (issued at): Waktu token dibuat (Unix timestamp)
      - exp (expiration): Waktu token expire (Unix timestamp)
      - nbf (not before): Waktu token mulai valid (optional)
   c. Custom claims:
      - admin_id: ID admin
      - username: Username admin
      - email: Email admin
   d. Di-encode dalam Base64URL format

3. Signature (Part 3):
   a. Signature untuk verify token authenticity
   b. Dibuat dengan: HMAC(Header + Payload + Secret Key) untuk HS256
   c. Atau RSA signature untuk RS256
   d. Untuk verify token belum di-tamper

Contoh JWT Token:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJhZG1pbl9pZCI6MSwibmFtZSI6IkFkbWluIiwiaWF0IjoxNTE2MjM5MDIyfQ.
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

Breaking down:
1. Part 1 (Header): eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
2. Part 2 (Payload): eyJhZG1pbl9pZCI6MSwibmFtZSI6IkFkbWluIiwiaWF0IjoxNTE2MjM5MDIyfQ
3. Part 3 (Signature): SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c

#### 6.3.2 JWT Token Expiration

1. Access Token:
   a. Durasi: 8 jam (untuk regular login)
   b. Durasi: 30 hari (jika remember_me = true)
   c. Gunakan: Untuk authenticate API requests
   d. Expiration: Jika expire, admin harus login ulang

2. Refresh Token (Optional):
   a. Durasi: 30 hari atau lebih
   b. Gunakan: Untuk generate access token baru tanpa login ulang
   c. Storage: Disimpan di secure storage (sama seperti access token)
   d. Implementation:
      - Saat access token expire, mobile send refresh token ke server
      - Server validate refresh token dan generate access token baru
      - Mobile dapat lanjutkan bekerja tanpa need login lagi

#### 6.3.3 JWT Token Validation di Mobile

Setiap kali aplikasi buka atau resume, mobile melakukan validation:

1. Read token dari secure storage
2. Jika token tidak ada: Navigate ke login screen
3. Jika token ada:
   a. Decode token payload (Base64URL decode, tanpa verify signature)
   b. Extract exp (expiration timestamp)
   c. Compare dengan current timestamp
   d. Jika exp <= now: Token expired
      - Delete token dari secure storage
      - Navigate ke login screen
   e. Jika exp > now: Token valid
      - Auto-login (skip login screen)
      - Navigate ke dashboard
      - Token dapat digunakan untuk API requests

#### 6.3.4 JWT Token di Request Header

Setiap API request dari mobile harus include JWT token:

1. Header format:
   a. Key: "Authorization"
   b. Value: "Bearer {jwt_token}"
   c. Contoh: Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

2. Backend validation:
   a. Extract token dari Authorization header
   b. Verify token signature dengan secret key
   c. Check apakah token sudah expired
   d. Extract admin info dari token payload
   e. Jika valid: Process request
   f. Jika invalid: Return 401 Unauthorized

#### 6.3.5 JWT Token Refresh Flow (Optional)

Implementasi refresh token untuk seamless user experience:

1. Saat access token expire:
   a. Mobile detect token sudah expire
   b. Mobile send request ke /api/admin/refresh dengan refresh token
   c. Server validate refresh token
   d. Server generate access token baru
   e. Server send access token baru ke mobile
   f. Mobile simpan access token baru ke secure storage
   g. Mobile retry original request dengan token baru

2. Keuntungan:
   a. User tidak perlu login ulang
   b. Seamless experience
   c. More secure: Access token durasi pendek

3. Kelemahan:
   a. Lebih kompleks untuk implement
   b. Refresh token management yang ekstra
   c. Additional refresh endpoint di server

### 6.4 Session Logout

#### 6.4.1 Logout dari Web Admin

1. Admin klik tombol "Logout" di interface
2. Browser kirim HTTP POST request ke /api/logout dengan session cookie
3. Server terima logout request
4. Server delete session dari storage (Redis atau Database)
5. Server send response dengan Set-Cookie header untuk delete session cookie
   a. Set-Cookie: ADMIN_SESSION=; Max-Age=0; Path=/; Secure; HttpOnly
   b. Max-Age=0 menginstruksikan browser untuk delete cookie
6. Browser delete session cookie
7. Server redirect ke login page
8. Admin berhasil logout

#### 6.4.2 Logout dari Mobile App

1. Admin tap tombol "Logout" di aplikasi
2. Aplikasi optional send request ke /api/logout untuk notify server
3. Aplikasi delete JWT token dari secure storage
4. Aplikasi delete user info dari local storage
5. Aplikasi navigate ke login screen
6. Admin berhasil logout

---

## 7. Fitur Keamanan Tambahan

### 7.1 Rate Limiting (Brute Force Protection)

#### 7.1.1 Implementasi Rate Limiting di Web

1. Tracking:
   a. Track login attempts per IP address
   b. Database table atau Redis key: failed_login_attempts:{ip_address}
   c. Data yang ditrack:
      - Jumlah failed attempts
      - Timestamp failed attempt terakhir
      - IP address

2. Rules:
   a. Maksimal 5 failed attempts dalam 15 menit dari IP yang sama
   b. Jika sudah 5 failed attempts, block IP
   c. Block duration: 15 menit
   d. After 15 menit, counter reset, IP bisa login lagi

3. Implementation:
   a. Saat admin login:
      - Check apakah IP sudah di-block
      - Jika ya, return error "Terlalu banyak percobaan login gagal"
      - Jika tidak, proceed login
   b. Saat login gagal:
      - Increment failed counter untuk IP ini
      - Check apakah sudah mencapai 5
      - Jika ya, block IP

4. Storage:
   a. Redis: SET failed_login:{ip} count EX 900 (15 menit TTL)
   b. Database: INSERT/UPDATE failed_login_attempts table dengan TTL

#### 7.1.2 Implementasi Rate Limiting di Mobile

1. Tracking:
   a. Track login attempts di device (local)
   b. SharedPreferences atau local storage
   c. Data yang ditrack:
      - Jumlah failed attempts
      - Timestamp failed attempt terakhir

2. Rules:
   a. Maksimal 5 failed attempts dalam 15 menit
   b. Jika sudah 5 failed attempts, show warning
   c. Maksimal 10 failed attempts, lock app sementara
   d. Lock duration: 15 menit
   e. Setelah 15 menit, counter reset

3. Implementation:
   a. Saat admin login:
      - Check local counter
      - Jika >= 10, show "App terkunci, coba lagi dalam 15 menit"
      - Jika >= 5, show warning "N percobaan gagal dari 10"
      - Proceed login
   b. Saat login gagal:
      - Increment counter
      - Update timestamp failed attempt
      - Check apakah >= 10, show lock message

4. UX:
   a. Warning message: "5 percobaan gagal dari 10. Hati-hati!"
   b. Lock message: "Terlalu banyak percobaan gagal. App terkunci 15 menit"
   c. Countdown timer: Show berapa lama app terkunci

### 7.2 Account Lockout

#### 7.2.1 Implementasi Account Lockout

1. Tracking:
   a. Track failed login attempts per admin account
   b. Database field: failed_login_attempts, locked_until
   c. Data:
      - failed_login_attempts: Jumlah percobaan gagal
      - locked_until: Timestamp kapan account akan di-unlock

2. Rules:
   a. Jika 5 failed login attempts, lock account
   b. Lock duration: 15 menit
   c. Admin tidak bisa login meskipun password benar saat account terkunci
   d. Setelah 15 menit, counter reset, account unlock

3. Implementation:
   a. Saat admin login:
      - Query admin dari database
      - Check field locked_until
      - Jika locked_until tidak NULL dan belum expired:
         - Return error "Account terkunci. Coba lagi dalam X menit"
         - Jangan verify password
         - Jangan increment counter
      - Jika locked_until NULL atau sudah expired:
         - Proceed password verification
   b. Saat password salah:
      - Increment failed_login_attempts counter
      - Check apakah counter >= 5
      - Jika ya:
         - Set locked_until = current_time + 15 minutes
         - Return error message yang friendly
         - Notify admin via email bahwa account terkunci

4. Notification:
   a. Send email ke admin:
      - Subject: "Account Admin Anda Terkunci"
      - Body: Informasi tentang lockout, kapan bisa login lagi
      - Optional: Link untuk unlock immediately (dengan verification)

### 7.3 Two-Factor Authentication (2FA) - Optional

#### 7.3.1 Email OTP (Recommended untuk MVP)

1. Flow:
   a. Admin login dengan username dan password
   b. Jika password benar, request 2FA code
   c. Server generate random 6-digit code
   d. Server send code ke email admin
   e. Admin input code di aplikasi/web
   f. Server verify code
   g. Jika code benar, generate session/token
   h. Jika code salah, reject login

2. Code characteristics:
   a. 6-digit random number
   b. Validity: 5 menit (code expire setelah 5 menit)
   c. One-time use: Code hanya bisa digunakan 1 kali
   d. Resend: Admin bisa request code baru (rate limited)

3. Implementation:
   a. Generate code: random.randint(100000, 999999)
   b. Store code di Redis: SET otp:{admin_id} code EX 300 (5 menit)
   c. Send email dengan code
   d. Admin input code di form
   e. Server verify code dari Redis
   f. Delete code setelah digunakan atau expired

#### 7.3.2 TOTP (Time-based OTP) - Phase 2

1. Setup:
   a. Admin scan QR code dengan Google Authenticator app
   b. QR code berisi secret key
   c. Google Authenticator generate 6-digit code yang berubah setiap 30 detik

2. Flow:
   a. Admin login dengan username dan password
   b. Request TOTP code
   c. Admin open Google Authenticator app
   d. Admin copy 6-digit code dari app
   e. Admin input code ke login form
   f. Server verify TOTP code dengan secret key
   g. Jika correct, generate session/token

3. Advantage:
   a. Tidak perlu internet untuk generate code
   b. Offline-first: Code generated locally di device
   c. Standard: Compatible dengan Google Authenticator dan similar apps

### 7.4 Password Reset/Recovery

#### 7.4.1 Password Reset Flow

1. Admin lupa password:
   a. Admin klik "Forgot Password" di login page
   b. Admin input username atau email
   c. Server cek apakah admin ada
   d. Server generate reset token (random, unique)
   e. Server send email dengan reset link

2. Email content:
   a. Subject: "Reset Password Admin R.R Hijab"
   b. Body:
      - Greeting dengan nama admin
      - Link untuk reset password: /reset-password?token={reset_token}
      - Link validity: 1 jam
      - Instruksi untuk click link
      - Warning jika bukan admin yang request, ignore email

3. Admin click link:
   a. Browser open link /reset-password?token={reset_token}
   b. Server validate token:
      - Token exist di database
      - Token belum expired (created_at + 1 hour > now)
      - Token belum digunakan (used_at = NULL)
   c. Jika valid: Show reset password form
   d. Jika invalid: Show error "Reset link expired atau tidak valid"

4. Admin input password baru:
   a. Admin input password baru (dengan validation)
   b. Admin click "Reset Password" button
   c. Server validate:
      - Token still valid
      - Password meet requirements
   d. Server hash password baru
   e. Server update password di database
   f. Server mark token sebagai used: UPDATE tokens SET used_at = now WHERE token = {reset_token}
   g. Server send email confirmation
   h. Show message "Password berhasil di-reset. Silakan login dengan password baru"

#### 7.4.2 Reset Token Security

1. Token generation:
   a. Random 32-character string
   b. Cryptographically secure random
   c. Unique di antara semua reset tokens

2. Token storage:
   a. Simpan di database table: password_reset_tokens
   b. Data: admin_id, token, created_at, expires_at, used_at
   c. No encryption needed: Token sudah random dan unique

3. Token expiration:
   a. Validity: 1 jam dari saat dibuat
   b. Check: created_at + 1 hour > current_time
   c. Expired tokens: Delete via background job atau via lazy delete

4. Token one-time use:
   a. Saat token digunakan, set used_at = current_time
   b. Sebelum menerima reset request, check used_at
   c. Jika used_at not NULL: Token sudah digunakan, reject

5. Security considerations:
   a. Token tidak include admin info (tidak bisa guess)
   b. Token expire cepat (1 jam)
   c. Token one-time use (tidak bisa reuse)
   d. Email link secure (hanya admin punya email)
   e. Log semua reset attempts untuk security monitoring

### 7.5 Login Activity Monitoring

#### 7.5.1 Track Login Attempts

1. Data yang ditrack:
   a. login_time: Timestamp saat login
   b. admin_id: Admin yang login
   c. username: Username
   d. ip_address: IP address dari mana login
   e. device_info: Device information (OS, browser, app version)
   f. user_agent: User agent string
   g. status: SUCCESS, FAILED, atau LOGOUT
   h. failure_reason: Jika failed, reason why (wrong password, account locked, dll)
   i. duration: Durasi session (untuk logout record)

2. Storage:
   a. Database table: login_history
   b. Retention: Minimal 3 bulan
   c. Index: admin_id, login_time, ip_address (untuk query fast)

#### 7.5.2 Admin Dashboard untuk Login Activity

Admin dashboard dapat menampilkan:

1. Recent login activity:
   a. List 10-20 login terakhir
   b. Waktu login
   c. Device/browser/IP
   d. Status (success/failed)

2. Failed login attempts:
   a. Jumlah failed attempts per admin
   b. Alasan failure (wrong password, account locked, rate limited, dll)
   c. IP address dari mana attempt berasal

3. Device management:
   a. List devices yang pernah login
   b. Last login dari device tersebut
   c. Option untuk logout dari device tertentu

#### 7.5.3 Security Alerts

Alert admin jika suspicious activity:

1. Unusual location login:
   a. Detect: Login dari IP address geografis yang jauh dari login terakhir
   b. Alert: Email ke admin "Login detected dari lokasi baru: City, Country"
   c. Action: Admin can confirm atau mark as suspicious

2. Multiple failed attempts:
   a. Detect: Multiple failed login attempts dari IP tertentu
   b. Alert: Email ke admin "Ada percobaan login yang gagal dari IP XXX"
   c. Action: Check apakah ada security breach

3. Unusual device login:
   a. Detect: Login dari device baru atau OS berbeda
   b. Alert: Email ke admin "Login dari device baru: Android, Samsung Galaxy"
   c. Action: Confirm device

4. Logout dan login cepat dari IP berbeda:
   a. Detect: Logout di IP A, login di IP B dalam waktu singkat (tidak mungkin)
   b. Alert: Email ke admin "Suspicious activity: Logout dan login dari lokasi berbeda"
   c. Action: Check apakah account di-compromise

---

## 8. Security Best Practices Checklist

### 8.1 Web Admin Security

1. Password Storage:
   a. Gunakan bcrypt dengan cost factor minimum 10
   b. Generate unique salt untuk setiap password
   c. Jangan pernah simpan password plain text

2. HTTPS/SSL:
   a. Semua login requests via HTTPS (tidak ada HTTP)
   b. Session cookie dengan Secure flag (hanya via HTTPS)
   c. HSTS header untuk force HTTPS di browser
   d. Valid SSL certificate dari trusted CA

3. Session Management:
   a. Generate random dan unique session IDs
   b. Session stored di server (Redis atau Database)
   c. Session cookie dengan HttpOnly flag (tidak accessible via JS)
   d. Session cookie dengan SameSite flag (prevent CSRF)
   e. Session timeout: Idle 30 menit, Absolute 8 jam

4. CSRF Protection:
   a. CSRF token di setiap form
   b. Token unique per session
   c. Token validation sebelum process form
   d. SameSite cookie flag

5. Brute Force Protection:
   a. Rate limiting: Max 5 failed attempts per IP dalam 15 menit
   b. Account lockout: Lock account setelah 5 failed attempts selama 15 menit
   c. Log semua failed attempts

6. Input Validation:
   a. Validate username format (alphanumeric, underscore, length)
   b. Validate password length (min 8, max 128)
   c. Parameterized queries (prevent SQL injection)
   d. Input sanitization dan trimming

7. Error Messages:
   a. Generic error messages (jangan expose detail)
   b. Jangan reveal apakah username exist atau password salah
   c. Log detailed errors di server untuk debugging

8. Audit Logging:
   a. Log semua login attempts (success/failed)
   b. Log IP address, device, browser
   c. Log session creation dan deletion
   d. Log password changes
   e. Retain logs minimal 3 bulan

9. Password Policy:
   a. Minimum 8 karakter
   b. Require uppercase, lowercase, number, special char
   c. Regular password change (setiap 90 hari atau policy)
   d. Password history: Tidak bisa reuse recent passwords

### 8.2 Mobile App Security

1. Password Storage:
   a. JANGAN simpan password di local storage
   b. JANGAN simpan password plain text di device
   c. Hanya simpan token, bukan password

2. Token Storage:
   a. Simpan JWT token di secure storage (Keystore/Keychain)
   b. JANGAN simpan di SharedPreferences atau plain text
   c. Encrypt token jika possible (double encryption)
   d. Delete token saat logout

3. HTTPS/SSL:
   a. Semua API requests via HTTPS
   b. Certificate validation: Validate server certificate
   c. Certificate pinning (prevent MITM attacks)
   d. Disable HTTP (jangan allow clear text)

4. Token Management:
   a. Check token expiration saat app open
   b. Refresh token jika diperlukan (optional)
   c. Delete token saat logout
   d. Handle 401 response: Delete token, navigate ke login

5. Brute Force Protection:
   a. Track failed login attempts di device
   b. Lock app sementara setelah 10 failed attempts
   c. Rate limiting: Max 5 failed attempts per 15 menit

6. Input Validation:
   a. Validate username format
   b. Validate password length
   c. Trim whitespace dari input
   d. Show validation errors real-time

7. Secure Storage:
   a. Gunakan flutter_secure_storage atau similar
   b. JANGAN simpan sensitive data di SharedPreferences
   c. JANGAN simpan sensitive data di local files

8. API Security:
   a. Include JWT token di Authorization header setiap request
   b. Validate SSL certificate
   c. Handle network errors gracefully
   d. Timeout jika request terlalu lama

9. Error Handling:
   a. Jangan display sensitive error messages
   b. Log errors untuk debugging
   c. Show generic error messages kepada user
   d. Handle network disconnection

10. App Security:
    a. Obfuscate code untuk prevent reverse engineering
    b. Disable debug mode di production builds
    c. Certificate pinning untuk prevent MITM
    d. Validate app signature (Android)
    e. Implement code tampering detection
    f. Monitor device security (jailbreak/root detection)

### 8.3 General Best Practices

1. Security Updates:
   a. Keep frameworks dan libraries updated
   b. Security patches: Apply immediately
   c. Monitor security advisories

2. Testing:
   a. Security testing: Penetration testing
   b. Unit tests untuk security functions
   c. Integration tests untuk full flow
   d. Load testing: Verify rate limiting works

3. Monitoring dan Alerting:
   a. Monitor login failures
   b. Alert untuk suspicious activities
   c. Monitor password changes
   d. Monitor session activities

4. Documentation:
   a. Document security architecture
   b. Document authentication flows
   c. Security runbooks untuk incidents
   d. Regular security training

5. Compliance:
   a. Follow OWASP guidelines
   b. Follow NIST guidelines
   c. Comply dengan regulatory requirements (GDPR, dll)
   d. Regular security audits

---

## 9. Ringkasan Sistem Login Aman

Sistem login yang aman untuk R.R Hijab melibatkan:

1. Web Admin:
   a. Session-based authentication
   b. CSRF protection dengan token
   c. Password hashing dengan bcrypt
   d. Rate limiting dan account lockout
   e. Audit logging lengkap

2. Mobile App:
   a. Token-based authentication dengan JWT
   b. Secure token storage
   c. Auto-login dengan token validation
   d. Similar security measures seperti web (rate limiting, logging)

3. Backend:
   a. Unified authentication endpoint untuk web dan mobile
   b. Password hashing dengan bcrypt
   c. Session/token generation dan validation
   d. Audit logging dan security monitoring
   e. Rate limiting dan account protection

4. Keamanan Komprehensif:
   a. Encryption in transit (HTTPS)
   b. Password hashing di storage
   c. Session/token management yang secure
   d. Brute force protection
   e. CSRF protection (web)
   f. Audit trail yang lengkap
