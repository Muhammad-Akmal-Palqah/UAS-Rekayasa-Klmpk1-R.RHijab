import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/models/order.dart';
import 'package:frontend/views/favorit/order_detail_page.dart';

void main() {
  testWidgets('shows pay now button for pending order', (tester) async {
    final order = Order(
      id: 42,
      namaPelanggan: 'Budi',
      email: 'budi@example.com',
      noWhatsapp: '08123456789',
      alamatPengiriman: 'Jl. Merdeka No. 1',
      idProduk: 7,
      namaProduk: 'Hijab Premium',
      jumlahBeli: 1,
      totalHarga: 125000,
      metodePembayaran: 'gopay',
      statusPembayaran: 'Menunggu Pembayaran',
      linkFoto: '',
      createdAt: '2026-07-15',
    );

    await tester.pumpWidget(MaterialApp(home: OrderDetailPage(order: order)));
    await tester.pumpAndSettle();

    expect(find.text('Bayar Sekarang'), findsOneWidget);
  });
}
