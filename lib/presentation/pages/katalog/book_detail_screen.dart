import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/buku_entity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final BukuEntity book;

  const BookDetailScreen({super.key, required this.book});

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  bool _isDescriptionExpanded = false;
  static const int _descriptionMaxLines = 4;

  @override
  Widget build(BuildContext context) {
    final isAvailable = (widget.book.stokTersedia ?? 0) > 0 && widget.book.status == 'aktif';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Cover AppBar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            surfaceTintColor: AppColors.surfaceContainerLowest,
            leading: _BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.fadeTitle, StretchMode.zoomBackground],
              background: _buildHeroCover(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Meta
                  _buildTitleSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Description
                  if (widget.book.deskripsi != null && widget.book.deskripsi!.isNotEmpty)
                    _buildDescriptionSection()
                  else
                    const SizedBox.shrink(),

                  // Detail Card
                  _buildDetailCard(),

                  const SizedBox(height: AppSpacing.xl + AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky Action Bar
      bottomNavigationBar: isAvailable ? _buildActionBar() : _buildUnavailableBar(),
    );
  }

  Widget _buildHeroCover() {
    final coverUrl = widget.book.coverUrl;
    final heroTag = 'book_cover_${widget.book.id}';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background color/shimmer
        Container(
          decoration: BoxDecoration(
            color: _getCoverColor(widget.book.id).withOpacity(0.15),
          ),
        ),

        // Cover Image
        if (coverUrl != null && coverUrl.isNotEmpty)
          Hero(
            tag: heroTag,
            child: CachedNetworkImage(
              imageUrl: coverUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => _buildCoverPlaceholder(),
              errorWidget: (context, url, error) => _buildCoverPlaceholder(),
            ),
          )
        else
          _buildCoverPlaceholder(),

        // Gradient overlay at bottom for title readability when stretched
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.primary.withOpacity(0.85),
                  AppColors.primary.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverPlaceholder() {
    return Center(
      child: Container(
        width: 140,
        height: 190,
        decoration: BoxDecoration(
          color: _getCoverColor(widget.book.id),
          borderRadius: AppRadius.rMd,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          Icons.menu_book_rounded,
          size: 64,
          color: Colors.white.withOpacity(0.25),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.book.judul,
          style: AppTypography.headlineLgMobile.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            _MetaChip(
              icon: Icons.person_outline,
              label: widget.book.penulis,
              onTap: () => _filterByAuthor(widget.book.penulis),
            ),
            if (widget.book.namaKategori != null)
              _MetaChip(
                icon: Icons.category_outlined,
                label: widget.book.namaKategori!,
                onTap: () => _filterByCategory(widget.book.namaKategori!),
              ),
            if (widget.book.tahunTerbit > 0)
              _MetaChip(
                icon: Icons.calendar_today_outlined,
                label: widget.book.tahunTerbit.toString(),
              ),
            if (widget.book.rating != null && widget.book.rating! > 0)
              _RatingChip(rating: widget.book.rating!),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final description = widget.book.deskripsi!;
    final isLong = _calculateLines(description) > _descriptionMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sinopsis', style: AppTypography.heading3),
            if (isLong)
              TextButton(
                onPressed: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _isDescriptionExpanded ? 'Tutup' : 'Baca selengkapnya',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.6,
          ),
          maxLines: _isDescriptionExpanded ? null : _descriptionMaxLines,
          overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  int _calculateLines(String text) {
    // Rough estimation: average characters per line ~ 35-40
    return (text.length / 38).ceil();
  }

  Widget _buildDetailCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.category_outlined,
            label: 'Kategori',
            value: widget.book.namaKategori ?? '-',
          ),
          _DetailDivider(),
          _DetailRow(
            icon: Icons.business_outlined,
            label: 'Penerbit',
            value: widget.book.penerbit,
          ),
          _DetailDivider(),
          _DetailRow(
            icon: Icons.event_outlined,
            label: 'Tahun Terbit',
            value: widget.book.tahunTerbit.toString(),
          ),
          if (widget.book.namaSubjek != null) ...[
            _DetailDivider(),
            _DetailRow(
              icon: Icons.subject_outlined,
              label: 'Subjek',
              value: widget.book.namaSubjek!,
            ),
          ],
          _DetailDivider(),
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Lokasi',
            value: widget.book.namaLokasi ?? '-',
          ),
          _DetailDivider(),
          _DetailRow(
            icon: Icons.inventory_2_outlined,
            label: 'Status',
            value: _getStatusLabel(),
            valueStyle: AppTypography.bodyMedium.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel() {
    if ((widget.book.stokTersedia ?? 0) > 0 && widget.book.status == 'aktif') {
      return 'Tersedia (${widget.book.stokTersedia} salinan)';
    }
    if (widget.book.status != 'aktif') {
      return 'Tidak Aktif';
    }
    return 'Habis';
  }

  Color _getStatusColor() {
    if ((widget.book.stokTersedia ?? 0) > 0 && widget.book.status == 'aktif') {
      return AppColors.success;
    }
    return AppColors.warning;
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: 'Pinjam',
          type: AppButtonType.primary,
          isExpanded: true,
          icon: Icons.library_add_rounded,
          onPressed: () => _showBorrowDialog(context, ref),
        ),
      ),
    );
  }

  Widget _buildUnavailableBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.warning,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Buku ini sedang tidak tersedia untuk dipinjam',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBorrowDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan login terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        title: const Text('Konfirmasi Peminjaman'),
        content: Text('Pinjam "${widget.book.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          AppButton(
            label: 'Ya, Pinjam',
            type: AppButtonType.primary,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Peminjaman "${widget.book.judul}" berhasil!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _toggleBookmark() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Buku disimpan ke wishlist'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _filterByAuthor(String author) {
    // Navigate to katalog with author filter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter penulis: $author'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _filterByCategory(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter kategori: $category'),
        behavior: SnackBarBehavior.floating,
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

// ===== Helper Widgets =====

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        minimumSize: const Size(48, 48),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.outline),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rPill,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: child,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppRadius.rPill,
      ),
      child: child,
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;

  const _RatingChip({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: AppRadius.rPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.outline),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle ?? AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 44),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.outlineVariant.withOpacity(0.2),
      ),
    );
  }
}