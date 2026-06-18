# Menyusun Algoritma Konfirmasi Pembayaran

Dokumen ini mendeskripsikan detail algoritma untuk fitur konfirmasi pembayaran pada sistem R.R Hijab yang diimplementasikan di aplikasi web admin dan aplikasi mobile Flutter.

---

## 1. Pendahuluan Algoritma Konfirmasi Pembayaran

### 1.1 Definisi Proses Konfirmasi Pembayaran

Konfirmasi pembayaran adalah proses di mana admin memvalidasi bukti transfer dari pelanggan dan mengubah status pesanan dari "Menunggu Pembayaran" menjadi "Diproses". Proses ini melibatkan koordinasi antara web admin, database, aplikasi mobile pelanggan, dan WhatsApp Gateway untuk notifikasi.

### 1.2 Aktor yang Terlibat

1. Admin/Pengelola: Melakukan validasi pembayaran melalui web
2. Sistem Backend: Memproses validasi dan mengupdate data
3. Database: Menyimpan dan mengambil data pesanan
4. Aplikasi Mobile: Menerima update status secara real-time
5. WhatsApp Gateway: Mengirimkan notifikasi kepada pelanggan

### 1.3 Tujuan Algoritma

1. Memastikan pembayaran benar-benar masuk ke rekening
2. Mengubah status pesanan dengan akurat
3. Mengembalikan stok jika pesanan dibatalkan
4. Mengirimkan notifikasi tepat waktu ke pelanggan
5. Mencatat log untuk keperluan audit

---

## 2. Algoritma Validasi Pembayaran (Web Admin)

### 2.1 Deskripsi Umum

Admin melakukan validasi manual terhadap bukti transfer yang diterima dari pelanggan. Sistem akan memverifikasi data pesanan, waktu pembayaran, dan jumlah transfer sebelum mengubah status pesanan.

### 2.2 Penjelasan Alur Validasi Pembayaran

#### 2.2.1 Langkah 1: Ambil Data Pesanan dari Database

Admin memasukkan nomor invoice untuk dicari di database. Sistem melakukan query ke tabel pesanan untuk mendapatkan data pesanan lengkap berdasarkan invoice ID yang dimasukkan.

Data yang diambil meliputi:
1. Nama pelanggan
2. Nomor WhatsApp
3. Status pesanan saat ini
4. Total harga
5. Waktu pembuatan pesanan
6. ID produk
7. Quantity/jumlah pesanan

Jika pesanan tidak ditemukan di database, sistem menampilkan pesan error "Nomor invoice tidak ditemukan di sistem" dan proses berhenti.

#### 2.2.2 Langkah 2: Validasi Status Pesanan Saat Ini

Setelah data pesanan ditemukan, sistem memeriksa status pesanan saat ini. Status pesanan harus "Menunggu Pembayaran" agar dapat divalidasi oleh admin.

Jika status pesanan bukan "Menunggu Pembayaran", berarti pesanan sudah pernah divalidasi sebelumnya atau sudah dibatalkan. Dalam hal ini, sistem menampilkan pesan error yang menjelaskan status saat ini dan proses validasi dibatalkan.

Tujuan validasi ini adalah untuk mencegah double validation atau manipulasi data pesanan yang sudah diproses sebelumnya.

#### 2.2.3 Langkah 3: Hitung Waktu yang Telah Berlalu

Sistem menghitung selisih waktu antara saat ini dengan waktu pembuatan pesanan. Perhitungan waktu menggunakan UTC timezone untuk consistency.

Rumus perhitungan:
Waktu yang berlalu = Waktu saat ini - Waktu pembuatan pesanan

Sistem menetapkan batasan maksimal 24 jam. Jika waktu yang berlalu sudah melampaui 24 jam, maka pesanan dianggap kadaluwarsa.

Tujuan batasan 24 jam adalah untuk memastikan bahwa pesanan yang tidak dibayar tidak tergantung di database selamanya. Pelanggan harus melakukan pembayaran dalam waktu 24 jam setelah membuat pesanan.

#### 2.2.4 Langkah 4: Periksa Apakah Pesanan Kadaluwarsa

Jika waktu yang berlalu lebih dari 24 jam, sistem melakukan proses pembatalan otomatis:

1. Mengubah status pesanan menjadi "Dibatalkan Sistem"
2. Mencatat waktu perubahan status (update timestamp)
3. Memanggil fungsi restoreStock untuk mengembalikan stok produk ke inventory
4. Menambahkan record ke tabel log_aktivitas untuk keperluan audit
5. Mengirimkan pesan WhatsApp ke pelanggan bahwa pesanan telah dibatalkan

Setelah proses pembatalan selesai, sistem menampilkan pesan error kepada admin bahwa "Pesanan sudah kadaluwarsa dan otomatis dibatalkan. Stok telah dikembalikan."

#### 2.2.5 Langkah 5: Update Status Pesanan Menjadi Diproses

Jika pesanan masih valid (belum melewati 24 jam), sistem melakukan update status pesanan:

1. Mengubah status pesanan dari "Menunggu Pembayaran" menjadi "Diproses"
2. Mencatat waktu pembayaran (waktu admin melakukan validasi)
3. Update timestamp "diubah_pada" untuk menandai kapan perubahan terjadi

Perubahan data ini dilakukan dalam satu transaction untuk memastikan atomicity. Jika ada error di tengah proses, seluruh perubahan akan di-rollback.

#### 2.2.6 Langkah 6: Ambil Data Admin yang Melakukan Validasi

Sistem mengambil data admin yang sedang login dan melakukan validasi pembayaran. Data yang diambil meliputi:

1. ID Admin
2. Username
3. Email

Data ini digunakan untuk keperluan logging dan audit trail sehingga dapat diketahui siapa yang melakukan validasi pembayaran dan kapan validasi dilakukan.

#### 2.2.7 Langkah 7: Log Aktivitas Validasi

Sistem menambahkan record ke tabel log_aktivitas untuk mencatat aktivitas validasi pembayaran. Data yang dicatat meliputi:

1. ID Pesanan (invoice ID)
2. ID Admin yang melakukan validasi
3. Aksi yang dilakukan ("Validasi Pembayaran")
4. Waktu validasi (timestamp saat admin melakukan validasi)
5. Keterangan tambahan (nama admin yang melakukan validasi)

Log ini penting untuk keperluan compliance, audit trail, dan troubleshooting. Jika ada masalah di masa depan, dapat dilacak siapa yang melakukan apa dan kapan.

#### 2.2.8 Langkah 8: Trigger Notifikasi WhatsApp

Sistem secara otomatis mengirimkan pesan WhatsApp kepada pelanggan bahwa pembayaran mereka telah divalidasi. Proses ini melibatkan:

1. Mengambil nomor WhatsApp pelanggan dari data pesanan
2. Mempersiapkan template pesan notifikasi
3. Memanggil WhatsApp Gateway API untuk mengirim pesan
4. Mencatat hasil pengiriman (success atau failed) ke log

Isi pesan notifikasi mencakup informasi:
1. Nama pelanggan
2. Nomor invoice pesanan
3. Total harga pesanan
4. Informasi bahwa pembayaran telah divalidasi
5. Informasi bahwa pesanan sedang diproses

#### 2.2.9 Langkah 9: Trigger Update Status di Aplikasi Mobile

Sistem mengirimkan signal/event ke aplikasi mobile pelanggan agar status pesanan ter-update secara real-time. Proses ini menggunakan salah satu dari teknologi:

1. WebSocket untuk instant real-time updates jika aplikasi sedang aktif
2. Push Notification (Firebase Cloud Messaging) jika aplikasi tidak aktif
3. Message Queue (RabbitMQ atau Redis) untuk queuing dan reliability

Update yang dikirim mencakup:
1. Nomor invoice pesanan
2. Status baru pesanan ("Diproses")
3. Waktu update
4. Nama pelanggan
5. Informasi tambahan lainnya

Ketika aplikasi mobile menerima update ini, aplikasi akan:
1. Update data pesanan di local storage
2. Refresh UI halaman riwayat transaksi
3. Hentikan countdown timer pembayaran
4. Tampilkan notifikasi kepada pelanggan

#### 2.2.10 Langkah 10: Update Cache untuk Performance

Sistem melakukan update pada cache (Redis atau Memcached) agar data yang sering diakses tersimpan dengan cepat. Cache ini membantu mengurangi beban pada database dan meningkatkan performa aplikasi.

Data yang di-cache meliputi:
1. Data pesanan lengkap
2. Data produk terkait
3. Data riwayat transaksi pelanggan

#### 2.2.11 Langkah 11: Commit Transaction

Setelah semua proses berhasil, sistem melakukan commit pada database transaction. Ini berarti semua perubahan data yang telah dilakukan akan disimpan secara permanen di database.

Jika ada error atau exception di tengah proses, transaction akan otomatis di-rollback sehingga database tetap dalam kondisi yang konsisten.

#### 2.2.12 Langkah 12: Tampilkan Success Message

Sistem menampilkan pesan sukses kepada admin di web interface bahwa "Pembayaran berhasil divalidasi. Status pesanan diubah menjadi Diproses."

---

## 3. Algoritma Pengembalian Stok

### 3.1 Deskripsi Umum

Ketika pesanan dibatalkan (baik karena kadaluwarsa maupun pembatalan manual), stok produk harus dikembalikan ke inventory agar dapat dipesan oleh pelanggan lain.

### 3.2 Penjelasan Alur Pengembalian Stok

#### 3.2.1 Langkah 1: Ambil Data Produk dari Database

Sistem mengambil data produk dari tabel produk berdasarkan product ID yang disertakan dalam data pesanan yang dibatalkan.

Data produk yang diambil meliputi:
1. ID Produk
2. Nama Produk
3. Stok saat ini
4. Status produk (Aktif atau Tidak Aktif)
5. Kategori produk
6. Harga produk

Jika produk tidak ditemukan, sistem menampilkan pesan error "Produk dengan ID [ProductID] tidak ditemukan" dan proses berhenti.

#### 3.2.2 Langkah 2: Hitung Stok Baru Setelah Dikembalikan

Sistem menghitung stok produk yang baru setelah dikembalikan dengan rumus:

Stok Baru = Stok Lama + Quantity Pesanan yang Dibatalkan

Contoh:
1. Stok lama produk "Hijab Pashmina" = 5 unit
2. Quantity pesanan yang dibatalkan = 2 unit
3. Stok baru = 5 + 2 = 7 unit

#### 3.2.3 Langkah 3: Tentukan Status Produk Berdasarkan Stok

Setelah stok baru dihitung, sistem menentukan status produk berdasarkan jumlah stok:

1. Jika stok baru lebih dari 0 (stok > 0), maka status produk menjadi "Aktif"
2. Jika stok baru sama dengan 0 (stok = 0), maka status produk menjadi "Tidak Aktif"
3. Jika stok baru kurang dari 0 (stok < 0), ini adalah kondisi error yang tidak boleh terjadi

Tujuan penentuan status ini adalah agar aplikasi mobile tahu produk mana yang masih bisa dipesan dan mana yang sudah habis.

#### 3.2.4 Langkah 4: Validasi Batasan Maksimal Stok

Sistem melakukan validasi bahwa stok baru tidak melebihi kapasitas maksimal yang ditetapkan. Batasan maksimal stok per produk adalah 10000 unit.

Jika stok baru lebih dari 10000 unit, sistem akan membatasi stok menjadi 10000 unit untuk mencegah overflow atau data corruption di database.

Contoh:
1. Stok lama = 9998 unit
2. Quantity yang dikembalikan = 5 unit
3. Stok baru calculated = 9998 + 5 = 10003 unit
4. Stok baru final = 10000 unit (dibatasi sesuai maksimal)

#### 3.2.5 Langkah 5: Update Stok dan Status Produk di Database

Sistem melakukan update pada tabel produk dengan data stok dan status yang baru. Update ini dilakukan dalam satu query untuk efisiensi:

Data yang di-update:
1. Stok produk = stok baru
2. Status produk = status baru
3. Timestamp "diubah_pada" = waktu saat ini

Update hanya dilakukan untuk produk dengan ID yang sesuai, menggunakan WHERE clause untuk precision.

#### 3.2.6 Langkah 6: Log Perubahan Stok untuk Audit

Sistem menambahkan record ke tabel log_stok untuk mencatat perubahan stok. Data yang dicatat meliputi:

1. ID Produk
2. Stok lama (sebelum pengembalian)
3. Stok baru (setelah pengembalian)
4. Jenis perubahan ("Pengembalian")
5. Keterangan perubahan (berapa quantity yang dikembalikan dan alasan pembatalan)
6. Waktu perubahan (timestamp)

Log ini penting untuk tracking dan analisis perubahan stok dari waktu ke waktu.

#### 3.2.7 Langkah 7: Trigger Update Katalog ke Aplikasi Mobile

Sistem mengirimkan event/signal ke aplikasi mobile untuk mengupdate data katalog produk secara real-time. Aplikasi mobile akan:

1. Update data produk di local storage
2. Refresh tampilan katalog produk
3. Update status tombol "Pesan" (dari "Stok Habis" menjadi "Pesan Sekarang" jika stok sudah tersedia)
4. Tampilkan notifikasi kepada pengguna bahwa produk sudah tersedia kembali

#### 3.2.8 Langkah 8: Update Cache Produk

Sistem melakukan update pada cache (Redis atau Memcached) agar data produk yang ter-cache tetap fresh dan sesuai dengan database.

Cache yang di-update meliputi:
1. Data produk lengkap
2. Data stok produk
3. Data status produk

---

## 4. Algoritma Pembatalan Otomatis (Background Job)

### 4.1 Deskripsi Umum

Sistem harus menjalankan job berkala (setiap 5 menit) untuk mengecek dan membatalkan pesanan yang sudah melewati batas waktu 24 jam tanpa pembayaran. Job ini berjalan di background dan tidak memerlukan intervensi admin.

### 4.2 Penjelasan Alur Pembatalan Otomatis

#### 4.2.1 Konfigurasi Job

Job ini dijadwalkan untuk berjalan secara otomatis setiap 5 menit. Interval 5 menit dipilih sebagai kompromi antara:

1. Responsivitas: Semakin sering job berjalan, semakin cepat pesanan yang kadaluwarsa dibatalkan
2. Beban server: Semakin jarang job berjalan, semakin sedikit beban pada server

Timezone yang digunakan adalah UTC (Coordinated Universal Time) agar konsisten di mana pun server berada.

#### 4.2.2 Langkah 1: Hitung Waktu Cutoff (24 Jam yang Lalu)

Sistem menghitung waktu cutoff dengan mengurangi 24 jam dari waktu saat ini.

Rumus perhitungan:
Cutoff Time = Waktu Saat Ini - 24 Jam

Semua pesanan yang dibuat sebelum waktu cutoff ini dianggap sudah melewati batas waktu pembayaran.

#### 4.2.3 Langkah 2: Query Pesanan Kadaluwarsa

Sistem melakukan query ke database untuk mengambil semua pesanan yang memenuhi kriteria:

1. Status pesanan = "Menunggu Pembayaran"
2. Waktu pembuatan pesanan < Cutoff Time (lebih dari 24 jam yang lalu)

Query ini menggunakan database index pada kolom status_pesanan dan waktu_pembuatan agar eksekusi cepat.

Hasil query berupa list berisi semua pesanan yang kadaluwarsa.

#### 4.2.4 Langkah 3: Periksa Apakah Ada Pesanan Kadaluwarsa

Sistem memeriksa apakah list pesanan kadaluwarsa kosong atau tidak.

1. Jika list kosong (tidak ada pesanan kadaluwarsa), job selesai dengan status "SUCCESS" dan tidak perlu melakukan proses selanjutnya
2. Jika list tidak kosong (ada pesanan kadaluwarsa), lanjutkan ke step berikutnya

#### 4.2.5 Langkah 4: Iterasi Setiap Pesanan Kadaluwarsa

Untuk setiap pesanan dalam list kadaluwarsa, sistem melakukan proses pembatalan. Loop ini akan berjalan sebanyak jumlah pesanan kadaluwarsa yang ditemukan.

#### 4.2.6 Langkah 4.1: Update Status Pesanan Menjadi Dibatalkan Sistem

Untuk setiap pesanan kadaluwarsa, sistem mengupdate status menjadi "Dibatalkan Sistem". Data yang di-update:

1. Status pesanan = "Dibatalkan Sistem"
2. Timestamp "diubah_pada" = waktu saat ini

Update ini dilakukan dengan WHERE clause yang spesifik ke pesanan tertentu.

#### 4.2.7 Langkah 4.2: Kembalikan Stok Produk

Sistem memanggil fungsi restoreStock untuk mengembalikan stok produk ke inventory. Fungsi ini akan:

1. Mengambil data produk dari database
2. Menghitung stok baru (stok lama + quantity pesanan)
3. Mengupdate status produk (Aktif atau Tidak Aktif)
4. Mencatat perubahan stok di log
5. Mengirim update ke aplikasi mobile

#### 4.2.8 Langkah 4.3: Kirim Notifikasi WhatsApp ke Pelanggan

Sistem secara otomatis mengirimkan pesan WhatsApp kepada pelanggan bahwa pesanan mereka telah dibatalkan karena melampaui batas waktu pembayaran.

Isi pesan WhatsApp:
1. Greeting kepada pelanggan dengan nama mereka
2. Nomor invoice pesanan yang dibatalkan
3. Alasan pembatalan (melampaui batas waktu 24 jam)
4. Total harga pesanan
5. Informasi bahwa stok sudah dikembalikan dan siap untuk dipesan kembali

#### 4.2.9 Langkah 4.4: Update Status di Aplikasi Mobile Secara Real-Time

Sistem mengirimkan event ke aplikasi mobile pelanggan agar status pesanan ter-update menjadi "Dibatalkan Sistem". Aplikasi mobile akan:

1. Mengupdate data pesanan di local storage
2. Refresh UI halaman riwayat transaksi
3. Menghentikan countdown timer pembayaran
4. Menampilkan notifikasi pembatalan kepada pelanggan

#### 4.2.10 Langkah 4.5: Log Pembatalan Otomatis untuk Audit

Sistem menambahkan record ke tabel log_aktivitas untuk mencatat pembatalan otomatis. Data yang dicatat:

1. ID Pesanan
2. Aksi yang dilakukan ("Pembatalan Otomatis")
3. Waktu pembatalan
4. Keterangan (alasan pembatalan karena timeout)

#### 4.2.11 Langkah 4.6: Catat Event Pembatalan untuk Analytics

Sistem menambahkan record ke tabel event_pembatalan untuk keperluan analytics dan reporting. Data yang dicatat:

1. ID Pesanan
2. Tipe pembatalan ("Timeout")
3. Waktu pembuatan pesanan
4. Waktu pembatalan pesanan
5. Durasi menunggu (berapa lama pesanan menunggu pembayaran sebelum dibatalkan)

Data analytics ini dapat digunakan untuk:
1. Mengetahui berapa banyak pesanan yang dibatalkan karena timeout per hari/minggu/bulan
2. Menganalisis rata-rata durasi menunggu pembayaran
3. Identifikasi tren dan pola pembatalan

#### 4.2.12 Langkah 5: Catat Hasil Job untuk Monitoring

Setelah semua pesanan kadaluwarsa diproses, sistem menambahkan record ke tabel log_scheduled_job untuk mencatat hasil eksekusi job. Data yang dicatat:

1. Nama job ("checkExpiredOrders")
2. Waktu eksekusi job (timestamp)
3. Jumlah pesanan yang dibatalkan
4. Status eksekusi job ("SUCCESS" atau "FAILED")

Log ini penting untuk monitoring dan troubleshooting. Admin atau ops dapat melihat apakah job berjalan dengan normal atau ada error.

#### 4.2.13 Langkah 6: Return Success Message

Job selesai dan menampilkan pesan success yang berisi jumlah pesanan yang telah dibatalkan. Contoh pesan: "Pengecekan pesanan kadaluwarsa selesai. 3 pesanan dibatalkan."

---

## 5. Algoritma Real-time Countdown Timer (Mobile)

### 5.1 Deskripsi Umum

Aplikasi mobile menampilkan countdown timer yang berkurang dari 24 jam untuk setiap pesanan. Timer ini berjalan di foreground dan menampilkan sisa waktu pembayaran secara real-time kepada pelanggan.

### 5.2 Penjelasan Alur Countdown Timer

#### 5.2.1 Langkah 1: Inisialisasi UI untuk Timer

Ketika halaman detail pesanan dibuka di aplikasi mobile, sistem menginisialisasi UI untuk menampilkan countdown timer. UI yang disiapkan meliputi:

1. Area untuk menampilkan waktu countdown (format: HH:MM:SS)
2. Progress bar atau visual indicator untuk menunjukkan progress waktu
3. Text informasi "Menghitung waktu pembayaran..."
4. Tombol untuk melakukan pembayaran atau aksi lainnya

#### 5.2.2 Langkah 2: Ambil Waktu Saat Ini

Aplikasi mengambil waktu saat ini dari sistem operasi device. Waktu ini digunakan sebagai baseline untuk perhitungan countdown.

#### 5.2.3 Langkah 3: Hitung Waktu yang Telah Berlalu

Aplikasi menghitung berapa lama pesanan sudah dibuat dengan rumus:

Waktu yang berlalu = Waktu Saat Ini - Waktu Pembuatan Pesanan

Waktu pembuatan pesanan diambil dari data pesanan yang diterima dari server.

#### 5.2.4 Langkah 4: Hitung Sisa Waktu

Aplikasi menghitung berapa lama sisa waktu pembayaran dengan rumus:

Sisa Waktu = 24 Jam - Waktu yang Berlalu

Sisa waktu ini ditampilkan kepada pelanggan dalam format jam:menit:detik.

#### 5.2.5 Langkah 5: Periksa Apakah Waktu Sudah Habis

Aplikasi memeriksa apakah sisa waktu <= 0 detik. Jika ya, berarti timer sudah mencapai 0 dan pesanan kadaluwarsa.

Jika waktu sudah habis, aplikasi melakukan:

1. Update UI untuk menampilkan "Pesanan Kadaluwarsa"
2. Disable tombol pembayaran dengan pesan "Waktu pembayaran sudah habis"
3. Tampilkan dialog error kepada pelanggan dengan informasi bahwa pesanan akan dibatalkan oleh sistem
4. Hentikan loop timer

#### 5.2.6 Langkah 6: Konversi Sisa Waktu ke Format Jam:Menit:Detik

Aplikasi mengkonversi sisa waktu (dalam satuan detik) ke format yang dapat dibaca manusia:

1. Jam = FLOOR(Sisa Waktu / 3600)
2. Menit = FLOOR((Sisa Waktu modulo 3600) / 60)
3. Detik = Sisa Waktu modulo 60

Setiap angka (jam, menit, detik) di-pad dengan 0 di depan agar selalu 2 digit. Contoh: 09:05:03 bukan 9:5:3.

Format display akhir: HH:MM:SS (contoh: 23:45:30)

#### 5.2.7 Langkah 7: Tentukan Warna Timer Berdasarkan Sisa Waktu

Aplikasi menentukan warna yang akan digunakan untuk menampilkan timer berdasarkan sisa waktu:

1. Jika sisa waktu > 1 jam (> 3600 detik): Warna HIJAU
   Kondisi ini menunjukkan masih ada waktu yang cukup banyak untuk membayar
2. Jika sisa waktu 10 menit sampai 1 jam (600-3600 detik): Warna ORANGE
   Kondisi ini menunjukkan harus segera membayar
3. Jika sisa waktu < 10 menit (< 600 detik): Warna MERAH
   Kondisi ini menunjukkan waktu pembayaran sudah hampir habis

Tujuan penggunaan warna adalah untuk memberikan visual cue kepada pelanggan tentang urgency/urgensi pembayaran.

#### 5.2.8 Langkah 8: Update UI dengan Countdown Terkini

Aplikasi melakukan update UI untuk menampilkan countdown terkini kepada pelanggan. Update yang dilakukan:

1. Update text timer dengan format jam:menit:detik terbaru
2. Update warna timer sesuai kondisi (hijau, orange, atau merah)
3. Update progress bar jika ada untuk menunjukkan progress countdown
4. Update timestamp terakhir update untuk referensi

#### 5.2.9 Langkah 9: Validasi Status Pesanan dengan Server Setiap 1 Menit

Setiap 1 menit (ketika detik = 0 dan menit habis terbagi dengan 1), aplikasi melakukan sync dengan server untuk mengecek status pesanan terkini.

Alasan melakukan sync setiap 1 menit adalah:

1. Jika admin sudah memvalidasi pembayaran, aplikasi dapat segera mengetahui dan menampilkan status "Pembayaran Dikonfirmasi"
2. Jika pesanan sudah dibatalkan oleh sistem atau admin, aplikasi dapat segera mengetahui dan menampilkan status "Pesanan Dibatalkan"
3. Sync setiap 1 menit adalah kompromi antara responsivitas dan efisiensi resource

Proses sync meliputi:

1. Aplikasi membuat HTTP GET request ke server endpoint: /api/orders/{invoiceID}/status
2. Server mengembalikan status pesanan terkini
3. Aplikasi menerima response dan melakukan pengecekan status

#### 5.2.10 Langkah 9.1: Handle Response Error

Jika aplikasi gagal menghubungi server (network error, timeout, server error), aplikasi melakukan:

1. Log error untuk debugging
2. Coba kembali pada sync 1 menit berikutnya
3. Tetap menampilkan countdown timer agar tidak mengganggu UX pengguna

#### 5.2.11 Langkah 9.2: Handle Status "Diproses"

Jika response dari server menunjukkan status pesanan sudah berubah menjadi "Diproses" (pembayaran sudah divalidasi oleh admin), aplikasi melakukan:

1. Update UI untuk menampilkan "Pembayaran Dikonfirmasi"
2. Hentikan countdown timer loop
3. Tampilkan success dialog kepada pelanggan dengan pesan:
   "Halo [Nama Pelanggan], Pembayaran Anda telah kami validasi. Pesanan sedang diproses dan akan segera dikirim. Terima kasih telah berbelanja."
4. Tampilkan tombol "OK" untuk menutup dialog
5. Redirect ke halaman detail pesanan atau halaman success

#### 5.2.12 Langkah 9.3: Handle Status "Dibatalkan Sistem"

Jika response dari server menunjukkan status pesanan sudah berubah menjadi "Dibatalkan Sistem" (pesanan dibatalkan karena timeout atau alasan lain), aplikasi melakukan:

1. Update UI untuk menampilkan "Pesanan Dibatalkan"
2. Hentikan countdown timer loop
3. Tampilkan error dialog kepada pelanggan dengan pesan:
   "Pesanan Anda sudah dibatalkan karena melampaui batas waktu pembayaran. Stok produk telah dikembalikan dan siap untuk dipesan kembali. Terima kasih."
4. Tampilkan tombol "OK" untuk menutup dialog
5. Redirect ke halaman katalog atau home screen

#### 5.2.13 Langkah 9.4: Handle Status "Dibatalkan Pelanggan"

Jika response dari server menunjukkan status pesanan sudah berubah menjadi "Dibatalkan Pelanggan" (pesanan dibatalkan oleh pelanggan sendiri), aplikasi melakukan:

1. Update UI untuk menampilkan "Pesanan Dibatalkan"
2. Hentikan countdown timer loop
3. Tampilkan info dialog kepada pelanggan dengan pesan:
   "Pesanan Anda telah dibatalkan. Stok produk telah dikembalikan."
4. Tampilkan tombol "OK" untuk menutup dialog
5. Redirect ke halaman riwayat transaksi

#### 5.2.14 Langkah 10: Sleep untuk Menghindari Excessive CPU Usage

Setelah setiap update UI, aplikasi melakukan sleep/delay selama 1 detik sebelum melakukan loop berikutnya.

Tujuan sleep adalah:

1. Mengurangi CPU usage device agar tidak membuat device panas atau baterai cepat habis
2. Mengurangi beban pada UI rendering engine
3. Membuat countdown terlihat natural dan smooth

#### 5.2.15 Langkah 11: Cleanup Timer Ketika Selesai

Ketika countdown timer selesai (baik karena waktu habis, pembayaran dikonfirmasi, atau pesanan dibatalkan), aplikasi melakukan cleanup:

1. Hentikan timer loop
2. Cancel semua pending HTTP requests
3. Remove event listeners yang terkait dengan timer
4. Clear resources yang digunakan timer dari memory
5. Dispose objects yang tidak lagi digunakan

Cleanup ini penting untuk menghindari memory leak di aplikasi mobile.

---

## 6. Algoritma Sinkronisasi Status ke Mobile

### 6.1 Deskripsi Umum

Ketika admin mengkonfirmasi pembayaran di web, status pesanan harus langsung ter-update di aplikasi mobile pelanggan secara real-time tanpa perlu refresh manual.

### 6.2 Penjelasan Alur Sinkronisasi Status

#### 6.2.1 Langkah 1: Ambil Data Pesanan Lengkap dari Database

Ketika admin melakukan validasi pembayaran, sistem mengambil data pesanan lengkap dari database untuk digunakan dalam proses sinkronisasi ke mobile.

Data yang diambil meliputi:
1. ID Pesanan (invoice ID)
2. Status pesanan lama
3. Nama pelanggan
4. Nomor WhatsApp
5. Nama produk
6. Total harga pesanan
7. Data lainnya yang relevan

#### 6.2.2 Langkah 2: Buat Payload Update dengan Informasi Lengkap

Sistem membuat paket data (payload) yang akan dikirim ke aplikasi mobile. Payload ini berisi semua informasi penting tentang update status pesanan:

1. Event Type: "ORDER_STATUS_CHANGED"
2. Invoice ID: Nomor invoice pesanan
3. Old Status: Status pesanan sebelum update
4. New Status: Status pesanan setelah update
5. Timestamp: Waktu update terjadi
6. Customer Name: Nama pelanggan
7. Product Name: Nama produk yang dipesan
8. Total Price: Total harga pesanan
9. Update Reason: Alasan update (contoh: "Admin validasi pembayaran")

Payload ini akan dikirim ke aplikasi mobile dalam format JSON.

#### 6.2.3 Langkah 3: Tentukan Channel Komunikasi

Sistem memilih channel komunikasi yang paling sesuai untuk mengirim update status ke aplikasi mobile. Ada 3 pilihan channel dengan priority:

1. Priority 1 - WebSocket:
   Digunakan jika aplikasi mobile memiliki koneksi WebSocket aktif dengan server. WebSocket memungkinkan komunikasi real-time dan instant.
   Keuntungan: Real-time, instant update tanpa delay
   Kekurangan: Memerlukan koneksi persistent dari mobile ke server

2. Priority 2 - Push Notification:
   Digunakan jika aplikasi mobile tidak memiliki koneksi WebSocket aktif atau mobile sedang dalam background.
   Push Notification dikirim melalui Firebase Cloud Messaging (FCM).
   Keuntungan: Berfungsi bahkan saat aplikasi dalam background atau non-active
   Kekurangan: Delay beberapa detik sampai notifikasi sampai ke device

3. Priority 3 - Message Queue:
   Digunakan sebagai fallback jika kedua metode di atas gagal.
   Update akan di-queue di message queue (RabbitMQ atau Redis) dan mobile app akan mengkonsumsi saat terhubung kembali.

#### 6.2.4 Langkah 3A: Pilihan Channel WebSocket

Jika sistem menggunakan WebSocket sebagai channel komunikasi:

1. Sistem mencari koneksi WebSocket yang aktif dari pelanggan (diidentifikasi dari nomor WhatsApp)
2. Jika koneksi ditemukan dan masih aktif (isConnected() = true):
   a. Sistem mengirim payload update langsung melalui WebSocket connection
   b. Proses pengiriman sangat cepat (milliseconds)
   c. Mobile app dapat langsung menerima dan update UI
   d. Sistem log pengiriman dengan status "SENT" dan channel "WebSocket"
3. Jika koneksi tidak ditemukan atau sudah disconnect:
   a. Sistem fallback ke Push Notification
   b. Memanggil fungsi sendPushNotification dengan payload yang sama

#### 6.2.5 Langkah 3B: Pilihan Channel Push Notification

Jika sistem menggunakan Push Notification sebagai channel komunikasi:

1. Sistem memanggil fungsi sendPushNotification dengan payload update status
2. Fungsi ini akan mengirim push notification melalui Firebase Cloud Messaging (FCM)
3. Push notification akan dikirim ke device mobile pelanggan
4. Jika aplikasi mobile dalam background, notification akan muncul di notification bar
5. Ketika pengguna tap notification, aplikasi akan membuka pesanan tersebut

#### 6.2.6 Langkah 3C: Pilihan Channel Message Queue

Jika sistem menggunakan Message Queue sebagai channel komunikasi:

1. Sistem publish update event ke message queue (RabbitMQ atau Redis)
2. Topic/Channel yang digunakan: "order_status_updates"
3. Mobile app akan subscribe ke topic ini dan mengkonsumsi events
4. Ketika mobile app connect ke server, akan mengkonsumsi events yang ter-queue
5. Jika ada multiple events, akan diproses satu per satu dalam order

#### 6.2.7 Langkah 4: Catat Event Update untuk Audit Trail

Setelah mengirim update ke mobile, sistem mencatat event ini di tabel log_status_update untuk keperluan audit dan troubleshooting.

Data yang dicatat:
1. ID Pesanan
2. Status lama (sebelum update)
3. Status baru (setelah update)
4. Waktu update
5. Metode pengiriman yang digunakan (WebSocket, Push Notification, atau Message Queue)

Log ini penting untuk:
1. Melacak kapan dan bagaimana status pesanan berubah
2. Troubleshooting jika ada masalah dengan update status
3. Compliance dan audit trail

#### 6.2.8 Langkah 5: Update Cache untuk Performa

Sistem melakukan update pada cache (Redis atau Memcached) agar data pesanan yang ter-cache tetap fresh dan sesuai dengan database.

Data pesanan di-cache agar:
1. Query ke database lebih cepat (cache hit)
2. Mengurangi beban pada database
3. Performa aplikasi meningkat

Cache yang di-update:
1. Cache dengan key "order_{invoiceID}" akan di-update dengan data pesanan terbaru

#### 6.2.9 Fungsi sendPushNotification

Fungsi ini menangani pengiriman push notification melalui Firebase Cloud Messaging (FCM):

Langkah 1: Ambil Device Token
- Sistem mengambil device token dari database
- Device token adalah identifier unique untuk setiap device yang menjalankan aplikasi mobile
- Device token disimpan saat aplikasi mobile pertama kali di-install

Langkah 2: Format Pesan untuk Push Notification
- Sistem membuat pesan notifikasi dengan format:
  - Title: "Update Pesanan [Invoice ID]"
  - Body: "Status pesanan berubah menjadi [Status Baru]"
  - Data: Payload update lengkap dalam format JSON

Langkah 3: Kirim ke Firebase Cloud Messaging (FCM)
- Sistem mengirim notifikasi ke FCM API
- FCM akan mengirim notifikasi ke device mobile melalui infrastructure FCM

Langkah 4: Handle Response dari FCM
- Jika response.status = "success":
  - Sistem log pengiriman berhasil
  - Notifikasi akan diterima device dalam beberapa detik
- Jika response.status = "failed":
  - Sistem log pengiriman gagal dengan error message
  - Implementasi retry logic untuk mencoba kembali

---

## 7. Algoritma Notifikasi WhatsApp

### 7.1 Deskripsi Umum

Ketika status pesanan berubah, sistem mengirimkan notifikasi WhatsApp kepada pelanggan secara otomatis melalui WhatsApp Gateway API.

### 7.2 Penjelasan Alur Notifikasi WhatsApp

#### 7.2.1 Langkah 1: Validasi Nomor WhatsApp

Sebelum mengirim notifikasi, sistem melakukan validasi bahwa nomor WhatsApp yang akan menerima notifikasi adalah valid.

Validasi meliputi:
1. Nomor tidak boleh kosong/null
2. Nomor harus numeric (hanya angka 0-9)
3. Nomor harus dalam format internasional Indonesia (diawali dengan 62)
4. Panjang nomor harus sesuai standar (minimal 10 digit setelah kode negara)

Jika validasi gagal, sistem mencatat warning dan menampilkan pesan error "Nomor WhatsApp tidak valid. Format: 62xxxxxxxxxx"

#### 7.2.2 Langkah 2: Format Nomor dengan Standar Internasional

Setelah validasi, sistem memformat nomor WhatsApp ke standar internasional untuk Indonesia:

1. Jika nomor diawali dengan "0", ganti dengan "62" (contoh: 081234567890 menjadi 6281234567890)
2. Jika nomor sudah diawali dengan "62", biarkan seperti itu
3. Jika nomor diawali dengan "+62", hapus karakter "+", sehingga menjadi "62..."

Hasil: Nomor WhatsApp dalam format 62XXXXXXXXXX

#### 7.2.3 Langkah 3: Tentukan Template Pesan Berdasarkan Tipe Notifikasi

Sistem memilih template pesan notifikasi berdasarkan tipe notifikasi yang akan dikirim. Ada beberapa tipe notifikasi:

Tipe 1: "Pembayaran Divalidasi"
- Dikirim saat admin melakukan validasi pembayaran
- Isi pesan:
  - Salam kepada pelanggan
  - Ucapan terima kasih telah berbelanja
  - Informasi pembayaran sudah divalidasi
  - Nomor invoice dan total harga
  - Informasi pesanan sedang diproses
  - Salam penutup

Tipe 2: "Pesanan Dibatalkan - Timeout"
- Dikirim saat pesanan dibatalkan karena melewati 24 jam tanpa pembayaran
- Isi pesan:
  - Salam kepada pelanggan
  - Informasi pesanan sudah dibatalkan
  - Alasan pembatalan (timeout 24 jam)
  - Nomor invoice dan total harga
  - Informasi stok sudah dikembalikan dan bisa dipesan lagi

Tipe 3: "Pesanan Dikirim"
- Dikirim saat pesanan dikirim ke pelanggan
- Isi pesan:
  - Salam kepada pelanggan
  - Informasi pesanan sudah dikirim
  - Nomor invoice dan total harga
  - Permintaan untuk menunggu kedatangan paket

Tipe 4: "Pesanan Selesai"
- Dikirim saat pesanan sudah sampai ke pelanggan
- Isi pesan:
  - Salam kepada pelanggan
  - Ucapan terima kasih
  - Permintaan untuk memberikan ulasan jika puas

#### 7.2.4 Langkah 4: Format Payload untuk WhatsApp Gateway API

Sistem membuat payload dalam format JSON yang akan dikirim ke WhatsApp Gateway API:

Isi payload:
1. phone_number: Nomor WhatsApp yang sudah di-format (62XXXXXXXXXX)
2. message: Teks pesan notifikasi
3. invoice_id: Nomor invoice pesanan
4. customer_name: Nama pelanggan
5. notification_type: Tipe notifikasi
6. priority: Priority pengiriman (HIGH, MEDIUM, atau LOW)
7. timestamp: Waktu saat payload dibuat

#### 7.2.5 Langkah 5: Kirim ke WhatsApp Gateway API

Sistem mengirim payload ke WhatsApp Gateway API menggunakan HTTP POST request.

Informasi request:
1. Endpoint: URL WhatsApp Gateway API (ditentukan saat konfigurasi)
2. Method: POST
3. Headers: Content-Type: application/json, Authorization: Bearer {API_KEY}
4. Body: Payload dalam format JSON

Response dari gateway akan berisi:
1. status: "success", "pending", atau "failed"
2. message_id: ID unik pesan dari gateway (jika berhasil)
3. error_code: Kode error (jika gagal)
4. error_message: Penjelasan error (jika gagal)

#### 7.2.6 Langkah 6A: Handle Response Status "SUCCESS"

Jika gateway mengirim response dengan status = "success":

1. Pesan berhasil dikirim ke gateway
2. Sistem mencatat log pengiriman di tabel log_whatsapp_notification dengan status "SENT"
3. Data yang dicatat:
   - ID Pesanan
   - Nomor WhatsApp tujuan
   - Tipe notifikasi
   - Waktu pengiriman
   - Message ID dari gateway
   - Status "SENT"
4. Sistem menampilkan pesan success: "Notifikasi WhatsApp berhasil dikirim (ID: {message_id})"

#### 7.2.7 Langkah 6B: Handle Response Status "PENDING"

Jika gateway mengirim response dengan status = "pending":

1. Gateway sedang memproses pesan, belum berhasil dikirim ke WhatsApp server
2. Sistem mencatat log pengiriman dengan status "PENDING"
3. Sistem queue pesan untuk retry otomatis dengan maksimal 3 kali percobaan
4. Sistem menampilkan pesan: "Notifikasi WhatsApp dalam antrian, akan dikirim segera"

#### 7.2.8 Langkah 6C: Handle Response Status "FAILED"

Jika gateway mengirim response dengan status = "failed":

1. Pengiriman pesan gagal (nomor invalid, network error, dll)
2. Sistem mencatat log pengiriman dengan status "FAILED"
3. Data yang dicatat:
   - ID Pesanan
   - Nomor WhatsApp tujuan
   - Tipe notifikasi
   - Waktu pengiriman
   - Status "FAILED"
   - Error code dan error message dari gateway
4. Sistem queue pesan untuk retry otomatis dengan maksimal 3 kali percobaan
5. Sistem log error untuk debugging
6. Sistem menampilkan pesan: "Notifikasi WhatsApp gagal, akan di-retry otomatis"

#### 7.2.9 Langkah 7: Implementasi Retry Otomatis

Jika pengiriman WhatsApp gagal atau pending, sistem melakukan retry otomatis dengan strategi exponential backoff:

Retry schedule:
1. Retry 1: Setelah 5 detik
2. Retry 2: Setelah 25 detik (5 * 5^1)
3. Retry 3: Setelah 125 detik (5 * 5^2)

Jika setelah 3 kali retry masih gagal:
1. Sistem mencatat event pengiriman ke tabel log_failed_notifications
2. Sistem log error untuk perhatian admin/ops
3. Sistem dapat mengirimkan alert/notifikasi ke admin bahwa ada pesan yang gagal dikirim

Strategi exponential backoff digunakan agar:
1. Tidak membebani gateway dengan terlalu banyak request sekaligus
2. Memberikan waktu untuk gateway/network untuk recover
3. Mengurangi overhead komunikasi

---

## 8. Flow Chart Lengkap Proses Konfirmasi Pembayaran

1. START: ADMIN VALIDASI PEMBAYARAN
2. ADMIN LIHAT DASHBOARD
3. ADMIN BUKA MENU "PESANAN MENUNGGU VERIFIKASI"
4. LIST PESANAN DENGAN STATUS "MENUNGGU PEMBAYARAN"
5. ADMIN PILIH 1 PESANAN
6. ADMIN CEK BUKTI TRANSFER DI REKENING/E-WALLET
7. VALIDASI JUMLAH TRANSFER
8. Apakah jumlah transfer sesuai?
   a. Jika YES: Lanjut ke step 9
   b. Jika NO: Tampilkan ERROR dan kembali
9. ADMIN KLIK "VALIDASI PEMBAYARAN"
10. SISTEM MELAKUKAN VALIDASI:
    a. Cek ID pesanan ada di database?
    b. Cek status pesanan = "Menunggu Pembayaran"?
    c. Cek waktu pembuatan < 24 jam?
    d. Cek duplikasi validasi sebelumnya?
11. Apakah semua validasi lolos?
    a. Jika YES: Lanjut ke step 12
    b. Jika NO: Tampilkan ERROR dan cancel
12. UPDATE STATUS PESANAN menjadi "Diproses"
13. LOG AKTIVITAS (WHO, WHEN, WHAT)
14. TRIGGER WHATSAPP NOTIFICATION ke pelanggan
15. TRIGGER MOBILE APP UPDATE (REAL-TIME)
16. STOP COUNTDOWN TIMER (di aplikasi mobile)
17. TAMPILKAN SUCCESS MESSAGE (di web admin)
18. TAMPILKAN SUCCESS MESSAGE (di aplikasi mobile)
19. END: PESANAN SIAP DIPROSES

---

## 9. Catatan Penting dalam Implementasi

### 9.1 Transaction Management

1. Semua operasi database harus dibungkus dalam transaction (BEGIN-COMMIT-ROLLBACK)
2. Jika ada error atau exception di tengah proses, seluruh perubahan harus di-rollback
3. Ini memastikan database tetap dalam kondisi yang konsisten dan tidak ada data yang half-updated
4. Contoh: Jika status berhasil di-update tapi log_aktivitas gagal, maka dua-duanya di-rollback

### 9.2 Error Handling

1. Setiap function/procedure harus mengembalikan success atau error dengan pesan yang jelas
2. Admin harus tahu dengan pasti apa yang terjadi jika proses validasi gagal
3. Pesan error harus informatif dan actionable (bukan hanya error code)
4. Log semua error untuk keperluan debugging dan troubleshooting

### 9.3 Audit Trail

1. Setiap aksi admin harus dicatat: siapa (ID admin), kapan (timestamp), apa (aksi yang dilakukan)
2. Data audit trail penting untuk keperluan compliance, legal, dan investigation
3. Simpan juga informasi teknis seperti IP address dan user agent device admin

### 9.4 Performance Optimization

1. Gunakan database index pada kolom yang sering di-query:
   a. index pada kolom id_pesanan (primary key)
   b. index pada kolom status_pesanan
   c. index pada kolom waktu_pembuatan
2. Cache data yang sering diakses menggunakan Redis atau Memcached
3. Implementasi lazy loading untuk list yang panjang
4. Query optimization: ambil hanya kolom yang dibutuhkan, jangan SELECT *

### 9.5 Security

1. Validasi semua input dari user/admin sebelum digunakan
2. Sanitize data sebelum disimpan ke database (prevent injection)
3. Gunakan parameterized queries untuk prevent SQL injection
4. Encrypt data sensitif (nomor WhatsApp) di database
5. Implementasi access control: hanya admin tertentu yang bisa validasi pembayaran
6. Rate limiting: cegah admin melakukan bulk validation dalam waktu singkat

### 9.6 Real-time Synchronization

1. Gunakan WebSocket atau Push Notification untuk update instant ke mobile app
2. Jangan rely hanya pada polling, karena terlalu boros resource dan tidak real-time
3. Implementasi fallback mechanism jika connection gagal
4. Implementasi reconnection logic jika connection disconnect

### 9.7 Testing Strategy

1. Unit test: test setiap function/procedure secara terpisah
2. Integration test: test flow lengkap dari awal sampai akhir
3. Load test: simulasi concurrent validations dari banyak admin untuk memastikan system scalable
4. Security test: test untuk vulnerability seperti SQL injection, XSS, etc
5. UAT (User Acceptance Test): test bersama actual users (admin) di staging environment

---

## 10. Data yang Harus Dicatat untuk Audit

Sistem harus mencatat data berikut untuk keperluan audit dan compliance:

### 10.1 Log Aktivitas Validasi Pembayaran

1. ID Pesanan (invoice ID)
2. ID Admin yang melakukan validasi
3. Waktu validasi (timestamp dengan zona waktu)
4. Status pesanan sebelum validasi
5. Status pesanan setelah validasi
6. Jumlah transfer yang divalidasi
7. Keterangan/catatan validasi
8. IP address admin yang melakukan validasi
9. User agent device admin
10. Result: Success atau Failed (jika failed, reason apa)

### 10.2 Log Pengembalian Stok

1. ID Produk
2. Stok sebelum pengembalian
3. Stok setelah pengembalian
4. Jumlah yang dikembalikan
5. Alasan pengembalian (dari pesanan mana)
6. Waktu pengembalian (timestamp)

### 10.3 Log Pembatalan Otomatis

1. ID Pesanan yang dibatalkan
2. Waktu pembuatan pesanan
3. Waktu pembatalan pesanan
4. Durasi menunggu (berapa lama pesanan menunggu sebelum dibatalkan)
5. Alasan pembatalan (timeout)
6. Stok yang di-restore
7. Notifikasi WhatsApp status (sent/failed)

### 10.4 Log Update Real-time ke Mobile

1. ID Pesanan
2. Status lama
3. Status baru
4. Channel komunikasi yang digunakan (WebSocket, Push Notification, Message Queue)
5. Waktu update dikirim
6. Status pengiriman (sent/failed)

### 10.5 Log Notifikasi WhatsApp

1. ID Pesanan
2. Nomor WhatsApp tujuan (ter-encrypt)
3. Tipe notifikasi (Pembayaran Divalidasi, Pesanan Dibatalkan, dst)
4. Waktu pengiriman
5. Status pengiriman (sent/pending/failed)
6. Message ID dari gateway
7. Error code dan error message (jika failed)
8. Retry attempts (jika di-retry)
