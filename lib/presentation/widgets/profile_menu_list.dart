import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

class ProfileMenuList extends StatelessWidget {
  final List<ProfileMenuItem> items;

  const ProfileMenuList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: items
            .map((item) => _MenuTile(item: item))
            .toList(),
      ),
    );
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showDivider;

  const ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.showDivider = true,
  });
}

class _MenuTile extends StatelessWidget {
  final ProfileMenuItem item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isDestructive ? AppColors.error : AppColors.onSurface;
    final iconColor = item.isDestructive ? AppColors.error : AppColors.primary;

    return InkWell(
      onTap: item.onTap,
      borderRadius: item.showDivider
          ? BorderRadius.zero
          : AppRadius.rXl,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: item.showDivider
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                borderRadius: AppRadius.rMd,
              ),
              child: Icon(
                item.icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.bodyLg.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.outline,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}