import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double iconSize;
  final Color filledColor;
  final Color halfColor;
  final Color emptyColor;
  final int starCount;

  const RatingStars({
    Key? key,
    required this.rating,
    this.iconSize = 16.0,
    this.filledColor = Colors.orange,
    Color? halfColor,
    this.emptyColor = Colors.black12,
    this.starCount = 5,
  }) : halfColor = halfColor ?? Colors.orange,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final double normalizedRating = rating.clamp(0.0, starCount.toDouble());
    final double roundedHalf = (normalizedRating * 2).round() / 2;
    final int fullStars = roundedHalf.floor();
    final bool hasHalfStar = (roundedHalf - fullStars) == 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(starCount, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, size: iconSize, color: filledColor);
        }

        if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, size: iconSize, color: halfColor);
        }

        return Icon(Icons.star_border, size: iconSize, color: emptyColor);
      }),
    );
  }
}
