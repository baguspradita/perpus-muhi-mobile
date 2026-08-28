import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_effects.dart';
import 'app_badge.dart';
import 'procedural_book_cover.dart';

class BookCard extends StatefulWidget {
  final String title;
  final String author;
  final String? coverUrl;
  final Color coverColor;
  final bool isAvailable;
  final String? loanStatus;
  final String? dueDate;
  final VoidCallback? onTap;
  final bool isGridMode;
  final String? heroTag;
  final int bookId;

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
    this.heroTag,
    this.bookId = 0,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return widget.isGridMode ? _buildGridCard() : _buildDetailCard();
  }

  Widget _buildGridCard() {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? AppMotion.pressScale : 1.0,
        duration: AppMotion.fast,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.card,
            boxShadow: AppGradients.elevation2,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover section with badge overlay
              Expanded(
                child: Stack(
                  children: [
                    Hero(
                      tag: widget.heroTag ?? 'book_cover_${widget.bookId}',
                      child: _buildCoverImage(),
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
              // Info section - bottom-aligned
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (widget.coverUrl != null && widget.coverUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.coverUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _buildCoverPlaceholder(),
        errorWidget: (context, url, error) => _buildCoverPlaceholder(),
      );
    }
    return _buildCoverPlaceholder();
  }

  Widget _buildCoverPlaceholder() {
    return ProceduralBookCover(
      title: widget.title,
      author: widget.author,
      bookId: widget.bookId,
      fit: BoxFit.cover,
    );
  }

  Widget _buildDetailCard() {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? AppMotion.pressScale : 1.0,
        duration: AppMotion.fast,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.card,
            boxShadow: AppGradients.elevation2,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover section
              Hero(
                tag: widget.heroTag ?? 'book_cover_${widget.bookId}',
                child: ProceduralBookCover(
                  title: widget.title,
                  author: widget.author,
                  bookId: widget.bookId,
                  height: 140,
                ),
              ),
              // Info section - bottom-aligned
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.author,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.dueDate != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tempo: ${widget.dueDate}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.loanStatus == 'Dipinjam Saya')
                          AppBadge(
                            text: widget.loanStatus!,
                            variant: AppBadgeVariant.info,
                          )
                        else if (widget.loanStatus != null)
                          AppBadge(
                            text: widget.loanStatus!,
                            variant: AppBadgeVariant.warning,
                          )
                        else
                          AppBadge(
                            text: widget.isAvailable ? 'Tersedia' : 'Habis',
                            variant: widget.isAvailable
                                ? AppBadgeVariant.success
                                : AppBadgeVariant.danger,
                          ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    String text;
    AppBadgeVariant variant;

    if (widget.loanStatus == 'Dipinjam Saya') {
      text = widget.loanStatus!;
      variant = AppBadgeVariant.info;
    } else if (widget.loanStatus != null) {
      text = widget.loanStatus!;
      variant = AppBadgeVariant.warning;
    } else if (widget.isAvailable) {
      text = 'Tersedia';
      variant = AppBadgeVariant.success;
    } else {
      text = 'Dipinjam';
      variant = AppBadgeVariant.danger;
    }

    return AppBadge(
      text: text,
      variant: variant,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    );
  }
}