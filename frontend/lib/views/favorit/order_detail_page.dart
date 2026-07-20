import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/order.dart';
import '../../service/api_service.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _isProcessingPayment = false;

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  String _paymentMethodLabel(String? method) {
    final normalized = (method ?? '').trim().toLowerCase();

    if (normalized.contains('gopay')) {
      return 'GoPay';
    }
    if (normalized.contains('qris')) {
      return 'QRIS';
    }
    if (normalized.contains('shopeepay')) {
      return 'ShopeePay';
    }

    return (method ?? '').trim().isNotEmpty ? method!.trim() : 'Tidak dipilih';
  }

  String _normalizePaymentType(String? method) {
    final normalized = (method ?? '').trim().toLowerCase();
    if (normalized.contains('gopay')) {
      return 'gopay';
    }
    if (normalized.contains('qris')) {
      return 'qris';
    }
    if (normalized.contains('shopeepay')) {
      return 'shopeepay';
    }
    return normalized;
  }

  bool _shouldShowPayButton(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized.isEmpty ||
        normalized.contains('menunggu') ||
        normalized.contains('pending');
  }

  Future<void> _payNow() async {
    final paymentType = _normalizePaymentType(widget.order.metodePembayaran);
    if (paymentType.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metode pembayaran belum tersedia.')),
      );
      return;
    }

    if (widget.order.id <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID pesanan tidak valid.')));
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final paymentResponse = await ApiService.initiatePayment(
        orderId: widget.order.id,
        paymentType: paymentType,
      );
      final snapToken = paymentResponse['snap_token']?.toString();

      if (snapToken == null || snapToken.isEmpty) {
        throw ApiException('Token pembayaran tidak ditemukan dari server.');
      }

      final paymentUrl =
          'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';
      final uri = Uri.parse(paymentUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Tidak bisa membuka halaman pembayaran.');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka pembayaran: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan #${widget.order.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.order.namaProduk.isNotEmpty
                          ? widget.order.namaProduk
                          : 'Produk tanpa nama',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Qty: ${widget.order.jumlahBeli}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                        Text(
                          _formatCurrency(widget.order.totalHarga),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if ((widget.order.ukuran ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Ukuran: ${widget.order.ukuran}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                    if ((widget.order.warna ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Warna: ${widget.order.warna}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                    if ((widget.order.metodePengiriman ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Pengiriman: ${widget.order.metodePengiriman}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
                title: 'Pilihan produk',
              ),
              const SizedBox(height: 14),
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.namaPelanggan.isNotEmpty
                          ? widget.order.namaPelanggan
                          : 'Nama penerima belum tersedia',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.order.alamatPengiriman.isNotEmpty
                          ? widget.order.alamatPengiriman
                          : 'Alamat belum tersedia',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    if (widget.order.noWhatsapp.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'No. HP: ${widget.order.noWhatsapp}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
                title: 'Alamat yang dipilih',
              ),
              const SizedBox(height: 14),
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Status',
                      widget.order.statusPembayaran.isNotEmpty
                          ? widget.order.statusPembayaran
                          : 'Menunggu Pembayaran',
                    ),
                    _buildInfoRow(
                      'Pembayaran',
                      _paymentMethodLabel(widget.order.metodePembayaran),
                    ),
                    if (widget.order.createdAt.isNotEmpty)
                      _buildInfoRow('Dibuat', widget.order.createdAt),
                    if ((widget.order.catatan ?? '').isNotEmpty)
                      _buildInfoRow('Catatan', widget.order.catatan!),
                    if (_shouldShowPayButton(
                      widget.order.statusPembayaran,
                    )) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessingPayment ? null : _payNow,
                          icon: _isProcessingPayment
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.payment_outlined),
                          label: Text(
                            _isProcessingPayment
                                ? 'Memproses...'
                                : 'Bayar Sekarang',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB23B5B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                title: 'Informasi pesanan',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
