import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_motion.dart';

/// Button variants following new design system
/// - Filled: primary navy background, white text
/// - Tonal: navy 10% background, navy text
/// - Text: transparent background, navy text
enum AppButtonType {
  filled,
  accent,
  tonal,
  text,
  outline,
  danger;

  // Legacy aliases (backward compatibility)
  static const AppButtonType primary = filled;
  static const AppButtonType secondary = tonal;
}

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.filled,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.height,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: AppMotion.fast,
      vsync: this,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: AppMotion.pressScale,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: AppMotion.springOut,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case AppButtonType.filled:
        return AppColors.primary;
      case AppButtonType.accent:
        return AppColors.accent;
      case AppButtonType.tonal:
        return AppColors.primaryContainer;
      case AppButtonType.text:
        return Colors.transparent;
      case AppButtonType.outline:
        return Colors.transparent;
      case AppButtonType.danger:
        return AppColors.danger;
    }
  }

  Color get _foregroundColor {
    switch (widget.type) {
      case AppButtonType.filled:
        return AppColors.onPrimary;
      case AppButtonType.accent:
        return AppColors.onAccent;
      case AppButtonType.tonal:
        return AppColors.onPrimaryContainer;
      case AppButtonType.text:
        return AppColors.primary;
      case AppButtonType.outline:
        return AppColors.primary;
      case AppButtonType.danger:
        return AppColors.onDanger;
    }
  }

  Color? get _borderColor {
    switch (widget.type) {
      case AppButtonType.outline:
        return AppColors.primary;
      case AppButtonType.danger:
        return AppColors.danger;
      default:
        return null;
    }
  }

  EdgeInsets get _padding {
    return EdgeInsets.symmetric(
      horizontal: AppSpacing.buttonPaddingHorizontal,
      vertical: AppSpacing.buttonPaddingVertical,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.reduceMotion ? 1.0 : _scaleAnim.value;
    return AnimatedScale(
      scale: scale,
      duration: AppMotion.fast,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        constraints: BoxConstraints(
          minHeight: widget.height ?? AppSpacing.buttonMinHeight,
          minWidth: widget.isExpanded ? double.infinity : 120,
        ),
        child: MouseRegion(
          cursor: widget.isLoading
              ? SystemMouseCursors.wait
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTapDown: widget.isLoading
                ? null
                : (_) => _pressController.forward(),
            onTapUp: widget.isLoading
                ? null
                : (_) => _pressController.reverse(),
            onTapCancel: widget.isLoading
                ? null
                : () => _pressController.reverse(),
            child: ElevatedButton(
              onPressed:
                  widget.isLoading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _backgroundColor,
                foregroundColor: _foregroundColor,
                elevation: 0,
                disabledBackgroundColor: _backgroundColor.withAlpha(128),
                disabledForegroundColor: _foregroundColor.withAlpha(128),
                padding: _padding,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                  side: _borderColor != null
                      ? BorderSide(
                          color: _borderColor!,
                          width: 1.5,
                        )
                      : BorderSide.none,
                ),
                textStyle: widget.type == AppButtonType.filled
                    ? AppTypography.buttonMd.copyWith(color: AppColors.onPrimary)
                    : widget.type == AppButtonType.accent
                        ? AppTypography.buttonMd.copyWith(color: AppColors.onAccent)
                        : widget.type == AppButtonType.tonal
                            ? AppTypography.buttonMd.copyWith(color: AppColors.onAccentContainer)
                            : widget.type == AppButtonType.danger
                                ? AppTypography.buttonMd.copyWith(color: AppColors.onDanger)
                                : AppTypography.buttonMd,
              ),
              child: widget.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_foregroundColor),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: AppSpacing.iconSm,
                            color: _foregroundColor,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(widget.label),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
