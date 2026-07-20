import 'package:flutter/material.dart';

import '../../service/api_service.dart';

const Color kCartPink = Color(0xFFFFCCCC);
const Color kCartGreen = Color(0xFFCCFFCC);
const Color kCartBlue = Color(0xFFCCCCFF);

int calculateTotalQuantity(List<CartItemData> items) {
  return items.fold(0, (sum, item) => sum + item.quantity);
}

int calculateSubtotal(List<CartItemData> items) {
  return items.fold(0, (sum, item) => sum + item.resolvedTotal);
}

class CartItemData {
  final String productId;
  final String name;
  final String subtitle;
  final String emoji;
  final String? imageUrl;
  final int
  unitPrice; // price per unit after discount (in whole currency units)
  final int originalPrice; // original unit price before promo
  final int quantity;
  final Color color;
  final String size;
  final String colorName;
  final double? promoPercent;

  const CartItemData({
    required this.productId,
    required this.name,
    required this.subtitle,
    required this.emoji,
    this.imageUrl,
    required this.unitPrice,
    required this.originalPrice,
    required this.quantity,
    required this.color,
    required this.size,
    required this.colorName,
    this.promoPercent,
  });

  CartItemData copyWith({int? quantity, String? imageUrl}) {
    return CartItemData(
      productId: productId,
      name: name,
      subtitle: subtitle,
      emoji: emoji,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice,
      originalPrice: originalPrice,
      quantity: quantity ?? this.quantity,
      color: color,
      size: size,
      colorName: colorName,
      promoPercent: promoPercent,
    );
  }

  int get resolvedUnitPrice {
    if (originalPrice > 0 && unitPrice > 0 && unitPrice < originalPrice) {
      return unitPrice;
    }

    if (promoPercent != null && promoPercent! > 0 && originalPrice > 0) {
      final discounted = (originalPrice * (1 - promoPercent! / 100)).round();
      if (discounted > 0 && discounted < originalPrice) {
        return discounted;
      }
    }

    return unitPrice;
  }

  int get resolvedTotal => resolvedUnitPrice * quantity;

  CartItemData withResolvedPrice() {
    final resolvedPrice = resolvedUnitPrice;
    if (resolvedPrice == unitPrice) {
      return this;
    }

    return CartItemData(
      productId: productId,
      name: name,
      subtitle: subtitle,
      emoji: emoji,
      imageUrl: imageUrl,
      unitPrice: resolvedPrice,
      originalPrice: originalPrice,
      quantity: quantity,
      color: color,
      size: size,
      colorName: colorName,
      promoPercent: promoPercent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'subtitle': subtitle,
      'emoji': emoji,
      'imageUrl': imageUrl,
      'unitPrice': unitPrice,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'color': color.value,
      'size': size,
      'colorName': colorName,
      'promoPercent': promoPercent,
    };
  }

  factory CartItemData.fromJson(Map<String, dynamic> json) {
    return CartItemData(
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
      imageUrl: ApiService.normalizeImageUrl(
        json['imageUrl']?.toString() ??
            json['image_url']?.toString() ??
            json['link_foto']?.toString(),
      ),
      unitPrice: (json['unitPrice'] is num)
          ? (json['unitPrice'] as num).toInt()
          : int.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0,
      originalPrice: (json['originalPrice'] is num)
          ? (json['originalPrice'] as num).toInt()
          : int.tryParse(json['originalPrice']?.toString() ?? '0') ?? 0,
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toInt()
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      color: Color(
        (json['color'] is int)
            ? json['color'] as int
            : int.tryParse(json['color']?.toString() ?? '0') ?? 0,
      ),
      size: json['size']?.toString() ?? '',
      colorName: json['colorName']?.toString() ?? '',
      promoPercent: json['promoPercent'] != null
          ? (json['promoPercent'] as num).toDouble()
          : null,
    );
  }

  String get priceLabel {
    final formatted = unitPrice.toString().replaceAllMapped(
      RegExp(r"(\d)(?=(\d{3})+(?!\d))"),
      (match) => '${match[1]}.',
    );
    return 'Rp $formatted';
  }

  String get totalLabel {
    final total = unitPrice * quantity;
    final formatted = total.toString().replaceAllMapped(
      RegExp(r"(\d)(?=(\d{3})+(?!\d))"),
      (match) => '${match[1]}.',
    );
    return 'Rp $formatted';
  }
}
