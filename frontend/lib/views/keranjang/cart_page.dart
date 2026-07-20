import 'package:flutter/material.dart';
import '../favorit/favorit_page.dart';
import '../profil/profile_page.dart';
import '../shared/app_bottom_nav.dart';
import '../shop/catalog_view.dart';
import '../beranda/home_view.dart';
import 'cart_constants.dart';
import '../../service/cart_service.dart';
import 'cart_item_tile.dart';
import 'cart_summary.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _selectedIndex = 2;

  late List<CartItemData> _items = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _refreshCart() async {
    await _loadCart();
  }

  Future<void> _loadCart() async {
    final loaded = await CartService.loadCart();
    setState(() {
      _items = loaded;
    });
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity < 1) return;
    setState(() {
      _items[index] = _items[index].copyWith(quantity: quantity);
      CartService.saveCart(_items);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      CartService.saveCart(_items);
    });
  }

  int get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.unitPrice * item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F6),
      appBar: AppBar(
        backgroundColor: kCartPink,
        elevation: 0,
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCart,
        child: _items.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_items.isNotEmpty)
            SafeArea(
              child: CartSummary(
                subtotal: _subtotal,
                shipping: 18000,
                discount: _items.fold<int>(
                  0,
                  (sum, item) =>
                      sum +
                      (item.originalPrice - item.unitPrice) * item.quantity,
                ),
                onCheckout: () {
                  debugPrint('CartSummary checkout button pressed');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const CheckoutPage(),
                    ),
                  );
                },
              ),
            ),
          AppBottomNav(
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index == 2) {
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
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return ListView(
      padding: const EdgeInsets.only(top: 20, bottom: 18),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSummaryHeader(),
        ),
        const SizedBox(height: 18),
        ...List.generate(
          _items.length,
          (index) => CartItemTile(
            item: _items[index],
            onQuantityChanged: (value) => _updateQuantity(index, value),
            onRemove: () => _removeItem(index),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    final itemCount = _items.length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCartPink,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$itemCount Produk dalam keranjang',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Periksa kembali pesananmu sebelum checkout',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: Colors.black87,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 96,
                color: Colors.black26,
              ),
              const SizedBox(height: 20),
              const Text(
                'Keranjangmu kosong',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tambahkan produk favoritmu untuk dapat lanjut checkout.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
