import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? shadowColor;
  final Color? bgColor;
  final bool isExpanded;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.shadowColor,
    this.bgColor,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = isExpanded ? double.infinity : 150.0;

    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? AppColors.shadowPrimary,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isExpanded ? _buildExpandedLayout() : _buildCompactLayout(),
    );
  }

  Widget _buildExpandedLayout() {
    return Row(
      children: [
        // Icon container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (bgColor ?? AppColors.surfaceContainerLow).withAlpha(100),
            borderRadius: AppRadius.rMd,
          ),
          child: Icon(
            icon ?? Icons.analytics,
            color: iconColor ?? AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTypography.statNumber,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelMd.copyWith(
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.statNumber.copyWith(fontSize: 24),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}