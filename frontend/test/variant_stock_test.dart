import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/product.dart';

void main() {
  group('Product variant stock updates', () {
    test('reduces size and color stock for the selected variant', () {
      final product = Product(
        id: '1',
        title: 'Hijab',
        price: 'Rp100000',
        priceValue: 100000,
        description: 'Test product',
        imageUrl: '',
        category: 'Hijab',
        rating: 5,
        averageRating: 5,
        reviewCount: 1,
        color: Colors.pink,
        isFeatured: false,
        availableSizes: const ['M', 'L'],
        availableColors: const ['Black', 'White'],
        availableSizeStocks: const {'M': 10, 'L': 5},
        availableColorStocks: const {'Black': 8, 'White': 3},
      );

      final updated = product.applyVariantPurchase(
        size: 'M',
        color: 'Black',
        quantity: 2,
      );

      expect(updated.availableSizeStocks['M'], 8);
      expect(updated.availableColorStocks['Black'], 6);
      expect(updated.availableSizeStocks['L'], 5);
      expect(updated.availableColorStocks['White'], 3);
    });

    test('does not change stock when variant selection is missing', () {
      final product = Product(
        id: '2',
        title: 'Hijab',
        price: 'Rp100000',
        priceValue: 100000,
        description: 'Test product',
        imageUrl: '',
        category: 'Hijab',
        rating: 5,
        averageRating: 5,
        reviewCount: 1,
        color: Colors.pink,
        isFeatured: false,
        availableSizes: const ['M'],
        availableColors: const ['Black'],
        availableSizeStocks: const {'M': 10},
        availableColorStocks: const {'Black': 8},
      );

      final updated = product.applyVariantPurchase(
        size: '',
        color: '',
        quantity: 2,
      );

      expect(updated.availableSizeStocks, product.availableSizeStocks);
      expect(updated.availableColorStocks, product.availableColorStocks);
    });
  });
}
