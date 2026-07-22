import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppAlert extends StatelessWidget {
  final String message;
  final AppAlertType type;
  final bool isDismissible;
  final VoidCallback? onDismissed;

  const AppAlert({
    super.key,
    required this.message,
    this.type = AppAlertType.success,
    this.isDismissible = true,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final typeColors = {
      AppAlertType.success: AppColors.success,
      AppAlertType.error: AppColors.error,
      AppAlertType.warning: AppColors.warning,
    };

    final bgColors = {
      AppAlertType.success: AppColors.successLight,
      AppAlertType.error: AppColors.errorLight,
      AppAlertType.warning: AppColors.warningLight,
    };

    final borderColors = {
      AppAlertType.success: AppColors.success,
      AppAlertType.error: AppColors.error,
      AppAlertType.warning: AppColors.warning,
    };

    final iconColor = {
      AppAlertType.success: AppColors.success,
      AppAlertType.error: AppColors.error,
      AppAlertType.warning: AppColors.warning,
    };

    Widget icon;
    switch (type) {
      case AppAlertType.success:
        icon = Icon(Icons.check_circle, color: iconColor[type], size: 20);
        break;
      case AppAlertType.error:
        icon = Icon(Icons.error_outline, color: iconColor[type], size: 20);
        break;
      case AppAlertType.warning:
        icon = Icon(Icons.warning_amber, color: iconColor[type], size: 20);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColors[type],
        border: Border.all(color: borderColors[type]!, width: 1),
        borderRadius: AppRadius.rMd,
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: typeColors[type],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isDismissible)
            GestureDetector(
              onTap: onDismissed,
              child: Icon(Icons.close, color: typeColors[type], size: 18),
            ),
        ],
      ),
    );
  }
}

enum AppAlertType {
  success,
  error,
  warning,
}