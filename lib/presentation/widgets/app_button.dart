import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum AppButtonType { primary, secondary, outline, danger }

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
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.height,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  Color get _backgroundColor {
    switch (widget.type) {
      case AppButtonType.primary:
        return AppColors.primary;
      case AppButtonType.secondary:
        return AppColors.secondary;
      case AppButtonType.outline:
        return Colors.transparent;
      case AppButtonType.danger:
        return AppColors.error;
    }
  }

  Color get _foregroundColor {
    if (widget.type == AppButtonType.outline) {
      return AppColors.primary;
    }
    return Colors.white;
  }

  Color get _borderColor {
    if (widget.type == AppButtonType.outline) {
      return AppColors.primary;
    }
    return Colors.transparent;
  }

EdgeInsets get _padding {
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      constraints: BoxConstraints(
        minHeight: widget.height ?? 48,
        minWidth: widget.isExpanded ? double.infinity : 120,
      ),
      child: ElevatedButton(
        onPressed: widget.isLoading
            ? null
            : () {
                setState(() => _isPressed = true);
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) setState(() => _isPressed = false);
                });
                widget.onPressed?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _foregroundColor,
          elevation: _isPressed ? 0 : 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          padding: _padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _borderColor,
              width: widget.type == AppButtonType.outline ? 1.5 : 0,
            ),
          ),
          textStyle: AppTypography.button,
        ),
        child: widget.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 20,
                      color: _foregroundColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(widget.label),
                ],
              ),
      ),
    );
  }
}
