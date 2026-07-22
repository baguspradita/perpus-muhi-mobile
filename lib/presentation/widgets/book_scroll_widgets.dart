import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/buku_entity.dart';

class PopularBooksScroll extends StatelessWidget {
  final String title;
  final List<BukuEntity> books;
  final void Function(BukuEntity)? onTap;

  const PopularBooksScroll({
    super.key,
    required this.title,
    required this.books,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            title,
            style: AppTypography.heading3,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return _PopularBookCard(
                book: book,
                onTap: () => onTap?.call(book),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PopularBookCard extends StatelessWidget {
  final BukuEntity book;
  final void Function()? onTap;

  const _PopularBookCard({required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'book_cover_${book.id}',
              child: Container(
                height: 150,
                width: 120,
                decoration: BoxDecoration(
                  color: _getCoverColor(book.id),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book,
                    size: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              book.judul,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textHeading,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              book.penulis,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCoverColor(int id) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00B894),
      const Color(0xFFE17055),
      const Color(0xFF74B9FF),
      const Color(0xFFA29BFE),
      const Color(0xFFFD79A8),
    ];
    return colors[id % colors.length];
  }
}

class RecommendedBooksGrid extends StatelessWidget {
  final String title;
  final List<BukuEntity> books;
  final void Function(BukuEntity)? onTap;

  const RecommendedBooksGrid({
    super.key,
    required this.title,
    required this.books,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            title,
            style: AppTypography.heading3,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return _RecommendedBookCard(
                book: book,
                onTap: () => onTap?.call(book),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecommendedBookCard extends StatelessWidget {
  final BukuEntity book;
  final void Function()? onTap;

  const _RecommendedBookCard({required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'book_cover_${book.id}',
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getCoverColor(book.id),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book,
                    size: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeading,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.penulis,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
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

  Color _getCoverColor(int id) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00B894),
      const Color(0xFFE17055),
      const Color(0xFF74B9FF),
      const Color(0xFFA29BFE),
      const Color(0xFFFD79A8),
    ];
    return colors[id % colors.length];
  }
}