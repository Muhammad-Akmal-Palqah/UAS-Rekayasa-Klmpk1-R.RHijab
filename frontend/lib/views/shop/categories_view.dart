import 'package:flutter/material.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({Key? key}) : super(key: key);

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Warna custom
  static const Color colorPink = Color(0xFFFFCCCC); // ffcccc
  static const Color colorGreen = Color(0xFFCCFFCC); // ccffcc
  static const Color colorBlue = Color(0xFFCCCCFF); // ccccff
  static const Color primaryPink = Color(0xFFEE3333); // untuk banner
  static const Color darkText = Color(0xFF333333);
  static const Color lightGray = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: darkText,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryPink,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Women'),
                  Tab(text: 'Kids'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Summer Sales Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: primaryPink,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  Text(
                    'SUMMER SALES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Up to 50% off',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Category Cards with Tab View
            SizedBox(
              height: 600,
              child: TabBarView(
                controller: _tabController,
                children: [_buildCategoryContent(), _buildCategoryContent()],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCategoryContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // New Section with pink background
          _buildCategoryCard(
            title: 'New',
            backgroundColor: colorPink,
            imagePath: null,
          ),
          const SizedBox(height: 16),
          // Clothes Section with green background
          _buildCategoryCard(
            title: 'Clothes',
            backgroundColor: colorGreen,
            imagePath: null,
          ),
          const SizedBox(height: 16),
          // Shoes Section with blue background
          _buildCategoryCard(
            title: 'Shoes',
            backgroundColor: colorBlue,
            imagePath: null,
          ),
          const SizedBox(height: 16),
          // Accessories Section
          _buildCategoryCard(
            title: 'Accessories',
            backgroundColor: colorPink,
            imagePath: null,
          ),
          const SizedBox(height: 32),
          // Choose Category Section
          _buildChooseCategorySection(),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required Color backgroundColor,
    String? imagePath,
  }) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Title Section
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ),
          ),
          // Image/Placeholder Section
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 48, color: Colors.black26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChooseCategorySection() {
    List<String> categories = [
      'Tops',
      'Shirts & Blouses',
      'Cardigans & Sweaters',
      'Knitwear',
      'Blazers',
      'Outerwear',
      'Pants',
      'Jeans',
      'Shorts',
      'Skirts',
      'Dresses',
    ];

    return Column(
      children: [
        // View All Items Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: primaryPink,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Text(
              'VIEW ALL ITEMS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Choose Category Header
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Choose category',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const SizedBox(height: 16),
        // Category List
        ...categories.asMap().entries.map((entry) {
          int idx = entry.key;
          String category = entry.value;
          Color bgColor;

          // Rotate through the three colors
          if (idx % 3 == 0) {
            bgColor = colorPink;
          } else if (idx % 3 == 1) {
            bgColor = colorGreen;
          } else {
            bgColor = colorBlue;
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryPink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Bag',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
