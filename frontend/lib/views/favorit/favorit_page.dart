import 'package:flutter/material.dart';
import 'package:frontend/main.dart';

import '../../models/order.dart';
import '../../service/api_service.dart';
import '../beranda/home_view.dart';
import '../keranjang/cart_page.dart';
import '../profil/profile_page.dart';
import '../shared/app_bottom_nav.dart';
import '../shop/catalog_view.dart';
import 'order_detail_page.dart';

const Color kDominant = Color(0xFFFFCCCC);
const Color kAccentGreen = Color(0xFFCCFFCC);
const Color kAccentBlue = Color(0xFFCCCCFF);

class FavoritPage extends StatefulWidget {
  const FavoritPage({super.key});

  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage>
    with WidgetsBindingObserver, RouteAware {
  int _selectedIndex = 3;
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ordersFuture = ApiService.fetchUserOrders();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _refreshOrders();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshOrders();
    }
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = ApiService.fetchUserOrders();
    });
    await _ordersFuture;
  }

  // removed _isProcessed as mapping is done via _statusLabel

  Color _statusColor(String? status) {
    final label = _statusLabel(status);
    if (label == 'Sudah Dibayar') {
      return const Color(0xFF2E7D32);
    }
    if (label == 'Pembayaran Gagal') {
      return const Color(0xFFD32F2F);
    }
    if (label == 'Menunggu Pembayaran') {
      return const Color(0xFFFFA000);
    }
    // Fallback
    return const Color(0xFFFFA000);
  }

  String _statusLabel(String? status) {
    final normalized = (status ?? '').trim().toLowerCase();

    if (normalized.isEmpty) return 'Menunggu Pembayaran';

    // Paid/settlement
    if (normalized.contains('sudah dibayar') ||
        normalized.contains('settlement') ||
        normalized.contains('paid')) {
      return 'Sudah Dibayar';
    }

    // Pending / waiting for payment
    if (normalized.contains('pending') ||
        normalized.contains('menunggu pembayaran') ||
        normalized.contains('belum bayar')) {
      return 'Menunggu Pembayaran';
    }

    // Expired / cancelled / denied / failed
    if (normalized.contains('expire') ||
        normalized.contains('cancel') ||
        normalized.contains('deny') ||
        normalized.contains('gagal')) {
      return 'Pembayaran Gagal';
    }

    // Shipped / processing
    if (normalized.contains('dikirim') || normalized.contains('diproses')) {
      return 'Dikirim';
    }

    // Default
    return 'Menunggu Pembayaran';
  }

  bool _canDeleteOrder(String? status) {
    final label = _statusLabel(status);
    return label == 'Sudah Dibayar' || label == 'Dikirim';
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

  Future<void> _deleteOrder(Order order) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus pesanan'),
        content: Text(
          'Hapus pesanan #${order.id} yang sudah dibayar? Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ApiService.deleteOrder(order.id);
      if (!mounted) return;
      await _refreshOrders();
      messenger.showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dihapus')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menghapus pesanan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pesanan',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Pesanan',
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await _refreshOrders();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Daftar pesanan diperbarui')),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshOrders,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FutureBuilder<List<Order>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 320,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SizedBox(
                    height: 320,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final orders = (snapshot.data ?? []).toList();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    children: orders.map((order) {
                      final statusColor = _statusColor(order.statusPembayaran);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderDetailPage(order: order),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      order.namaProduk.isNotEmpty
                                          ? order.namaProduk
                                          : 'Produk tanpa nama',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _statusLabel(order.statusPembayaran),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (_canDeleteOrder(order.statusPembayaran))
                                    IconButton(
                                      tooltip: 'Hapus pesanan',
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => _deleteOrder(order),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pesanan #${order.id}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                order.alamatPengiriman.isNotEmpty
                                    ? order.alamatPengiriman
                                    : 'Alamat belum tersedia',
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (order.namaPelanggan.isNotEmpty ||
                                  (order.metodePembayaran ?? '').isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (order.namaPelanggan.isNotEmpty)
                                        Text(
                                          'Nama penerima: ${order.namaPelanggan}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      if ((order.metodePembayaran ?? '')
                                          .isNotEmpty)
                                        Text(
                                          'Pembayaran: ${_paymentMethodLabel(order.metodePembayaran)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Qty: ${order.jumlahBeli}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Rp ${order.totalHarga.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (order.createdAt.isNotEmpty)
                                Text(
                                  'Dibuat: ${order.createdAt}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3) {
            setState(() {
              _selectedIndex = index;
            });
            return;
          }

          final destination = <Widget>[
            const HomeView(),
            const CatalogView(),
            const CartPage(),
            const FavoritPage(),
            const ProfilePage(),
          ][index];

          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
        },
      ),
    );
  }
}
