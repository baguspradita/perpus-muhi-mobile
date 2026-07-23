import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBorder;
  final Color? borderColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 32,
    this.backgroundColor,
    this.textColor,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final bgColor = backgroundColor ?? AppColors.primary;
    final txtColor = textColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.primaryLight,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: bgColor.withAlpha(38),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              initial,
              style: AppTypography.heading3.copyWith(
                color: txtColor,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (showBorder)
            Positioned(
              right: size * 0.05,
              bottom: size * 0.05,
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                  size: size * 0.15,
                ),
              ),
            ),
        ],
      ),
    );
  }
}