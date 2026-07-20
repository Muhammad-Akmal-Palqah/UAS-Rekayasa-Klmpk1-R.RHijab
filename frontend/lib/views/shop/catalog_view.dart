import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../service/api_service.dart';
import '../../shared/rating_stars.dart';
import '../beranda/home_view.dart';
import '../favorit/favorit_page.dart';
import '../keranjang/cart_page.dart';
import '../profil/profile_page.dart';
import '../shared/app_bottom_nav.dart';
import 'filter_view.dart';
import 'product_page.dart';

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
  bool isSearching = false;
  String currentSortLabel = 'Harga: rendah ke tinggi';
  String selectedCategory = 'Semua';

  List<String> categories = ['Semua'];

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  List<Product> products = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  List<Product> _applyVariantFilters(
    List<Product> source, {
    String? color,
    String? size,
  }) {
    final selectedColor = color?.trim();
    final selectedSize = size?.trim();

    if ((selectedColor == null || selectedColor.isEmpty) &&
        (selectedSize == null || selectedSize.isEmpty)) {
      return source;
    }

    bool hasAnyMatchingStock = true;

    if (selectedColor != null && selectedColor.isNotEmpty) {
      hasAnyMatchingStock = source.any((product) {
        final hasColor = product.availableColors.any(
          (entry) => entry.toLowerCase() == selectedColor.toLowerCase(),
        );
        final stock = product.availableColorStocks[selectedColor] ?? 0;
        return hasColor && stock > 0;
      });
    }

    if (hasAnyMatchingStock &&
        selectedSize != null &&
        selectedSize.isNotEmpty) {
      hasAnyMatchingStock = source.any((product) {
        final hasSize = product.availableSizes.any(
          (entry) => entry.toLowerCase() == selectedSize.toLowerCase(),
        );
        final stock = product.availableSizeStocks[selectedSize] ?? 0;
        return hasSize && stock > 0;
      });
    }

    if (!hasAnyMatchingStock) {
      return source;
    }

    return source.where((product) {
      bool matches = true;

      if (selectedColor != null && selectedColor.isNotEmpty) {
        final hasColor = product.availableColors.any(
          (entry) => entry.toLowerCase() == selectedColor.toLowerCase(),
        );
        final stock = product.availableColorStocks[selectedColor] ?? 0;
        matches = matches && hasColor && stock > 0;
      }

      if (selectedSize != null && selectedSize.isNotEmpty) {
        final hasSize = product.availableSizes.any(
          (entry) => entry.toLowerCase() == selectedSize.toLowerCase(),
        );
        final stock = product.availableSizeStocks[selectedSize] ?? 0;
        matches = matches && hasSize && stock > 0;
      }

      return matches;
    }).toList();
  }

  List<Product> _applySorting(List<Product> source, String? sortKey) {
    final items = List<Product>.from(source);
    switch (sortKey) {
      case 'popular':
        items.sort(
          (a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0),
        );
        items.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case 'newest':
        items.sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
        break;
      case 'customer_review':
        items.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case 'price_high_to_low':
        items.sort((a, b) => b.priceValue.compareTo(a.priceValue));
        break;
      case 'price_low_to_high':
      default:
        items.sort((a, b) => a.priceValue.compareTo(b.priceValue));
        break;
    }
    return items;
  }

  Future<void> _loadProducts({Map<String, dynamic>? filters}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedProducts = await ApiService.fetchProducts(
        minPrice: filters?['min_price'] != null
            ? (filters!['min_price'] as num).toDouble()
            : null,
        maxPrice: filters?['max_price'] != null
            ? (filters!['max_price'] as num).toDouble()
            : null,
        color: filters?['color']?.toString(),
        size: filters?['size']?.toString(),
        category: filters?['kategori']?.toString(),
        sortBy: filters?['sort']?.toString(),
      );

      final categorySet = <String>{};
      for (final product in loadedProducts) {
        if (product.category.isNotEmpty) {
          categorySet.add(product.category);
        }
      }

      final filteredProducts = _applyVariantFilters(
        loadedProducts,
        color: filters?['color']?.toString(),
        size: filters?['size']?.toString(),
      );

      final sortedProducts = _applySorting(
        filteredProducts,
        filters?['sort']?.toString(),
      );

      if (!mounted) return;
      setState(() {
        products = sortedProducts;
        categories = ['Semua', ...categorySet.toList()];
        selectedCategory = filters?['kategori']?.toString() ?? 'Semua';
        isLoading = false;
        if (filters != null && filters['sort'] != null) {
          currentSortLabel = _sortLabelFromKey(filters['sort'].toString());
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

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
        title: isSearching
            ? _buildSearchField()
            : const Text(
                'Toko R.R Hijab',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: darkText,
            ),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  isSearching = false;
                  searchQuery = '';
                  searchController.clear();
                } else {
                  isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildCategoryChips(),
                const SizedBox(height: 16),
                _buildFilterBar(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        )
                      : _buildProductArea(),
                ),
                const SizedBox(height: 24),
              ],
            ),
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

  String _sortLabelFromKey(String? sortKey) {
    switch (sortKey) {
      case 'newest':
        return 'Terbaru';
      case 'price_low_to_high':
        return 'Harga: rendah ke tinggi';
      case 'price_high_to_low':
        return 'Harga: tinggi ke rendah';
      case 'popular':
        return 'Populer';
      case 'customer_review':
        return 'Ulasan pelanggan';
      default:
        return 'Harga: rendah ke tinggi';
    }
  }

  Widget _buildProductArea() {
    final query = searchQuery.trim().toLowerCase();
    final filteredByCategory = selectedCategory == 'Semua'
        ? products
        : products
              .where(
                (product) =>
                    product.category.toLowerCase() ==
                    selectedCategory.toLowerCase(),
              )
              .toList();
    final displayedProducts = query.isEmpty
        ? filteredByCategory
        : filteredByCategory.where((product) {
            final title = product.title.toLowerCase();
            final category = product.category.toLowerCase();
            final description = product.description.toLowerCase();
            return title.contains(query) ||
                category.contains(query) ||
                description.contains(query);
          }).toList();

    if (displayedProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            query.isEmpty
                ? 'Tidak ada produk tersedia.'
                : 'Produk tidak ditemukan untuk "$searchQuery".',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return isGridMode
        ? _buildProductGrid(displayedProducts)
        : _buildProductList(displayedProducts);
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Cari produk...',
        border: InputBorder.none,
      ),
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      textInputAction: TextInputAction.search,
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
          final bool isSelected = label == selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = label;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? darkText : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.black12,
                ),
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
                  color: isSelected ? Colors.white : darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
        onTap: () async {
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(builder: (_) => const FilterView()),
          );
          if (result != null) {
            setState(() {
              currentSortLabel = _sortLabelFromKey(result['sort']?.toString());
            });
            await _loadProducts(filters: result);
          }
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
              Text(
                currentSortLabel,
                style: const TextStyle(
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

  Widget _buildProductList(List<Product> productList) {
    return Column(
      children: productList.asMap().entries.map((entry) {
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

  Widget _buildProductGrid(List<Product> productList) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: productList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final product = productList[index];
        final Color cardColor = index % 3 == 0
            ? colorPink
            : index % 3 == 1
            ? colorGreen
            : colorBlue;
        return _buildGridProductCard(product, cardColor);
      },
    );
  }

  Widget _buildGridProductCard(Product product, Color backgroundColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductPage(product: product)),
          );
        },
        borderRadius: BorderRadius.circular(24),
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
                    product.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Category chip
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RatingStars(
                      rating: product.averageRating,
                      iconSize: 14,
                      filledColor: Colors.orange,
                      emptyColor: Colors.black12,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.price,
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
      ),
    );
  }

  Widget _buildProductCard(Product product, Color backgroundColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductPage(product: product)),
          );
        },
        borderRadius: BorderRadius.circular(24),
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
                      product.imageUrls.isNotEmpty
                          ? product.imageUrls.first
                          : product.imageUrl,
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
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RatingStars(
                        rating: product.averageRating,
                        iconSize: 16,
                        filledColor: Colors.orange,
                        emptyColor: Colors.black12,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.price,
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
      ),
    );
  }
}
