import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/service/api_service.dart';

void main() {
  group('ApiService order payload', () {
    test('includes recipient name, phone, and formatted shipping address', () {
      final body = ApiService.buildOrderRequestBody(
        namaPelanggan: 'Budi Santoso',
        email: 'budi@example.com',
        noWhatsapp: '081234567890',
        alamatPengiriman:
            'Jl. Mawar No. 10, Bandung, Jawa Barat 40123, Indonesia',
        ukuran: 'M',
        metodePengiriman: 'JNE',
        catatan: 'Pesanan via aplikasi mobile',
        metodePembayaran: 'qris',
        jumlahBeli: 2,
        totalHarga: 200000,
      );

      expect(body['nama_pelanggan'], 'Budi Santoso');
      expect(body['no_whatsapp'], '081234567890');
      expect(
        body['alamat_pengiriman'],
        'Jl. Mawar No. 10, Bandung, Jawa Barat 40123, Indonesia',
      );
      expect(body['metode_pembayaran'], 'qris');
    });
  });
}
