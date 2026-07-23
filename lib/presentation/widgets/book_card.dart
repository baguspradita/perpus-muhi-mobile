import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_badge.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String? coverUrl;
  final Color coverColor;
  final bool isAvailable;
  final String? loanStatus;
  final String? dueDate;
  final VoidCallback? onTap;
  final bool isGridMode;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    this.coverUrl,
    this.coverColor = AppColors.primary,
    this.isAvailable = true,
    this.loanStatus,
    this.dueDate,
    this.onTap,
    this.isGridMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridMode) {
      return _buildGridCard();
    }
    return _buildDetailCard();
  }

  Widget _buildGridCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.rXl,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowPrimary,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover section with badge overlay
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: coverColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                  ),
                  // Status badge top-right
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: _buildStatusBadge(),
                  ),
                ],
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.rXl,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowPrimary,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover section
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (loanStatus != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: AppRadius.rPill,
                      ),
                      child: Text(
                        loanStatus!,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (dueDate != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tempo: $dueDate',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (loanStatus != null)
                        AppBadge(
                          text: loanStatus!,
                          variant: AppBadgeVariant.warning,
                        )
                      else
                        AppBadge(
                          text: isAvailable ? 'Tersedia' : 'Habis',
                          variant: isAvailable
                              ? AppBadgeVariant.success
                              : AppBadgeVariant.danger,
                        ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    String text;
    AppBadgeVariant variant;

    if (loanStatus != null) {
      text = loanStatus!.toUpperCase();
      variant = AppBadgeVariant.warning;
    } else if (isAvailable) {
      text = 'TERSEDIA';
      variant = AppBadgeVariant.success;
    } else {
      text = 'DIPINJAM';
      variant = AppBadgeVariant.danger;
    }

    return AppBadge(
      text: text,
      variant: variant,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}