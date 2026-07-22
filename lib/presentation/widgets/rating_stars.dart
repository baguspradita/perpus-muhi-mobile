import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double starSize;
  final bool showText;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.starSize = 16,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          return Icon(
            index < rating.floor()
                ? Icons.star
                : index < rating
                    ? Icons.star_half
                    : Icons.star_border,
            size: starSize,
            color: AppColors.starFilled,
          );
        }),
        if (showText) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: starSize - 2,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}