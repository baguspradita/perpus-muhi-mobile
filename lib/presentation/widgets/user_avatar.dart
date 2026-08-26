import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Avatar component with squircle shape (radius 24% of size)
/// Provides distinctive look compared to generic circular avatars
class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBorder;
  final Color? borderColor;
  final bool isSquircle;
  final String? imageUrl;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 32,
    this.backgroundColor,
    this.textColor,
    this.showBorder = false,
    this.borderColor,
    this.isSquircle = true,
    this.imageUrl,
  });

  Color get _backgroundColor => backgroundColor ?? AppColors.primary;
  Color get _textColor => textColor ?? AppColors.onPrimary;

  @override
  Widget build(BuildContext context) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final double radius = isSquircle ? size * 0.24 : size / 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.primaryContainer,
                width: 2.0,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Stack(
              children: [
                // TODO: Implement network image with fallback to initial
                _buildInitial(initial),
              ],
            )
          : _buildInitial(initial),
    );
  }

  Widget _buildInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: AppTypography.titleLg.copyWith(
          color: _textColor,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}