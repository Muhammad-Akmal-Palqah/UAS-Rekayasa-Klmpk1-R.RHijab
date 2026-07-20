class Address {
  // ✅ ID alamat unik (saat ini di-generate lokal di Flutter, belum di-sync ke database backend)
  final String id;

  // ✅ Nama lengkap penerima alamat (dari form input user atau dari users table di backend)
  final String fullName;

  // ✅ Alamat lengkap jalan/nomor (dari orders.alamat_pengiriman di database unified)
  final String address;

  // ✅ Kota/kabupaten tujuan pengiriman
  final String city;

  // ✅ Provinsi/negara bagian tujuan
  final String state;

  // ✅ Kode pos tujuan pengiriman
  final String zipCode;

  // ✅ Negara tujuan pengiriman (default: Indonesia)
  final String country;

  // ✅ Flag apakah ini alamat default (untuk quick checkout)
  bool isDefault;
  // Nomor telepon penerima (opsional)
  String? phone;

  // Koordinat lokasi (opsional)
  double? latitude;
  double? longitude;

  Address({
    required this.id,
    required this.fullName,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.isDefault = false,
    this.phone,
    this.latitude,
    this.longitude,
  });

  // 📦 Konversi Address object ke Map (untuk simpan ke SharedPreferences / local storage)
  Map<String, dynamic> toMap() {
    return {
      // ✅ ID address untuk reference lokal
      'id': id,
      // ✅ Nama penerima alamat
      'fullName': fullName,
      // ✅ Alamat lengkap (akan dikirim ke orders.alamat_pengiriman di database backend)
      'address': address,
      // ✅ Kota tujuan
      'city': city,
      // ✅ Provinsi/state tujuan
      'state': state,
      // ✅ Kode pos
      'zipCode': zipCode,
      // ✅ Negara (untuk international shipping support di masa depan)
      'country': country,
      // ✅ Flag default address
      'isDefault': isDefault,
      // Nomor telepon
      'phone': phone,
      // Koordinat
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // 🏭 Factory constructor: Parse Map dari SharedPreferences ke Address object
  // Digunakan saat restore saved addresses dari local storage
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      // ✅ Parse ID dari map (generate jika tidak ada)
      id: map['id'] ?? '',
      // ✅ Parse nama penerima
      fullName: map['fullName'] ?? '',
      // ✅ Parse alamat lengkap
      address: map['address'] ?? '',
      // ✅ Parse kota
      city: map['city'] ?? '',
      // ✅ Parse state/provinsi
      state: map['state'] ?? '',
      // ✅ Parse kode pos
      zipCode: map['zipCode'] ?? '',
      // ✅ Parse negara
      country: map['country'] ?? '',
      // ✅ Parse flag default (default: false jika tidak ada)
      isDefault: map['isDefault'] ?? false,
      phone: map['phone'],
      latitude: map['latitude'] is num
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: map['longitude'] is num
          ? (map['longitude'] as num).toDouble()
          : null,
    );
  }

  Address copyWith({
    String? id,
    String? fullName,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
    String? phone,
    double? latitude,
    double? longitude,
  }) {
    return Address(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
