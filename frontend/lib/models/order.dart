class Order {
  // ✅ ID unik dari database unified (tabel orders.id_order)
  final int id;

  // ✅ Nama lengkap pembeli dari orders.nama_pelanggan
  final String namaPelanggan;

  // ✅ Email pembeli dari database unified (orders.email - bisa diisi dari user auth)
  final String email;

  // ✅ Nomor WhatsApp pembeli dari orders.no_whatsapp (untuk contact buyer)
  final String noWhatsapp;

  // ✅ Alamat pengiriman pesanan dari orders.alamat_pengiriman (unified database)
  final String alamatPengiriman;

  // ✅ ID produk yang dipesan dari orders.id_produk (FK ke products.id_produk)
  final int idProduk;

  // ✅ Nama produk yang ditampilkan dari JOIN dengan products table (unified)
  final String namaProduk;

  // ✅ Jumlah item yang dibeli dari orders.jumlah_beli
  final int jumlahBeli;

  // ✅ Total harga pesanan dari orders.total_harga (dalam Rupiah)
  final double totalHarga;

  // ✅ Ukuran produk yang dipilih dari orders.ukuran (baru dari unified database)
  final String? ukuran;

  final String? warna;

  // ✅ Metode pengiriman (JNE, Grab, etc) dari orders.metode_pengiriman (baru dari unified database)
  final String? metodePengiriman;

  // ✅ Catatan tambahan dari pembeli dari orders.catatan (BARU - baru dari unified database)
  final String? catatan;

  // ✅ Metode pembayaran yang dipilih saat checkout, jika tersedia di backend
  final String? metodePembayaran;

  // ✅ Status pembayaran dari orders.status_pembayaran (enum di backend: Menunggu Pembayaran, Sudah Dibayar, Pembayaran Gagal)
  final String statusPembayaran;

  // ✅ Gambar produk dari products.link_foto (URL lengkap dari backend)
  final String linkFoto;

  // ✅ Tanggal pembuatan order dari orders.created_at (ISO 8601 format)
  final String createdAt;

  Order({
    required this.id,
    required this.namaPelanggan,
    required this.email,
    required this.noWhatsapp,
    required this.alamatPengiriman,
    required this.idProduk,
    required this.namaProduk,
    required this.jumlahBeli,
    required this.totalHarga,
    this.ukuran,
    this.warna,
    this.metodePengiriman,
    this.catatan,
    this.metodePembayaran,
    required this.statusPembayaran,
    required this.linkFoto,
    required this.createdAt,
  });

  static String? _extractPaymentMethod(dynamic value) {
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final normalized = trimmed.toLowerCase();
    if (normalized.contains('gopay')) {
      return 'gopay';
    }
    if (normalized.contains('qris')) {
      return 'qris';
    }
    if (normalized.contains('shopeepay')) {
      return 'shopeepay';
    }

    return trimmed;
  }

  // 🏭 Factory constructor: Parse JSON response dari backend Laravel unified database
  // Response struktur: {id, nama_pelanggan, email, no_whatsapp, alamat_pengiriman, id_produk, nama_produk, jumlah_beli, total_harga, ukuran, metode_pengiriman, catatan, status_pembayaran, link_foto, created_at}
  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse order ID dari 'id' field (atau 'id_order' jika menggunakan field name lama)
    final orderId = json['id'] is num
        ? (json['id'] as num).toInt()
        : int.tryParse(json['id']?.toString() ?? '') ??
              (json['id_order'] is num
                  ? (json['id_order'] as num).toInt()
                  : int.tryParse(json['id_order']?.toString() ?? '') ?? 0);

    // ✅ Parse nama pelanggan dari database field 'nama_pelanggan'
    final namaPelanggan = json['nama_pelanggan'] as String? ?? '';

    // ✅ Parse email pembeli dari database field 'email' (baru dari unified database)
    final email = json['email'] as String? ?? '';

    // ✅ Parse nomor WhatsApp dari database field 'no_whatsapp'
    final noWhatsapp = json['no_whatsapp'] as String? ?? '';

    // ✅ Parse alamat pengiriman dari database field 'alamat_pengiriman'
    final alamatPengiriman = json['alamat_pengiriman'] as String? ?? '';

    // ✅ Parse ID produk dari database field 'id_produk' (FK ke products table)
    final idProduk = json['id_produk'] is num
        ? (json['id_produk'] as num).toInt()
        : int.tryParse(json['id_produk']?.toString() ?? '') ?? 0;

    // ✅ Parse nama produk dari JOIN result dengan products table di backend
    final namaProduk = json['nama_produk'] as String? ?? 'Produk R.R Hijab';

    // ✅ Parse jumlah beli dari database field 'jumlah_beli'
    final jumlahBeli = json['jumlah_beli'] is num
        ? (json['jumlah_beli'] as num).toInt()
        : int.tryParse(json['jumlah_beli']?.toString() ?? '') ?? 1;

    // ✅ Parse total harga dari database field 'total_harga' (dalam Rupiah, bisa String atau Number)
    final totalHarga = json['total_harga'] is String
        ? double.tryParse(json['total_harga'] as String) ?? 0.0
        : (json['total_harga'] as num?)?.toDouble() ?? 0.0;

    // ✅ Parse ukuran produk dari database field 'ukuran' (baru dari unified database)
    final ukuran = json['ukuran'] as String?;

    final warna = json['warna'] as String?;

    // ✅ Parse metode pengiriman dari database field 'metode_pengiriman' (baru dari unified database)
    final metodePengiriman = json['metode_pengiriman'] as String?;

    // ✅ Parse catatan pembeli dari database field 'catatan' (BARU - tambahan dari unified database)
    // Field ini berisi catatan tambahan dari buyer, bisa berisi metode pembayaran + custom notes
    final catatan = json['catatan'] as String?;

    // ✅ Parse metode pembayaran dari field backend jika ada, atau fallback dari catatan
    final metodePembayaran =
        _extractPaymentMethod(json['metode_pembayaran']) ??
        _extractPaymentMethod(catatan);

    // ✅ Parse status pembayaran dari database field 'status_pembayaran' (enum: Menunggu Pembayaran, Sudah Dibayar, dll)
    final statusPembayaran = json['status_pembayaran'] as String? ?? '';

    // ✅ Parse link gambar produk dari database field 'link_foto' (URL lengkap dari backend)
    final linkFoto = json['link_foto'] as String? ?? '';

    // ✅ Parse tanggal pembuatan order dari database field 'created_at' (ISO 8601 format)
    final createdAt = json['created_at'] as String? ?? '';

    // 🏗️ Construct Order object dengan semua field dari database unified
    return Order(
      id: orderId,
      namaPelanggan: namaPelanggan,
      email: email,
      noWhatsapp: noWhatsapp,
      alamatPengiriman: alamatPengiriman,
      idProduk: idProduk,
      namaProduk: namaProduk,
      jumlahBeli: jumlahBeli,
      totalHarga: totalHarga,
      ukuran: ukuran,
      warna: warna,
      metodePengiriman: metodePengiriman,
      catatan: catatan,
      metodePembayaran: metodePembayaran,
      statusPembayaran: statusPembayaran,
      linkFoto: linkFoto,
      createdAt: createdAt,
    );
  }
}
