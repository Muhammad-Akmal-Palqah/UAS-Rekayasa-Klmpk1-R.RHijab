import 'package:flutter/material.dart';
import '../favorit/favorit_page.dart';
import '../keranjang/cart_page.dart';
import '../profil/profile_page.dart';
import '../shop/catalog_view.dart';
import '../shop/product_page.dart';
import '../shop/section_products_page.dart';
import '../shared/app_bottom_nav.dart';
import '../chat_page.dart';
import '../../service/api_service.dart';
import '../../service/auth_service.dart';
import '../../shared/rating_stars.dart';
import '../../models/product.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // Warna custom
  final Color primaryPink = Color(0xFFffcccc);
  final Color lightGreen = Color(0xFFccffcc);
  final Color lightBlue = Color(0xFFccccff);

  bool _isLoading = true;
  List<Product> _allProducts = [];
  List<Product> _koleksiTerbaru = [];
  List<Product> _produkTerbaru = [];
  List<Product> _promoSpesial = [];
  // Flags to detect whether admin explicitly selected products for each section
  bool _koleksiSelectedByAdmin = false;
  bool _produkSelectedByAdmin = false;
  bool _promoSelectedByAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryPink,
        elevation: 0,
        title: const Text(
          'RR Hijab',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Section dengan Carousel
              _buildBannerSection(),

              // Koleksi Terbaru (gambar saja)
              _buildSectionTitle('Koleksi Terbaru', 'Lihat semua', () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SectionProductsPage(
                      title: 'Koleksi Terbaru',
                      sectionKey: 'koleksi',
                    ),
                  ),
                );
              }),
              SizedBox(
                height: 140,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : (_koleksiSelectedByAdmin
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _koleksiTerbaru.length,
                              itemBuilder: (context, index) {
                                final p = _koleksiTerbaru[index];
                                return _buildImageOnlyCard(
                                  p,
                                  index,
                                  large: true,
                                );
                              },
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Belum ada produk yang dipilih untuk Koleksi Terbaru',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            )),
              ),

              const SizedBox(height: 12),

              // Produk Terbaru
              _buildSectionTitle('Produk Terbaru', 'Lihat semua', () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SectionProductsPage(
                      title: 'Produk Terbaru',
                      sectionKey: 'terbaru',
                    ),
                  ),
                );
              }),
              SizedBox(
                height: 250,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : (_produkSelectedByAdmin
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _produkTerbaru.length,
                              itemBuilder: (context, index) {
                                return _buildNewProductCard(
                                  _produkTerbaru[index],
                                  index,
                                );
                              },
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Belum ada produk yang dipilih untuk Produk Terbaru',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            )),
              ),

              const SizedBox(height: 24),

              // Sale Section
              _buildSectionTitle('Promo Spesial', 'Lihat semua', () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SectionProductsPage(
                      title: 'Promo Spesial',
                      sectionKey: 'promo',
                    ),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : (_promoSelectedByAdmin
                          ? Column(
                              children: List.generate(
                                _promoSpesial.length,
                                (index) => _buildSaleProductCard(
                                  _promoSpesial[index],
                                  index,
                                ),
                              ),
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Belum ada produk yang dipilih untuk Promo Spesial',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            )),
              ),

              const SizedBox(height: 24),

              // Street Clothes Banner
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              _selectedIndex = index;
            });
            return;
          }

          final destination = <Widget>[
            const SizedBox(),
            const CatalogView(),
            const CartPage(),
            const FavoritPage(),
            const ProfilePage(),
          ][index];

          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => destination));

          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ApiService.fetchProducts(sortBy: 'newest');
      // Prioritaskan pilihan admin via `home_section` (koleksi/terbaru/promo)
      final koleksi = products
          .where((p) => (p.homeSection ?? '') == 'koleksi')
          .toList();
      final terbaru = products
          .where((p) => (p.homeSection ?? '') == 'terbaru')
          .toList();
      final promo = products
          .where((p) => (p.homeSection ?? '') == 'promo')
          .toList();

      // Fallback (only used if you later want to enable fallbacks)
      final fallbackKoleksi = products.where((p) => p.isFeatured).toList();
      final fallbackPromo = products
          .where((p) => p.badge != null && p.badge!.isNotEmpty)
          .toList();
      final sortedByCreated = List<Product>.from(products)
        ..sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

      final hasKoleksi = koleksi.isNotEmpty;
      final hasTerbaru = terbaru.isNotEmpty;
      final hasPromo = promo.isNotEmpty;

      setState(() {
        _allProducts = products;
        // If admin explicitly selected items for a section, show them.
        // Otherwise leave the list empty and show a message in the UI.
        _koleksiSelectedByAdmin = hasKoleksi;
        _produkSelectedByAdmin = hasTerbaru;
        _promoSelectedByAdmin = hasPromo;

        _koleksiTerbaru = hasKoleksi ? koleksi : [];
        _produkTerbaru = hasTerbaru ? terbaru : [];
        _promoSpesial = hasPromo ? promo : [];

        // Keep loading false
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // ignore: avoid_print
      print('Gagal memuat produk: $e');
    }
  }

  Widget _buildImageOnlyCard(Product product, int index, {bool large = false}) {
    final bg = [lightGreen, lightBlue, primaryPink][index % 3];
    final width = large ? 220.0 : 120.0;
    final imageSize = large ? 160.0 : 100.0;
    final borderRadius = large ? 20.0 : 12.0;

    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ProductPage(product: product))),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child:
              (product.imageUrls.isNotEmpty
                      ? product.imageUrls.first
                      : product.imageUrl)
                  .isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius - 4),
                  child: Image.network(
                    product.imageUrls.isNotEmpty
                        ? product.imageUrls.first
                        : product.imageUrl,
                    fit: BoxFit.cover,
                    width: imageSize,
                    height: imageSize,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 48),
                  ),
                )
              : const Icon(Icons.image, size: 48),
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    final userName = AuthService.currentUser?.username ?? 'Pengguna';
    return Container(
      color: primaryPink,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;
          final leftContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SELAMAT DATANG $userName DI APLIKASI R.R HIJAB',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Temukan koleksi hijab paling trendi, promo spesial, dan pengalaman belanja yang nyaman di aplikasi kami.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD94C73),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CatalogView()),
                      );
                    },
                    child: const Text(
                      'Lihat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChatPage()),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text(
                      'Chat Bot',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
          final rightContent = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBannerFeatureCard(
                title: 'Koleksi Terbaru',
                subtitle: 'Pilihan terbaik setiap hari',
                color: lightGreen,
              ),
              const SizedBox(height: 12),
              _buildBannerFeatureCard(
                title: 'Promo Spesial',
                subtitle: 'Diskon hanya untuk Anda',
                color: lightBlue,
              ),
            ],
          );
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [leftContent, const SizedBox(height: 20), rightContent],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: leftContent),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: rightContent),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBannerFeatureCard({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    String viewAll,
    VoidCallback onViewAll,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              viewAll,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewProductCard(Product product, int index) {
    final colors = [lightGreen, lightBlue, primaryPink];
    final bgColor = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductPage(product: product)),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: bgColor.withOpacity(0.7),
                ),
                child: Center(
                  child:
                      (product.imageUrls.isNotEmpty
                              ? product.imageUrls.first
                              : product.imageUrl)
                          .isNotEmpty
                      ? Image.network(
                          product.imageUrls.isNotEmpty
                              ? product.imageUrls.first
                              : product.imageUrl,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 48),
                        )
                      : const Icon(Icons.image, size: 60),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleProductCard(Product product, int index) {
    final colors = [lightGreen, lightBlue, primaryPink];
    final bgColor = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductPage(product: product)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 120,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                color: bgColor.withOpacity(0.7),
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Center(
                    child:
                        (product.imageUrls.isNotEmpty
                                ? product.imageUrls.first
                                : product.imageUrl)
                            .isNotEmpty
                        ? Image.network(
                            product.imageUrls.isNotEmpty
                                ? product.imageUrls.first
                                : product.imageUrl,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image, size: 50),
                          )
                        : const Icon(Icons.image, size: 50),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.badge ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (product.promoPrice != null) ...[
                          Text(
                            'Rp${product.promoPrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else ...[
                          Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        RatingStars(
                          rating: product.averageRating,
                          iconSize: 14,
                          filledColor: Colors.orange,
                          emptyColor: Colors.black12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          product.reviewCount == 0
                              ? 'Belum ada review'
                              : '${product.averageRating.toStringAsFixed(1)} (${product.reviewCount})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
