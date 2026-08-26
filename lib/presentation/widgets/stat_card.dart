import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_effects.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? bgColor;
  final bool isExpanded;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.bgColor,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final width = widget.isExpanded ? double.infinity : 150.0;
    final effectiveBg = widget.bgColor ?? AppColors.surfaceContainerLowest;
    final effectiveIconColor = widget.iconColor ?? AppColors.accent;

    final card = Container(
      width: width,
      padding: EdgeInsets.all(widget.isExpanded ? AppSpacing.lg : AppSpacing.md),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: AppRadius.card,
        boxShadow: AppGradients.elevation2,
      ),
      child: widget.isExpanded
          ? _buildExpandedLayout(effectiveIconColor)
          : _buildCompactLayout(effectiveIconColor),
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? AppMotion.pressScale : 1.0,
        duration: AppMotion.fast,
        child: card,
      ),
    );
  }

  Widget _buildExpandedLayout(Color iconColor) {
    return Row(
      children: [
        // Icon circle - accent 10% background
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            widget.icon ?? Icons.analytics_outlined,
            color: iconColor,
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
                widget.title,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.value,
                style: AppTypography.dataLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: AppTypography.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          widget.value,
          style: AppTypography.dataLg.copyWith(
            fontSize: 24,
            color: AppColors.onSurface,
          ),
        ),
        if (widget.subtitle != null)
          Text(
            widget.subtitle!,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}