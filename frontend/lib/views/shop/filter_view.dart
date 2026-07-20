import 'package:flutter/material.dart';
import '../../service/api_service.dart';

class FilterView extends StatefulWidget {
  const FilterView({Key? key}) : super(key: key);

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  static const Color colorPink = Color(0xFFFFCCCC);
  static const Color darkText = Color(0xFF222222);
  static const Color background = Color(0xFFF7F7F7);

  RangeValues priceRange = const RangeValues(0, 0);
  double minPrice = 0;
  double maxPrice = 0;
  int selectedColorIndex = 0;
  int selectedSizeIndex = 0;
  int selectedCategoryIndex = 0;
  int selectedSortIndex = 3;

  List<String> colorOptions = ['Semua'];
  List<String> sizeOptions = ['Semua'];
  List<String> categories = ['Semua'];

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    try {
      final products = await ApiService.fetchProducts();
      final categorySet = <String>{};
      final colorSet = <String>{};
      final sizeSet = <String>{};
      double lowest = double.infinity;
      double highest = 0;

      for (final p in products) {
        if (p.category.isNotEmpty) categorySet.add(p.category);
        for (final rawColor in p.availableColors) {
          final colorValue = rawColor.trim();
          if (colorValue.isNotEmpty) colorSet.add(colorValue);
        }
        for (final rawSize in p.availableSizes) {
          final sizeValue = rawSize.trim();
          if (sizeValue.isNotEmpty) sizeSet.add(sizeValue);
        }
        if (p.priceValue < lowest) lowest = p.priceValue;
        if (p.priceValue > highest) highest = p.priceValue;
      }

      setState(() {
        categories = ['Semua', ...categorySet.toList()..sort()];
        colorOptions = ['Semua', ...colorSet.toList()..sort()];
        sizeOptions = ['Semua', ...sizeSet.toList()..sort()];
        minPrice = lowest == double.infinity ? 0 : lowest;
        maxPrice = highest;
        priceRange = RangeValues(minPrice, maxPrice);
      });
    } catch (_) {
      setState(() {
        categories = ['Semua'];
        colorOptions = ['Semua'];
        sizeOptions = ['Semua'];
      });
    }
  }

  void _resetFilters() {
    setState(() {
      priceRange = RangeValues(minPrice, maxPrice);
      selectedColorIndex = 0;
      selectedSizeIndex = 0;
      selectedCategoryIndex = 0;
      selectedSortIndex = 3;
    });
  }

  String _sortKeyFromIndex(int index) {
    switch (index) {
      case 0:
        return 'popular';
      case 1:
        return 'newest';
      case 2:
        return 'customer_review';
      case 3:
        return 'price_low_to_high';
      case 4:
        return 'price_high_to_low';
      default:
        return 'price_low_to_high';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: darkText,
      ),
    );
  }

  String _formatRupiah(double value) {
    final amount = value.round();
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'Rp$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Filter',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Rentang harga'),
                    const SizedBox(height: 12),
                    _buildPriceCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Warna'),
                    const SizedBox(height: 12),
                    _buildColorSelector(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Ukuran'),
                    const SizedBox(height: 12),
                    _buildSizeSelector(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Kategori'),
                    const SizedBox(height: 12),
                    _buildCategorySelector(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Urutkan'),
                    const SizedBox(height: 12),
                    _buildSortBySelector(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: darkText),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _resetFilters,
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: darkText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final payload = <String, dynamic>{
                          'kategori': categories[selectedCategoryIndex],
                          'sort': _sortKeyFromIndex(selectedSortIndex),
                        };

                        if (selectedColorIndex > 0)
                          payload['color'] = colorOptions[selectedColorIndex];
                        if (selectedSizeIndex > 0)
                          payload['size'] = sizeOptions[selectedSizeIndex];
                        if (priceRange.start > minPrice)
                          payload['min_price'] = priceRange.start;
                        if (priceRange.end < maxPrice)
                          payload['max_price'] = priceRange.end;

                        Navigator.pop(context, payload);
                      },
                      child: const Text(
                        'Terapkan',
                        style: TextStyle(
                          color: darkText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  Widget _buildPriceCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatRupiah(priceRange.start),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _formatRupiah(priceRange.end),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorPink,
              inactiveTrackColor: colorPink.withAlpha(89),
              thumbColor: colorPink,
              overlayColor: colorPink.withAlpha(51),
              trackHeight: 6,
            ),
            child: RangeSlider(
              values: priceRange,
              min: minPrice,
              max: maxPrice <= minPrice ? minPrice + 1 : maxPrice,
              divisions: maxPrice > minPrice ? 10 : null,
              labels: RangeLabels(
                _formatRupiah(priceRange.start),
                _formatRupiah(priceRange.end),
              ),
              onChanged: (values) => setState(
                () => priceRange = RangeValues(
                  values.start.clamp(minPrice, maxPrice),
                  values.end.clamp(minPrice, maxPrice),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(colorOptions.length, (index) {
            final bool isSelected = selectedColorIndex == index;
            final label = colorOptions[index];
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 12.0),
              child: GestureDetector(
                onTap: () => setState(() => selectedColorIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorPink.withValues(alpha: 0.25)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? colorPink : Colors.black12,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: sizeOptions.asMap().entries.map((entry) {
          final int index = entry.key;
          final String size = entry.value;
          final bool selected = selectedSizeIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedSizeIndex = index),
            child: Container(
              width: index == 0 ? 80 : 64,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? colorPink : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? colorPink : Colors.black12,
                  width: 1.5,
                ),
              ),
              child: Text(
                size,
                style: const TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: categories.asMap().entries.map((entry) {
          final int index = entry.key;
          final String category = entry.value;
          final bool selected = selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedCategoryIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? colorPink : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? Colors.red.shade400 : Colors.black12,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: selected ? darkText : darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortBySelector() {
    final sortOptions = [
      'Populer',
      'Terbaru',
      'Ulasan pelanggan',
      'Harga: rendah ke tinggi',
      'Harga: tinggi ke rendah',
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: sortOptions.asMap().entries.map((entry) {
          final int index = entry.key;
          final String option = entry.value;
          final bool selected = selectedSortIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedSortIndex = index),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: selected ? colorPink.withAlpha(80) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? colorPink : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: selected ? darkText : Colors.black87,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check, size: 20, color: Colors.black54),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
