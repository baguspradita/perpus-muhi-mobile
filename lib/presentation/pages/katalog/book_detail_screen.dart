import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/buku_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/peminjaman_provider.dart';
import '../../providers/book_detail_provider.dart';
import '../../providers/related_books_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/book_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/procedural_book_cover.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final BukuEntity book;

  const BookDetailScreen({super.key, required this.book});

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isDescriptionExpanded = false;
  static const int _descriptionMaxLines = 4;
  late AnimationController _staggerController;

  late BukuEntity _book = widget.book;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _staggerController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookDetailProvider(_book.id).notifier).loadBuku(_book.id);
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(bookDetailProvider(_book.id));
    final detailBook = detail.book;
    if (detailBook != null) {
      _book = detailBook.copyWith(
        stokTersedia: detailBook.stokTersedia ?? _book.stokTersedia,
        totalSalinan: detailBook.totalSalinan ?? _book.totalSalinan,
      );
    }
    final isAvailable = (_book.stokTersedia ?? 0) > 0 && _book.status == 'aktif';
    final relatedState = ref.watch(relatedBooksProvider(_book.id));
    final relatedBooks = relatedState.books;

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
                  if (detail.errorMessage.isNotEmpty && detail.book == null)
                    _buildErrorBanner(detail.errorMessage),

                  // Title & Meta
                  _buildTitleSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Description
                  if (_book.deskripsi != null && _book.deskripsi!.isNotEmpty)
                    _buildDescriptionSection()
                  else
                    const SizedBox.shrink(),

                  // Detail Card
                  _buildDetailCard(),

                  const SizedBox(height: AppSpacing.xl),

                  _buildRelatedSection(context, relatedState),

                  const SizedBox(height: AppSpacing.xl + AppSpacing.lg),
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

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadius.rMd,
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Gagal memuat detail lengkap: $message',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onErrorContainer),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(bookDetailProvider(_book.id).notifier).loadBuku(_book.id),
            child: Text('Coba Lagi', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedSection(BuildContext context, RelatedBooksState relatedState) {
    if (relatedState.isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Buku Serupa',
            actionLabel: 'Lihat Semua',
            onAction: () => context.push(RouteNames.katalog),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: AppSpacing.md),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, __) => SizedBox(
                width: 150,
                child: _buildRelatedSkeleton(),
              ),
            ),
          ),
        ],
      );
    }

    if (relatedState.errorMessage.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Buku Serupa',
            actionLabel: 'Coba Lagi',
            onAction: () => ref.read(relatedBooksProvider(_book.id).notifier).loadRelatedBooks(_book.id),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 210,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: Text(
                relatedState.errorMessage,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    final books = relatedState.books;
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Buku Serupa',
          actionLabel: 'Lihat Semua',
          onAction: () => context.push(RouteNames.katalog),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: AppSpacing.md),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final book = books[index];
              return SizedBox(
                width: 150,
                child: BookCard(
                  title: book.judul,
                  author: book.penulis,
                  coverUrl: book.coverUrl,
                  coverColor: _getCoverColor(book.id),
                  isAvailable: (book.stokTersedia ?? 0) > 0,
                  bookId: book.id,
                  isGridMode: true,
                  heroTag: 'book_cover_${book.id}',
                  onTap: () => context.push(
                    RouteNames.bookDetail,
                    extra: book,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedSkeleton() {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.rMd)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  color: AppColors.surfaceContainerHigh,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 80,
                  color: AppColors.surfaceContainerHigh,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCover() {
    final coverUrl = _book.coverUrl;
    final heroTag = 'book_cover_${_book.id}';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background color/shimmer
        Container(
          decoration: BoxDecoration(
            color: _getCoverColor(_book.id).withOpacity(0.15),
          ),
        ),

        // Subtle radial ambient gradient
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.heroCenterRadial(
                  primaryColor: AppColors.primary.withValues(alpha: 0.06),
                  accentColor: AppColors.accent.withValues(alpha: 0.03),
                  radius: 0.85,
                ),
              ),
            ),
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
      child: ProceduralBookCover(
        title: _book.judul,
        author: _book.penulis,
        bookId: _book.id,
        width: 140,
        height: 190,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _book.judul,
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
              icon: Icons.person,
              label: _book.penulis,
              onTap: () => _filterByAuthor(_book.penulis),
            ),
            if (_book.namaKategori != null)
              _MetaChip(
                icon: Icons.category_outlined,
                label: _book.namaKategori!,
                onTap: () => _filterByCategory(_book.namaKategori!),
              ),
            if (_book.tahunTerbit > 0)
              _MetaChip(
                icon: Icons.calendar_today_outlined,
                label: _book.tahunTerbit.toString(),
              ),
            if (_book.rating != null && _book.rating! > 0)
              _RatingChip(rating: _book.rating!),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final description = _book.deskripsi!;
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
            value: _book.namaKategori ?? '-',
          ),
          _DetailDivider(),
          _DetailRow(
            icon: Icons.business_outlined,
            label: 'Penerbit',
            value: _book.penerbit,
          ),
          _DetailDivider(),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tahun Terbit',
            value: _book.tahunTerbit.toString(),
          ),
          if (_book.namaSubjek != null) ...[
            _DetailDivider(),
            _DetailRow(
              icon: Icons.subject_outlined,
              label: 'Subjek',
              value: _book.namaSubjek!,
            ),
          ],
          _DetailDivider(),
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Lokasi',
            value: _book.namaLokasi ?? '-',
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
    if ((_book.stokTersedia ?? 0) > 0 && _book.status == 'aktif') {
      return 'Tersedia (${_book.stokTersedia} salinan)';
    }
    if (_book.status != 'aktif') {
      return 'Tidak Aktif';
    }
    return 'Habis';
  }

  Color _getStatusColor() {
    if ((_book.stokTersedia ?? 0) > 0 && _book.status == 'aktif') {
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
            color: AppColors.shadowPrimary.withValues(alpha: 0.6),
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
              Icons.info_outline,
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDue = today.add(const Duration(days: 1));
    DateTime selectedDue = firstDue;
    bool isBorrowing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final durasi = selectedDue.difference(today).inDays;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
            title: Text(
              'Peminjaman "${_book.judul}"',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tenggat Pengembalian',
                  style: AppTypography.labelMd.copyWith(color: AppColors.outline),
                ),
                const SizedBox(height: AppSpacing.xs),
                InkWell(
                  onTap: isBorrowing
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDue,
                            firstDate: firstDue,
                            lastDate: today.add(const Duration(days: 7)),
                            helpText: 'Pilih Tenggat Pengembalian',
                          );
                          if (picked != null) {
                            setState(() => selectedDue = picked);
                          }
                        },
                  borderRadius: AppRadius.rMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outlineVariant),
                      borderRadius: AppRadius.rMd,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            AppDateUtils.formatDate(selectedDue),
                            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '($durasi hari)',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Maksimal 7 hari',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Batal',
                      type: AppButtonType.outline,
                      onPressed: isBorrowing ? null : () => Navigator.pop(dialogContext),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: isBorrowing ? 'Memproses...' : 'Pinjam',
                      type: AppButtonType.primary,
                      icon: isBorrowing ? null : Icons.library_add_rounded,
                      onPressed: isBorrowing
                          ? null
                          : () async {
                              setState(() => isBorrowing = true);

                              final tglPinjam = DateFormat('yyyy-MM-dd').format(now);
                              final tglJatuhTempo = DateFormat('yyyy-MM-dd').format(selectedDue);

                              await ref.read(peminjamanProvider.notifier).createPeminjaman(
                                userId: user.id,
                                bukuIds: [_book.id],
                                tglPinjam: tglPinjam,
                                tglJatuhTempo: tglJatuhTempo,
                              );

                              if (!context.mounted) return;

                              final error = ref.read(peminjamanProvider).errorMessage;
                              Navigator.pop(dialogContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error.isNotEmpty
                                        ? error
                                        : 'Peminjaman "${_book.judul}" berhasil!',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
                                  backgroundColor:
                                      error.isNotEmpty ? AppColors.error : AppColors.success,
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
          const Icon(Icons.star, size: 14, color: AppColors.warning),
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
