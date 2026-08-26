import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_effects.dart';

/// Card elevation levels following new design system
/// - flat: background color only, no shadow
/// - raised: tinted navy shadow
/// - outlined: 1px border only
enum AppCardElevation { flat, raised, outlined }

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final AppCardElevation elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool enablePress;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.height,
    this.width,
    this.elevation = AppCardElevation.raised,
    this.backgroundColor,
    this.borderRadius,
    this.enablePress = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? AppRadius.card;
    final effectiveBg = widget.backgroundColor ??
        (widget.elevation == AppCardElevation.flat
            ? AppColors.surfaceContainer
            : AppColors.surfaceContainerLowest);

    List<BoxShadow>? shadows;
    if (widget.elevation == AppCardElevation.raised) {
      shadows = _isPressed
          ? AppGradients.elevation1
          : AppGradients.elevation2;
    }

    final decoration = BoxDecoration(
      color: effectiveBg,
      borderRadius: effectiveRadius,
      border: widget.elevation == AppCardElevation.outlined
          ? Border.all(color: AppColors.outlineVariant, width: 1)
          : null,
      boxShadow: shadows,
    );

    final card = Container(
      height: widget.height,
      width: widget.width,
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: decoration,
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: widget.enablePress ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enablePress ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.enablePress ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed && widget.enablePress ? AppMotion.pressScale : 1.0,
        duration: AppMotion.fast,
        child: card,
      ),
    );
  }
}