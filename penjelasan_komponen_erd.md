Penjelasan Komponen Entity Relationship Diagram (ERD)

Bagian ini mendeskripsikan seluruh komponen, atribut, dan hubungan (relasi) antar-entitas yang wajib digambar dalam diagram ERD sistem R.R Hijab untuk memenuhi kebutuhan penyimpanan data pada database MySQL.

Entitas Data Admin

Sisi Sistem Berbasis Web (Manajemen Akun)

1. Atribut Kunci Utama
- Atribut ID Admin berperan sebagai Primary Key berupa angka unik yang bertambah otomatis untuk membedakan setiap akun admin

2. Atribut Kredensial Masuk
- Atribut Username berupa teks singkat untuk identitas login dan bersifat unik tidak boleh ada yang sama
- Atribut Password berupa teks rahasia yang sudah disamarkan menggunakan enkripsi keamanan

3. Hubungan Relasi Data
- Seorang Admin dapat mengelola banyak data produk di dalam sistem dengan jenis relasi Satu ke Banyak atau One to Many

---

Entitas Data Produk

Sisi Sistem Berbasis Web dan Aplikasi Mobile

1. Atribut Kunci Utama
- Atribut ID Produk berperan sebagai Primary Key berupa kode unik untuk penanda setiap jenis jilbab

2. Atribut Informasi Katalog
- Atribut Nama Produk berupa teks untuk menampilkan nama hijab di halaman utama
- Atribut Deskripsi Produk berupa teks panjang yang menjelaskan detail bahan, ukuran, dan warna hijab
- Atribut Kategori berupa teks untuk mengelompokkan jenis produk seperti Pashmina atau Hijab Instan

3. Atribut Nilai dan Media
- Atribut Harga berupa angka positif untuk nominal harga jual produk
- Atribut Tautan Gambar berupa teks alamat URL yang mengarah ke file foto produk di server supplier

4. Hubungan Relasi Data
- Satu produk dapat dipilih di dalam banyak data pesanan pelanggan dengan jenis relasi Satu ke Banyak atau One to Many

---

Entitas Data Pesanan

Sisi Sistem Berbasis Aplikasi Mobile dan Web

1. Atribut Kunci Utama
- Atribut ID Pesanan berperan sebagai Primary Key berupa nomor invoice unik untuk tiap transaksi belanja

2. Atribut Identitas Transaksi
- Atribut Nama Pelanggan berupa teks nama lengkap pihak pembeli
- Atribut Nomor WhatsApp berupa teks atau angka nomor kontak aktif pembeli
- Atribut Status Pesanan berupa teks status kondisi transaksi saat ini yang berisi Menunggu Pembayaran, Diproses, atau Dibatalkan

3. Atribut Penghubung Relasi
- Atribut ID Produk berperan sebagai Foreign Key atau kunci tamu yang menghubungkan data pesanan dengan asal produk yang dibeli
- Satu data pesanan hanya dapat menerima satu data ulasan purna jual setelah transaksi selesai dengan jenis relasi Satu ke Satu atau One to One

---

Entitas Data Feedback

Sisi Sistem Berbasis Aplikasi Mobile (Flutter)

1. Atribut Kunci Utama
- Atribut ID Feedback berperan sebagai Primary Key berupa angka unik penanda ulasan yang bertambah otomatis

2. Atribut Informasi Ulasan
- Atribut Nama Pengirim berupa teks nama pelanggan yang memberikan komentar
- Atribut Isi Komentar berupa teks ulasan mengenai kualitas pelayanan atau produk hijab

3. Atribut Penghubung Relasi
- Atribut ID Pesanan berperan sebagai Foreign Key atau kunci tamu untuk memastikan ulasan yang dikirim valid berdasarkan transaksi asli
