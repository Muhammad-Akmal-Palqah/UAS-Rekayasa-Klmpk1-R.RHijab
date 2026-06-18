Merancang Alur Teknis Integrasi WhatsApp Gateway

Bagian ini menjelaskan bagaimana sistem Web dan Aplikasi Mobile Flutter terhubung dengan layanan pihak ketiga yaitu WhatsApp Gateway untuk mengirimkan notifikasi otomatis dan memfasilitasi komunikasi transaksi.

Alur Pengiriman Notifikasi dari Sistem Web

Sisi Sistem Berbasis Web (Aplikasi Admin)

1. Pemicu Validasi Transaksi
- Saat pengelola sistem selesai melakukan verifikasi manual terhadap bukti transfer dan mengubah status pesanan menjadi Diproses pada sistem web, aksi ini menjadi pemicu utama

2. Pengiriman Data ke Gateway
- Sistem web secara otomatis mengumpulkan data transaksi yang diperlukan, seperti nama pelanggan, nomor invoice, dan nomor WhatsApp tujuan yang tersimpan di database MySQL

3. Penerusan Pesan oleh Layanan Gateway
- Sistem web mengirimkan data tersebut ke server penyedia layanan WhatsApp Gateway melalui koneksi internet
- Server gateway kemudian memprosesnya dan mengirimkan pesan teks resmi ke nomor WhatsApp pelanggan

4. Format Pesan Otomatis
- Pesan yang diterima pelanggan akan berupa teks biasa yang berisi konfirmasi bahwa pembayaran telah divalidasi dan pesanan mereka sedang diteruskan ke pihak supplier

Sisi Sistem Berbasis Aplikasi Mobile (Flutter)

1. Pembaruan Status Real Time
- Aplikasi mobile Flutter menerima pembaruan data status dari database MySQL yang telah diubah oleh sistem web
- Tampilan menu riwayat di HP pelanggan ikut berubah secara otomatis menjadi Diproses

---

Alur Komunikasi Langsung dari Aplikasi Mobile

Sisi Sistem Berbasis Aplikasi Mobile (Flutter)

1. Pemicu Tombol Pesan
- Ketika pelanggan selesai memilih jilbab pada aplikasi mobile Flutter dan menekan tombol konfirmasi pesanan, sistem Flutter akan memanggil fungsi pengiriman data pesanan awal ke database MySQL

2. Pembuatan Tautan Otomatis
- Setelah nomor invoice sukses diterbitkan oleh database, aplikasi mobile Flutter menggunakan data nomor WhatsApp tujuan milik toko dan nomor invoice tersebut untuk menyusun sebuah tautan internet khusus

3. Pengalihan Aplikasi (Deep Linking)
- Aplikasi mobile Flutter secara otomatis mengarahkan pelanggan keluar dari aplikasi dan membuka aplikasi WhatsApp yang terpasang di HP pelanggan melalui tautan khusus yang sudah dibuat

4. Pengiriman Pesan Manual oleh Pelanggan
- Aplikasi WhatsApp di HP pelanggan akan terbuka dengan ruang obrolan langsung ke nomor toko R.R Hijab, lengkap dengan draf tulisan yang berisi detail pesanan dan nomor invoice
- Pelanggan hanya perlu menekan tombol kirim di WhatsApp untuk memulai percakapan

Sisi Sistem Berbasis Web (Arsip Data)

1. Pencatatan Log Transaksi
- Sistem web tetap mencatat bahwa invoice tersebut telah dialihkan menuju WhatsApp
- Pengelola dapat memantau pesanan mana saja yang sedang dalam tahap komunikasi chat melalui halaman dashboard web
