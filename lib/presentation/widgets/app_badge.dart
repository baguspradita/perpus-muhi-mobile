import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeVariant variant;
  final EdgeInsetsGeometry? padding;

  const AppBadge({
    super.key,
    required this.text,
    this.variant = AppBadgeVariant.defaultType,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bgColors = {
      AppBadgeVariant.defaultType: AppColors.surfaceVariant,
      AppBadgeVariant.success: AppColors.successLight,
      AppBadgeVariant.warning: AppColors.warningLight,
      AppBadgeVariant.danger: AppColors.errorLight,
      AppBadgeVariant.info: AppColors.infoLight,
    };

    final textColors = {
      AppBadgeVariant.defaultType: AppColors.textBody,
      AppBadgeVariant.success: AppColors.success,
      AppBadgeVariant.warning: AppColors.warning,
      AppBadgeVariant.danger: AppColors.error,
      AppBadgeVariant.info: AppColors.info,
    };

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bgColors[variant],
        borderRadius: BorderRadius.circular(9999),
        border: AppBadgeVariant.defaultType == variant
            ? null
            : Border.all(color: bgColors[variant]!.withAlpha(100)),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: textColors[variant],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

enum AppBadgeVariant {
  defaultType,
  success,
  warning,
  danger,
  info,
}