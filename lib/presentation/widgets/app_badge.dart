import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Badge variants following new design system
/// - Primary: navy background, white text
/// - Accent: amber background, navy text
/// - Success/Warning/Danger/Info: semantic colors
enum AppBadgeVariant {
  primary,
  accent,
  success,
  warning,
  danger,
  info,
  neutral;

  // Legacy alias (backward compatibility)
  static const AppBadgeVariant defaultType = neutral;
}

class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeVariant variant;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  const AppBadge({
    super.key,
    required this.text,
    this.variant = AppBadgeVariant.neutral,
    this.padding,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getVariantConfig(variant);

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: AppRadius.badge,
        border: config.showBorder
            ? Border.all(color: config.borderColor!, width: 1)
            : null,
      ),
      child: Text(
        // Sentence case for better readability
        _toSentenceCase(text),
        style: AppTypography.labelMd.copyWith(
          color: config.textColor,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }

  _BadgeConfig _getVariantConfig(AppBadgeVariant variant) {
    switch (variant) {
      case AppBadgeVariant.primary:
        return _BadgeConfig(
          bg: AppColors.primary,
          textColor: AppColors.onPrimary,
          showBorder: false,
        );
      case AppBadgeVariant.accent:
        return _BadgeConfig(
          bg: AppColors.accentContainer,
          textColor: AppColors.onAccentContainer,
          showBorder: false,
        );
      case AppBadgeVariant.success:
        return _BadgeConfig(
          bg: AppColors.successContainer,
          textColor: AppColors.onSuccessContainer,
          showBorder: true,
          borderColor: AppColors.success.withAlpha(60),
        );
      case AppBadgeVariant.warning:
        return _BadgeConfig(
          bg: AppColors.warningContainer,
          textColor: AppColors.onWarningContainer,
          showBorder: true,
          borderColor: AppColors.warning.withAlpha(60),
        );
      case AppBadgeVariant.danger:
        return _BadgeConfig(
          bg: AppColors.dangerContainer,
          textColor: AppColors.onDangerContainer,
          showBorder: true,
          borderColor: AppColors.danger.withAlpha(60),
        );
      case AppBadgeVariant.info:
        return _BadgeConfig(
          bg: AppColors.infoContainer,
          textColor: AppColors.onInfoContainer,
          showBorder: true,
          borderColor: AppColors.info.withAlpha(60),
        );
      case AppBadgeVariant.neutral:
        return _BadgeConfig(
          bg: AppColors.surfaceContainer,
          textColor: AppColors.onSurfaceVariant,
          showBorder: false,
        );
    }
  }

  String _toSentenceCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

class _BadgeConfig {
  final Color bg;
  final Color textColor;
  final bool showBorder;
  final Color? borderColor;

  _BadgeConfig({
    required this.bg,
    required this.textColor,
    required this.showBorder,
    this.borderColor,
  });
}