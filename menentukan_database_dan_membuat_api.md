# Menentukan Database dan Membuat API

## Aturan Pengelolaan dan Batasan Basis Data (MySQL)

Bagian ini mendefinisikan aturan main penyimpanan data di database MySQL yang memisahkan batasan untuk sistem berbasis Web dan Aplikasi Mobile.

### Sisi Sistem Berbasis Web (Company Profile dan Admin Web)

#### 1. Manajemen Konten Utama
- Sistem web bertanggung jawab penuh atas pengelolaan data utama seperti katalog jilbab, harga, deskripsi, dan kategori
- Perubahan yang dilakukan di web akan langsung memperbarui database pusat

#### 2. Keamanan Akun Internal
- Semua password akun pengelola atau admin yang masuk lewat web wajib dikunci dengan enkripsi hash
- Database **dilarang** menyimpan password dalam bentuk teks biasa

#### 3. Validasi Transaksi
- Data pesanan yang masuk ke database awalnya berstatus **Menunggu Pembayaran**
- Status ini hanya bisa diubah menjadi **Valid** setelah dilakukan pengecekan manual terhadap mutasi rekening atau e-wallet

### Sisi Sistem Berbasis Aplikasi Mobile (Flutter)

#### 1. Sinkronisasi Katalog
- Aplikasi mobile bertindak sebagai penerima informasi data secara real-time
- Produk yang aktif di database MySQL harus langsung muncul di aplikasi Flutter pelanggan tanpa jeda lama

#### 2. Kontrol Stok Reseller
- Jika ada info dari supplier bahwa stok hijab habis, status produk di database harus berubah otomatis
- Aplikasi mobile langsung menyembunyikan tombol order untuk produk yang stoknya habis

#### 3. Privasi Pengguna
- Data sensitif pengguna aplikasi mobile seperti nomor HP atau alamat rumah **dilarang** dimasukkan atau disimpan ke dalam tabel testimoni atau feedback publik
- Data pengguna harus tetap aman dan tidak terekspos ke publik

#### 4. Aturan Pembatalan Otomatis (TBD-3)
- Batas waktu kapan data pesanan di aplikasi mobile otomatis hangus jika tidak dibayar
- Status saat ini: **Masih dalam diskusi oleh tim**

---

## Spesifikasi Antarmuka Aplikasi (API Contract)

API di sini dibagi menjadi dua kelompok besar untuk memisahkan jalur komunikasi data antara program Web dan program Aplikasi Mobile.

### Kelompok API untuk Sistem Web

#### 1. API Pembaruan Status Transaksi (Update Order Status)

**Fungsi:**
Mengubah status data pesanan di database setelah pengelola selesai mengecek bukti transfer secara manual di web.

**Input dari Web:**
- ID Pesanan yang sedang diperiksa
- Pilihan status baru (contoh: `Diproses`, `Dikirim`, `Selesai`)

**Output dari Database:**
- Notifikasi sukses bahwa status di database sudah berubah
- Riwayat transaksi di kedua program (Web & Mobile) langsung ter-update

---

#### 2. API Sinkronisasi Katalog Web (Sync Web Catalog)

**Fungsi:**
Menyalurkan data produk baru yang di-input atau diedit oleh pengelola lewat halaman web ke dalam database.

**Input dari Web:**
- Nama hijab
- Kategori produk
- Harga
- Deskripsi
- File Foto

**Output dari Database:**
- Data berhasil disimpan
- Link foto produk siap diakses oleh sistem luar

---

### Kelompok API untuk Aplikasi Mobile (Flutter)

#### 1. API Memuat Katalog Produk (Get Product List Mobile)

**Fungsi:**
Mengambil data katalog dari database MySQL untuk dipasang pada halaman utama dan halaman pencarian di aplikasi Flutter.

**Input dari Flutter:**
- Parameter filter kategori jilbab
- Kata kunci pencarian yang diketik pengguna di HP

**Output dari Database:**
- Daftar produk aktif berisi:
  - Nama produk
  - Deskripsi
  - Harga
  - Link Foto
- **Target performa:** Muat di layar HP dalam waktu kurang dari 3 detik

---

#### 2. API Pengiriman Data Pesanan Baru (Post Order Data Mobile)

**Fungsi:**
Mencatat data belanjaan dari aplikasi Flutter ke database sebagai arsip pesanan, sebelum pengguna diarahkan lanjut ke WhatsApp.

**Input dari Flutter:**
- Nama pelanggan
- ID produk yang dipilih
- Nomor WhatsApp aktif

**Output dari Database:**
- Nomor invoice pesanan baru
- Tautan otomatis untuk membuka chat ke WhatsApp Gateway

---

#### 3. API Pengiriman Ulasan Pengguna (Submit Feedback Mobile)

**Fungsi:**
Mengirim ulasan atau komplain langsung dari aplikasi Flutter setelah pengguna menerima paket hijab.

**Input dari Flutter:**
- Nama pengirim
- Isi ulasan atau komentarnya

**Output dari Database:**
- Teks komentar berhasil masuk ke database
- Nomor HP atau alamat pembeli **tidak ikut tersimpan** agar data mereka tetap aman

---

## Catatan Penting

- Semua API harus mengikuti standar RESTful atau GraphQL yang konsisten
- Implementasi error handling dan validasi input yang ketat pada setiap endpoint
- Dokumentasi API akan dikembangkan lebih lanjut sesuai kebutuhan development
- Data sanitization dan security measures harus diterapkan di setiap transaksi