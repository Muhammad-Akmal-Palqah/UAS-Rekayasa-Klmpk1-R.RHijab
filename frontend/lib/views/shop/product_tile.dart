import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'product_page.dart';

class ProductTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double price;

  const ProductTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final product = Product(
          id: title,
          title: title,
          price: '\$${price.toStringAsFixed(2)}',
          priceValue: price,
          description: subtitle,
          imageUrl: imageUrl,
          imageUrls: [imageUrl],
          category: '',
          rating: 4,
          averageRating: 4.0,
          reviewCount: 0,
          color: Colors.grey,
          isFeatured: false,
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductPage(product: product)),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
