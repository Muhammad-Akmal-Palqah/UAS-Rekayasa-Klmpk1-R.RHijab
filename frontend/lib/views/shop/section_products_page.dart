import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../service/api_service.dart';
import '../../shared/rating_stars.dart';
import 'filter_view.dart';
import 'product_page.dart';

class SectionProductsPage extends StatefulWidget {
  const SectionProductsPage({
    super.key,
    required this.title,
    required this.sectionKey,
  });

  final String title;
  final String sectionKey;

  @override
  State<SectionProductsPage> createState() => _SectionProductsPageState();
}

class _SectionProductsPageState extends State<SectionProductsPage> {
  static const Color colorPink = Color(0xFFFFCCCC);
  static const Color colorGreen = Color(0xFFCCFFCC);
  static const Color colorBlue = Color(0xFFCCCCFF);
  static const Color darkText = Color(0xFF222222);
  static const Color lightGray = Color(0xFFF3F3F3);

  bool isLoading = true;
  bool isGridMode = false;
  bool isSearching = false;
  String searchQuery = '';
  String? errorMessage;
  List<Product> products = [];
  List<String> categories = ['Semua'];
  String selectedCategory = 'Semua';
  String currentSortLabel = 'Terbaru';

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSectionProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshSectionProducts() async {
    await _loadSectionProducts();
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

  Future<void> _loadSectionProducts([Map<String, dynamic>? filters]) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedProducts = await ApiService.fetchProducts(
        sortBy: filters?['sort']?.toString(),
        minPrice: filters != null && filters['min_price'] != null
            ? (filters['min_price'] as num).toDouble()
            : null,
        maxPrice: filters != null && filters['max_price'] != null
            ? (filters['max_price'] as num).toDouble()
            : null,
        color: filters?['color']?.toString(),
        size: filters?['size']?.toString(),
        category: filters?['kategori']?.toString(),
      );

      final filteredBySection = loadedProducts
          .where((p) => (p.homeSection ?? '') == widget.sectionKey)
          .toList();

      final filtered = _applyVariantFilters(
        filteredBySection,
        color: filters?['color']?.toString(),
        size: filters?['size']?.toString(),
      );

      final sortedProducts = _applySorting(
        filtered,
        filters?['sort']?.toString(),
      );

      final categorySet = <String>{};
      for (final product in filtered) {
        if (product.category.isNotEmpty) {
          categorySet.add(product.category);
        }
      }

      if (!mounted) return;
      setState(() {
        products = sortedProducts;
        categories = ['Semua', ...categorySet.toList()..sort()];
        selectedCategory = filters?['kategori']?.toString() ?? 'Semua';
        isLoading = false;
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
            : Text(
                widget.title,
                style: const TextStyle(
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
          onRefresh: _refreshSectionProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildCategoryChips(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildFilterBar(),
                ),
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
    );
  }

  Widget _buildFilterBar() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(builder: (_) => const FilterView()),
        );
        if (result != null) {
          setState(() {
            currentSortLabel = _sortLabelFromKey(result['sort']?.toString());
          });
          await _loadSectionProducts(result);
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
            const Icon(Icons.filter_list, color: darkText),
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

  Widget _buildProductArea() {
    final query = searchQuery.trim().toLowerCase();
    final filteredByCategory = selectedCategory == 'All'
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          query.isEmpty
              ? 'Belum ada produk untuk ${widget.title}.'
              : 'Produk tidak ditemukan untuk "$searchQuery".',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
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
                color: isSelected ? darkText : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.black12,
                ),
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
        return 'Terbaru';
    }
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
                    product.imageUrls.isNotEmpty
                        ? product.imageUrls.first
                        : product.imageUrl,
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (product.source == 'flutter' ? 'Flutter Admin' : ''),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: product.source == 'flutter'
                              ? Colors.deepPurple.withValues(alpha: 0.12)
                              : Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          (product.source == 'flutter'
                              ? 'Flutter Admin'
                              : 'Main DB'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: product.source == 'flutter'
                                ? Colors.deepPurple
                                : Colors.green.shade700,
                          ),
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
