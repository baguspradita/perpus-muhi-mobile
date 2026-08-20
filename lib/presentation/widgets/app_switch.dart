import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_typography.dart';

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? subtitle;
  final Widget? leading;
  final bool isEnabled;
  final Color? activeColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;

  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.subtitle,
    this.leading,
    this.isEnabled = true,
    this.activeColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final effectiveInactiveThumbColor = inactiveThumbColor ?? AppColors.outline;
    final effectiveInactiveTrackColor = inactiveTrackColor ?? AppColors.outlineVariant;
    final textColor = isEnabled ? AppColors.onSurface : AppColors.outline;

    return IgnorePointer(
      ignoring: !isEnabled || onChanged == null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      style: AppTypography.bodyMd.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: effectiveActiveColor,
              activeTrackColor: effectiveActiveColor.withValues(alpha: 0.3),
              inactiveThumbColor: effectiveInactiveThumbColor,
              inactiveTrackColor: effectiveInactiveTrackColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class AppSwitchTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool isEnabled;
  final Color? activeColor;
  final EdgeInsetsGeometry? contentPadding;
  final Color? tileColor;
  final BorderRadius? borderRadius;

  const AppSwitchTile({
    super.key,
    required this.value,
    this.onChanged,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.isEnabled = true,
    this.activeColor,
    this.contentPadding,
    this.tileColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTileColor = tileColor ?? AppColors.surfaceContainerLowest;
    final effectiveBorderRadius = borderRadius ?? AppRadius.rMd;

    return Material(
      color: effectiveTileColor,
      borderRadius: effectiveBorderRadius,
      child: InkWell(
        onTap: isEnabled && onChanged != null ? () => onChanged!(!value) : null,
        borderRadius: effectiveBorderRadius,
        child: Container(
          padding: contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMd.copyWith(
                        color: isEnabled ? AppColors.onSurface : AppColors.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Switch(
                value: value,
                onChanged: isEnabled ? onChanged : null,
                activeColor: activeColor ?? AppColors.primary,
                activeTrackColor: (activeColor ?? AppColors.primary).withValues(alpha: 0.3),
                inactiveThumbColor: AppColors.outline,
                inactiveTrackColor: AppColors.outlineVariant,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppToggleButtons<T> extends StatelessWidget {
  final T value;
  final List<ToggleButtonItem<T>> items;
  final ValueChanged<T>? onChanged;
  final bool isEnabled;
  final Color? selectedColor;
  final Color? unselectedColor;

  const AppToggleButtons({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.isEnabled = true,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.primary;
    final effectiveUnselectedColor = unselectedColor ?? AppColors.outline;

    return ToggleButtons(
      isEnabled: isEnabled,
      onPressed: onChanged != null
          ? (index) => onChanged!(items[index].value)
          : null,
      borderRadius: AppRadius.rMd,
      selectedColor: Colors.white,
      fillColor: effectiveSelectedColor,
      color: effectiveUnselectedColor,
      borderColor: effectiveUnselectedColor.withValues(alpha: 0.3),
      selectedBorderColor: effectiveSelectedColor,
      constraints: const BoxConstraints(
        minHeight: 40,
        minWidth: 80,
      ),
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 18),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                item.label,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ToggleButtonItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const ToggleButtonItem({
    required this.value,
    required this.label,
    this.icon,
  });
}