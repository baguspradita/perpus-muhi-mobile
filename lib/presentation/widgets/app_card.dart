import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? height;
  final Color? shadowColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.height,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveShadow = shadowColor ?? AppColors.shadowPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      child: Card(
        elevation: 0,
        shadowColor: effectiveShadow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.rMd,
          side: BorderSide(color: AppColors.divider),
        ),
        color: AppColors.surface,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rMd,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}
