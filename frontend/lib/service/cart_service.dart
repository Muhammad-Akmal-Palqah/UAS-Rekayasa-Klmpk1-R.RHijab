import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../views/keranjang/cart_constants.dart';

class CartService {
  static const _key = 'rr_cart_items_v1';

  static Future<List<CartItemData>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = json.decode(raw) as List<dynamic>;
      final items = decoded
          .map((e) => CartItemData.fromJson((e as Map).cast<String, dynamic>()))
          .toList();

      // Fallback: if cart item has no image, try to recover from loaded product catalog
      final updatedItems = items.map((item) {
        var normalizedItem = item.withResolvedPrice();
        if (normalizedItem.imageUrl != null &&
            normalizedItem.imageUrl!.isNotEmpty) {
          return normalizedItem;
        }
        final product = productCatalog.firstWhere(
          (product) => product.id == normalizedItem.productId,
          orElse: () => productCatalog.isNotEmpty
              ? productCatalog.first
              : Product(
                  id: '',
                  title: '',
                  price: 'Rp 0',
                  priceValue: 0,
                  description: '',
                  imageUrl: '',
                  category: '',
                  rating: 0,
                  averageRating: 0.0,
                  reviewCount: 0,
                  color: const Color(0xFFFFFFFF),
                  isFeatured: false,
                ),
        );
        if (product.id.isNotEmpty && product.imageUrl.isNotEmpty) {
          return normalizedItem.copyWith(imageUrl: product.imageUrl);
        }
        return normalizedItem;
      }).toList();

      return updatedItems;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCart(List<CartItemData> items) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, payload);
  }

  static Future<void> addItem(CartItemData item) async {
    final items = await loadCart();
    // Merge if same product + size + colorName
    final index = items.indexWhere(
      (i) =>
          i.productId == item.productId &&
          i.size == item.size &&
          i.colorName == item.colorName,
    );
    if (index >= 0) {
      final existing = items[index];
      items[index] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
    } else {
      items.add(item);
    }
    await saveCart(items);
  }

  static Future<void> removeAt(int index) async {
    final items = await loadCart();
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      await saveCart(items);
    }
  }

  static Future<void> updateQuantity(int index, int quantity) async {
    final items = await loadCart();
    if (index >= 0 && index < items.length && quantity > 0) {
      items[index] = items[index].copyWith(quantity: quantity);
      await saveCart(items);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
