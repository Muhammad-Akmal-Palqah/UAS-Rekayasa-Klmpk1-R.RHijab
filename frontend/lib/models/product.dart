import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final String price;
  final Color color;
  final int rating;
  final String? badge;
  final String description;
  final bool isFavorite;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.color,
    required this.rating,
    this.badge,
    required this.description,
    this.isFavorite = false,
  });
}

const List<Product> productCatalog = [
  Product(
    id: 'hijab_elegant',
    title: 'Luxury Chiffon Hijab Elegant',
    price: '€24,95',
    color: Color(0xffffcccc),
    rating: 5,
    badge: 'BEST',
    description: 'Soft chiffon with elegant shine, perfect for special moments.',
    isFavorite: true,
  ),
  Product(
    id: 'hijab_blush',
    title: 'Eco-friendly Modal Hijab Blush',
    price: '€19,95',
    color: Color(0xffccccff),
    rating: 5,
    badge: 'NEW',
    description: 'Breathable modal fabric designed for all-day comfort.',
    isFavorite: true,
  ),
  Product(
    id: 'hijab_dusty_rose',
    title: 'Modal Hijab Dusty Rose',
    price: '€19,95',
    color: Color(0xffccffcc),
    rating: 5,
    badge: 'NEW',
    description: 'A soft, everyday hijab with a flattering drape.',
  ),
  Product(
    id: 'hijab_serene',
    title: 'Modal Hijab Serene',
    price: '€19,95',
    color: Color(0xffffcccc),
    rating: 5,
    description: 'Classic tone with a silky feel for refined styling.',
  ),
  Product(
    id: 'hijab_mocca',
    title: 'Modal Hijab Mocca',
    price: '€19,95',
    color: Color(0xffccccff),
    rating: 5,
    description: 'Warm, neutral tone designed for everyday layering.',
  ),
  Product(
    id: 'hijab_dessert',
    title: 'Modal Hijab Dessert',
    price: '€19,95',
    color: Color(0xffccffcc),
    rating: 5,
    description: 'Soft pastel tone that works beautifully with any outfit.',
    isFavorite: true,
  ),
];

final List<Product> favoriteProducts =
    productCatalog.where((product) => product.isFavorite).toList();
