import 'package:flutter/material.dart';
import '../beranda/home_view.dart';
import '../favorit/favorit_page.dart';
import '../keranjang/cart_page.dart';
import '../profil/profile_page.dart';
import '../shared/app_bottom_nav.dart';
import 'filter_view.dart';
import 'product_page.dart';
import '../../models/product.dart';

class CatalogView extends StatefulWidget {
  const CatalogView({Key? key}) : super(key: key);

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  int _selectedIndex = 1;

  static const Color colorPink = Color(0xFFFFCCCC);
  static const Color colorGreen = Color(0xFFCCFFCC);
  static const Color colorBlue = Color(0xFFCCCCFF);
  static const Color darkText = Color(0xFF222222);
  static const Color lightGray = Color(0xFFF3F3F3);

  bool isGridMode = false;

  final List<String> categories = const [
    'T-shirts',
    'Crop tops',
    'Sleeveless',
    'Shirts',
    'Sweaters',
  ];

  final List<Map<String, dynamic>> products = const [
    {
      'title': 'Pullover',
      'brand': 'Mango',
      'price': '51\$',
      'rating': 4,
      'reviews': 3,
      'image':
          'https://images.pexels.com/photos/3748221/pexels-photo-3748221.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
    },
    {
      'title': 'Blouse',
      'brand': 'Dorothy Perkins',
      'price': '34\$',
      'rating': 0,
      'reviews': 0,
      'image':
          'https://images.pexels.com/photos/762020/pexels-photo-762020.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
    },
    {
      'title': 'T-shirt',
      'brand': 'LOST Ink',
      'price': '12\$',
      'rating': 5,
      'reviews': 10,
      'image':
          'https://images.pexels.com/photos/2983464/pexels-photo-2983464.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
    },
    {
      'title': 'Shirt',
      'brand': 'Topshop',
      'price': '51\$',
      'rating': 4,
      'reviews': 3,
      'image':
          'https://images.pexels.com/photos/857739/pexels-photo-857739.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Women’s tops',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: darkText),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 16),
              _buildFilterBar(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isGridMode ? _buildProductGrid() : _buildProductList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final String label = categories[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: index == 0 ? darkText : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: index == 0 ? Colors.white : darkText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FilterView()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.filter_list, color: darkText),
              const SizedBox(width: 10),
              const Text(
                'Filter',
                style: TextStyle(fontWeight: FontWeight.w600, color: darkText),
              ),
              const Spacer(),
              const Icon(Icons.swap_vert, color: Colors.black54),
              const SizedBox(width: 8),
              const Text(
                'Harga: rendah ke tinggi',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    isGridMode ? Icons.view_agenda : Icons.grid_view,
                    color: darkText,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      isGridMode = !isGridMode;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      children: products.asMap().entries.map((entry) {
        final int index = entry.key;
        final product = entry.value;
        final Color cardColor = index % 3 == 0
            ? colorPink
            : index % 3 == 1
            ? colorGreen
            : colorBlue;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildProductCard(product, cardColor),
        );
      }).toList(),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        final Color cardColor = index % 3 == 0
            ? colorPink
            : index % 3 == 1
            ? colorGreen
            : colorBlue;
        return _buildGridProductCard(product, cardColor);
      },
    );
  }

  Widget _buildGridProductCard(
    Map<String, dynamic> product,
    Color backgroundColor,
  ) {
    return GestureDetector(
      onTap: () {
        final prod = Product(
          id: product['title'] as String,
          title: product['title'] as String,
          price: product['price'] as String,
          priceValue:
              double.tryParse(
                (product['price'] as String).replaceAll(RegExp(r'[^0-9.]'), ''),
              ) ??
              0.0,
          description: '',
          imageUrl: product['image'] as String,
          category: '',
          rating: product['rating'] as int,
          averageRating: (product['rating'] as int).toDouble(),
          reviewCount: 0,
          color: Colors.grey,
          isFeatured: false,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductPage(product: prod)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Image.network(
                  product['image'] as String,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        Icons.star,
                        size: 14,
                        color: starIndex < (product['rating'] as int)
                            ? Colors.orange
                            : Colors.black12,
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product['price'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkText,
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

  Widget _buildProductCard(
    Map<String, dynamic> product,
    Color backgroundColor,
  ) {
    return GestureDetector(
      onTap: () {
        final prod = Product(
          id: product['title'] as String,
          title: product['title'] as String,
          price: product['price'] as String,
          priceValue:
              double.tryParse(
                (product['price'] as String).replaceAll(RegExp(r'[^0-9.]'), ''),
              ) ??
              0.0,
          description: '',
          imageUrl: product['image'] as String,
          category: '',
          rating: product['rating'] as int,
          averageRating: (product['rating'] as int).toDouble(),
          reviewCount: 0,
          color: Colors.grey,
          isFeatured: false,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductPage(product: prod)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Image.network(
                    product['image'] as String,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const SizedBox.shrink(),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          Icons.star,
                          size: 16,
                          color: starIndex < (product['rating'] as int)
                              ? Colors.orange
                              : Colors.black12,
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product['price'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
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
