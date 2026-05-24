# Aturan Batas Waktu dan Operasional

## Aturan Batas Waktu Pembayaran Pesanan

Bagian ini mendefinisikan kebijakan otomatisasi sistem terkait batas waktu toleransi pembayaran sebelum transaksi dibatalkan oleh sistem.

### Sisi Sistem Berbasis Web (Manajemen Kontrol)

#### 1. Pengaturan Durasi Pembatalan
- Pengelola sistem dapat menentukan dan mengubah acuan waktu kedaluwarsa pesanan melalui halaman konfigurasi di web
- Waktu standar yang ditetapkan oleh sistem adalah **24 jam** sejak pesanan pertama kali dibuat oleh pelanggan

#### 2. Sistem Otomatisasi Penghapusan
- Web server akan melakukan pengecekan berkala ke database MySQL
- Jika ditemukan data pesanan dengan status **Menunggu Pembayaran** yang telah melewati batas waktu 24 jam, sistem web akan otomatis mengubah status menjadi **Dibatalkan Sistem**

#### 3. Pemulihan Stok Otomatis
- Ketika sistem web mengubah status transaksi menjadi batal, jumlah inventaris atau kuota produk di database akan dikembalikan secara otomatis
- Hal ini dilakukan untuk mencegah manipulasi data stok

### Sisi Sistem Berbasis Aplikasi Mobile (Flutter)

#### 1. Penghitung Waktu Mundur (Countdown Timer)
- Aplikasi mobile Flutter akan menerima data waktu pembuatan pesanan dari database
- Menampilkan teks penghitung waktu mundur secara real-time di halaman riwayat transaksi pelanggan

#### 2. Penutupan Akses Bayar
- Jika waktu hitung mundur di aplikasi mobile sudah mencapai angka nol, tombol untuk melanjutkan konfirmasi atau akses kirim bukti ke WhatsApp otomatis dikunci
- Teks tampilan berubah menjadi **Pesanan Kadaluwarsa**

---

## Aturan Jam Operasional Kerja Sistem

Bagian ini mendefinisikan kebijakan operasional sistem berdasarkan jam kerja R.R Hijab dan sinkronisasi aturan data.

### Sisi Sistem Berbasis Web (Manajemen Kontrol)

#### 1. Pembatasan Respon Admin
- Halaman validasi transaksi pada sistem web tetap dapat diakses oleh pengelola selama 24 jam
- Proses verifikasi manual bukti transfer hanya dilakukan pada jam kerja aktif: **08:00 - 17:00 WIB**

#### 2. Notifikasi Penundaan
- Sistem web dikonfigurasi untuk menunda pemicu pesan otomatis ke pihak ketiga (seperti WhatsApp Gateway)
- Jika pengelola melakukan perubahan status di luar jam kerja aktif, pengiriman pesan ditunda untuk menghindari pesan di malam hari

### Sisi Sistem Berbasis Aplikasi Mobile (Flutter)

#### 1. Pengiriman Pesanan Fleksibel
- Pelanggan tetap dapat melihat katalog dan menekan tombol buat pesanan di aplikasi mobile Flutter **kapan saja**
- Termasuk di luar jam kerja (malam hari, hari libur, dll)

#### 2. Peringatan Jam Operasional
- Jika pelanggan membuat pesanan di luar jam kerja (**sebelum 08:00 atau setelah 17:00 WIB**), aplikasi mobile akan memunculkan teks informasi pemberitahuan
- Pesan: *"Transaksi Anda telah dicatat di database, namun proses verifikasi oleh pengelola akan diproses pada keesokan hari kerja."*

---

## Ringkasan Timeline Sistem

| Aspek | Web | Mobile | Keterangan |
|-------|-----|--------|-----------|
| **Akses Katalog** | 24 jam | 24 jam | Selalu tersedia |
| **Buat Pesanan** | 24 jam | 24 jam | Pelanggan bisa kapan saja |
| **Verifikasi Manual** | 08:00 - 17:00 WIB | - | Admin verifikasi pada jam kerja |
| **Batas Waktu Bayar** | 24 jam | 24 jam | Countdown timer aktif |
| **Notifikasi Ke Pihak 3** | 08:00 - 17:00 WIB | - | Hanya saat jam kerja |
| **Pembatalan Otomatis** | Setelah 24 jam | Setelah 24 jam | Jika belum dibayar |

---

## Catatan Penting

- Semua waktu menggunakan standar **WIB (Waktu Indonesia Barat)**
- Sistem harus konsisten dalam melakukan pengecekan dan otomatisasi
- Pengaturan durasi pembatalan dapat dikonfigurasi ulang melalui admin panel web
- Error handling dan logging harus tercatat untuk audit trail transaksi
- Notifikasi delay tidak mengurangi keandalan sistem, hanya mengatur waktu pengiriman