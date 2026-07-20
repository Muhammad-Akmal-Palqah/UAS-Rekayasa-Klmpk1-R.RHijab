import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/app_bottom_nav.dart';
import '../beranda/home_view.dart';
import '../shop/catalog_view.dart';
import '../favorit/favorit_page.dart';
import '../profil/profile_page.dart';
import '../../models/address.dart';
import '../../models/product.dart';
import '../../service/api_service.dart';
import '../../service/address_service.dart';
import '../../service/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_constants.dart';
import 'shipping_address_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _selectedIndex = 2;
  String _shippingMethod = 'JNE';
  String? _selectedPaymentMethod; // 'gopay' atau 'qris'
  // WhatsApp field removed per design (no longer collected here)

  Address? _selectedAddress;
  List<Address> _addresses = [];
  bool _isLoadingAddresses = true;
  bool _isSubmitting = false;
  List<CartItemData> _cartItems = [];
  Map<String, dynamic>? _paymentData;
  Timer? _statusPollingTimer;
  int? _currentOrderId;
  String? _currentTransactionId;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _loadCartItems();
  }

  @override
  void dispose() {
    _statusPollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    final saved = await AddressService.loadAddresses();
    if (!mounted) return;
    setState(() {
      _addresses = saved;
      _selectedAddress = _addresses.isNotEmpty
          ? _addresses.first
          : Address(
              id: '1',
              fullName: 'Jane Doe',
              address: '3 Newbridge Court',
              city: 'Chino Hills',
              state: 'California',
              zipCode: '91709',
              country: 'United States',
              isDefault: true,
            );
      _isLoadingAddresses = false;
    });
  }

  Future<void> _loadCartItems() async {
    final loaded = await CartService.loadCart();
    debugPrint('CheckoutPage: loaded cart items count=${loaded.length}');
    for (var item in loaded) {
      debugPrint('CheckoutPage: cart item=${item.toJson()}');
    }
    if (!mounted) return;
    setState(() {
      _cartItems = loaded;
    });
  }

  int get _totalQuantity => calculateTotalQuantity(_cartItems);
  int get _orderTotal => calculateSubtotal(_cartItems);
  int get _deliveryFee {
    switch (_shippingMethod) {
      case 'JNE':
        return 15000;
      case 'J&T Express':
        return 17000;
      case 'GoSend':
        return 25000;
      default:
        return 0;
    }
  }

  int get _summaryTotal => _orderTotal + _deliveryFee;

  final List<Map<String, String>> _shippingOptions = const [
    {'label': 'JNE', 'time': '1-2 hari', 'fee': '15000'},
    {'label': 'J&T Express', 'time': '2-3 hari', 'fee': '17000'},
    {'label': 'GoSend', 'time': '2 jam - 1 hari', 'fee': '25000'},
  ];

  void _onBottomNavTap(int index) {
    if (index == _selectedIndex) return;

    final destination = <Widget>[
      const HomeView(),
      const CatalogView(),
      const CheckoutPage(),
      const FavoritPage(),
      const ProfilePage(),
    ][index];

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
  }

  void _navigateToAddressSelection() async {
    if (_isLoadingAddresses) return;

    final result = await Navigator.of(context).push<Address>(
      MaterialPageRoute(
        builder: (context) => ShippingAddressPage(
          selectedAddress: _selectedAddress,
          existingAddresses: _addresses.isNotEmpty ? _addresses : null,
        ),
      ),
    );

    if (result != null) {
      final saved = await AddressService.loadAddresses();
      if (!mounted) return;
      setState(() {
        _selectedAddress = result;
        _addresses = saved;
      });
    }
  }

  String _buildFullAddress(Address address) {
    final parts = <String>[
      address.address.trim(),
      address.city.trim(),
      address.state.trim(),
      address.zipCode.trim(),
      address.country.trim(),
    ].where((value) => value.isNotEmpty).toList();

    return parts.join(', ');
  }

  Future<void> _applyVariantStockUpdates(List<CartItemData> cartItems) async {
    for (final item in cartItems) {
      final productIndex = productCatalog.indexWhere(
        (p) => p.id == item.productId,
      );
      if (productIndex < 0) {
        continue;
      }

      final product = productCatalog[productIndex];
      final updatedProduct = product.applyVariantPurchase(
        size: item.size,
        color: item.colorName,
        quantity: item.quantity,
      );
      productCatalog[productIndex] = updatedProduct;
    }
  }

  Future<void> _submitOrder() async {
    if (_selectedAddress == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final cartItems = await CartService.loadCart();
      if (cartItems.isEmpty) {
        throw ApiException(
          'Keranjang kosong. Tambahkan produk sebelum checkout.',
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('auth_email') ?? '';
      final name = (_selectedAddress?.fullName ?? '').trim().isNotEmpty
          ? _selectedAddress!.fullName.trim()
          : (prefs.getString('auth_name') ?? '').trim();
      final phone = (_selectedAddress?.phone ?? '').trim().isNotEmpty
          ? _selectedAddress!.phone!.trim()
          : (prefs.getString('auth_phone') ?? '').trim();

      if (email.isEmpty) {
        throw ApiException(
          'Email pengguna tidak ditemukan. Silakan login ulang.',
        );
      }

      if (name.isEmpty) {
        throw ApiException('Nama penerima tidak ditemukan.');
      }

      if (phone.isEmpty) {
        throw ApiException(
          'Nomor HP penerima belum tersedia. Silakan isi nomor HP pada alamat pengiriman.',
        );
      }

      final alamatPengiriman = _buildFullAddress(_selectedAddress!);
      final String paymentNote =
          'Metode pembayaran: ' +
          (_selectedPaymentMethod == 'gopay' ? 'GoPay' : 'QRIS');

      final items = <Map<String, dynamic>>[];
      for (var i = 0; i < cartItems.length; i++) {
        final item = cartItems[i];
        final int itemTotal = item.unitPrice * item.quantity;
        final int totalWithShipping = i == 0
            ? itemTotal + _deliveryFee
            : itemTotal;
        items.add({
          'product_id': int.tryParse(item.productId) ?? item.productId,
          'jumlah_beli': item.quantity,
          'total_harga': totalWithShipping,
          'ukuran': item.size.isNotEmpty ? item.size : null,
          'warna': item.colorName.isNotEmpty ? item.colorName : null,
        });
      }
      debugPrint('CheckoutPage: bulk order items=$items');

      final orderIds = await ApiService.submitBulkOrder(
        namaPelanggan: name,
        email: email,
        noWhatsapp: phone,
        alamatPengiriman: alamatPengiriman,
        metodePengiriman: _shippingMethod,
        catatan: paymentNote,
        metodePembayaran: _selectedPaymentMethod!,
        items: items,
      );

      debugPrint('CheckoutPage: submitted bulk order ids=$orderIds');

      if (orderIds.isEmpty) {
        throw ApiException(
          'Pesanan gagal diproses. Tidak ada ID pesanan yang dikembalikan.',
        );
      }

      _currentOrderId = orderIds.last;

      await _applyVariantStockUpdates(cartItems);
      await CartService.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pesanan berhasil dikirim. Silakan cek detail pesanan untuk melanjutkan pembayaran.',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      debugPrint('CheckoutPage ApiException: ${e.message}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      debugPrint('CheckoutPage unknown error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _bayarSekarang() async {
    if (_paymentData == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token pembayaran tidak tersedia.')),
      );
      return;
    }

    final snapToken = _paymentData!['snap_token']?.toString();
    if (snapToken == null || snapToken.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token pembayaran tidak ditemukan.')),
      );
      return;
    }

    final paymentUrl =
        'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';
    final uri = Uri.parse(paymentUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak bisa membuka halaman pembayaran.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka halaman pembayaran: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: kCartPink,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            _buildSectionTitle('Alamat pengiriman'),
            const SizedBox(height: 14),
            _buildCard(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedAddress?.fullName ??
                                    'Memuat alamat...',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_selectedAddress?.isDefault == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Utama',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _navigateToAddressSelection,
                          child: const Text(
                            'Ubah',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_selectedAddress?.address ?? '-'),
                    if (_selectedAddress?.phone != null &&
                        _selectedAddress!.phone!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'HP: ${_selectedAddress!.phone}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _selectedAddress != null
                          ? '${_selectedAddress!.city}, ${_selectedAddress!.state} ${_selectedAddress!.zipCode}, ${_selectedAddress!.country}'
                          : '-',
                    ),
                  ],
                ),
              ),
            ),
            // WhatsApp input removed from checkout page
            const SizedBox(height: 24),
            _buildSectionTitle('Pembayaran'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentMethodCard(
                    label: 'GoPay',
                    method: 'gopay',
                    iconUrl:
                        'https://seeklogo.com/images/G/gopay-logo-96E1A87B97-seeklogo.com.png',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPaymentMethodCard(
                    label: 'QRIS',
                    method: 'qris',
                    iconUrl:
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/QRIS_Logo.svg/768px-QRIS_Logo.svg.png',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Metode pengiriman'),
            const SizedBox(height: 14),
            Column(
              children: _shippingOptions.map((option) {
                final isSelected = option['label'] == _shippingMethod;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _shippingMethod = option['label']!;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red.shade50 : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.grey.shade300,
                        width: isSelected ? 2 : 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['label']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.red : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option['time']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${_formatAmount(int.parse(option['fee']!))}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Colors.red.shade600,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            _buildOrderRow('Jumlah item:', '$_totalQuantity pcs'),
            const SizedBox(height: 10),
            _buildOrderRow('Pesanan:', 'Rp ${_formatAmount(_orderTotal)}'),
            const SizedBox(height: 10),
            _buildOrderRow('Pengiriman:', 'Rp ${_formatAmount(_deliveryFee)}'),
            const SizedBox(height: 10),
            _buildOrderRow(
              'Ringkasan:',
              'Rp ${_formatAmount(_summaryTotal)}',
              valueStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitOrder,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'KIRIM PESANAN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildOrderRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style:
              valueStyle ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
        ),
      ],
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r"(\d)(?=(\d{3})+(?!\d))"),
      (match) => '${match[1]}.',
    );
  }

  Widget _buildPaymentMethodCard({
    required String label,
    required String method,
    required String iconUrl,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            // Payment method icon/logo
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.network(
                  iconUrl,
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      method == 'gopay' ? Icons.payment : Icons.qr_code_2,
                      size: 36,
                      color: Colors.grey.shade600,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog() {
    if (_paymentData == null || _paymentData!['snap_token'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pembayaran tidak valid.')),
      );
      return;
    }

    final paymentType = _paymentData!['payment_type'] as String?;
    final snapToken = _paymentData!['snap_token']?.toString();
    final rawAmount = _paymentData!['amount'];
    final amount = rawAmount is int
        ? rawAmount
        : rawAmount is String
        ? int.tryParse(rawAmount) ?? _summaryTotal
        : rawAmount is num
        ? rawAmount.toInt()
        : _summaryTotal;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status text
                  Text(
                    'Menunggu Pembayaran...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lanjutkan pembayaran melalui halaman Snap Midtrans.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),

                  // Payment content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          paymentType == 'gopay'
                              ? Icons.payment
                              : Icons.payment,
                          size: 52,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Anda akan diarahkan ke halaman pembayaran Midtrans.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Amount
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rp ${_formatAmount(amount ?? 0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Open payment button
                  if (snapToken != null && snapToken.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.open_in_new,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Buka Halaman Pembayaran',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _bayarSekarang,
                      ),
                    )
                  else
                    const SizedBox(height: 0),

                  const SizedBox(height: 12),

                  // Check status button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.red.shade600,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (_currentOrderId != null) {
                          _startPaymentStatusPolling(_currentOrderId!);
                        }
                      },
                      child: Text(
                        'Cek Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startPaymentStatusPolling(int orderId) {
    _statusPollingTimer?.cancel();

    int errorCount = 0;

    _statusPollingTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      try {
        final statusResponse = await ApiService.checkPaymentStatus(
          orderId: orderId.toString(),
        );

        if (!mounted) {
          timer.cancel();
          return;
        }

        final statusData = statusResponse['data'] as Map<String, dynamic>?;
        final status = statusData?['status_pembayaran'] as String?;

        debugPrint('Payment status check: $status');

        if (status == 'Sudah Dibayar') {
          timer.cancel();
          _statusPollingTimer = null;

          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          _showPaymentSuccessDialog();
          return;
        }

        if (status == null || status.isEmpty) {
          errorCount += 1;
        } else {
          errorCount = 0;
        }

        if (errorCount >= 3) {
          timer.cancel();
          _statusPollingTimer = null;

          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Koneksi terputus. Silakan coba lagi nanti.'),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error checking payment status: $e');
        errorCount += 1;

        if (errorCount >= 3) {
          timer.cancel();
          _statusPollingTimer = null;

          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Koneksi terputus. Silakan coba lagi nanti.'),
            ),
          );
        }
      }
    });

    if (!mounted) return;
    _showPaymentPollingDialog(orderId);
  }

  void _showPaymentPollingDialog(int orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Memproses Pembayaran...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  'Jangan tutup aplikasi. Kami sedang mengecek status pembayaran Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                Text(
                  'Order ID: $orderId',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Pesanan Anda telah dikonfirmasi. Terima kasih telah berbelanja!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const FavoritPage()),
                    );
                  },
                  child: const Text(
                    'Lihat Riwayat Pemesanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentFailedDialog(String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.cancel,
                    size: 64,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pembayaran Gagal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Status: ${reason.replaceAll('_', ' ').toUpperCase()}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    // Reset state untuk retry
                    setState(() {
                      _paymentData = null;
                      _currentOrderId = null;
                      _selectedPaymentMethod = null;
                    });
                  },
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
