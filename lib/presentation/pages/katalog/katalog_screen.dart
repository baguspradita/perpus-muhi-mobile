import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/routes/route_names.dart';
import '../../../domain/entities/buku_entity.dart';
import '../../providers/katalog_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/procedural_book_cover.dart';
import '../../widgets/staggered_list.dart';

class KatalogScreen extends ConsumerStatefulWidget {
  const KatalogScreen({super.key});

  @override
  ConsumerState<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends ConsumerState<KatalogScreen> {
  String _currentSearch = '';
  int? _selectedCategoryId;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _currentSearch = value);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(katalogProvider.notifier).loadData(
            search: value.isEmpty ? null : value,
            kategoriId: _selectedCategoryId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final katalogState = ref.watch(katalogProvider);
    final categories = _buildCategories(katalogState);
    final selectedIndex = _resolveSelectedIndex(categories);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero header with title
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          // Sticky search + filter chips
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyFilterDelegate(
              child: _buildStickyBar(katalogState, categories, selectedIndex),
            ),
          ),
          // Content
          if (katalogState.isLoading)
            SliverToBoxAdapter(child: _buildLoadingState())
          else if (katalogState.errorMessage.isNotEmpty)
            SliverToBoxAdapter(child: _buildErrorState(katalogState.errorMessage))
          else
            _buildMasonrySliver(katalogState),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Katalog Buku', style: AppTypography.headlineLg),
          Consumer(
            builder: (context, ref, _) {
              final unreadCount = ref.watch(notificationProvider).unreadBadge;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Notifikasi',
                    onPressed: () => context.push(RouteNames.notifications),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBar(
    KatalogState katalogState,
    List<CategoryItem> categories,
    int selectedIndex,
  ) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          AppSearchBar(
            hintText: 'Cari buku, penulis, atau ISBN...',
            onChanged: _onSearchChanged,
            onClear: () {
              _debounceTimer?.cancel();
              setState(() => _currentSearch = '');
              ref.read(katalogProvider.notifier).loadData(
                    search: null,
                    kategoriId: _selectedCategoryId,
                  );
            },
            isLoading: katalogState.isLoading,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.outline,
              size: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          katalogState.isFiltersLoading
              ? _buildCategoryLoadingState()
              : CategoryChipsScroll(
                  categories: categories,
                  selectedIndex: selectedIndex,
                  onCategorySelected: (index) {
                    final selectedCategoryId =
                        index == 0 ? null : categories[index].id;
                    setState(() => _selectedCategoryId = selectedCategoryId);
                    ref.read(katalogProvider.notifier).loadData(
                          search: _currentSearch.isEmpty ? null : _currentSearch,
                          kategoriId: selectedCategoryId,
                        );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.lg),
          const CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Memuat buku...',
            style: AppTypography.bodySm.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLoadingState() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final widths = [72.0, 64.0, 80.0, 76.0];
          return LoadingShimmer(
            width: widths[index],
            height: 30,
            borderRadius: 999,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Gagal Memuat Buku',
          subtitle: error,
          actionLabel: 'Coba Lagi',
          onAction: () {
            ref.read(katalogProvider.notifier).loadData();
          },
        ),
      ),
    );
  }

  /// Masonry grid (2-column balanced) with auto height per card
  Widget _buildMasonrySliver(KatalogState state) {
    if (state.bukuList.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: EmptyState(
              icon: Icons.menu_book,
              title: 'Belum Ada Buku',
              subtitle: state.searchQuery.isNotEmpty
                  ? 'Tidak ada buku yang cocok dengan "${state.searchQuery}"'
                  : 'Data buku akan muncul di sini.',
              actionLabel: state.searchQuery.isNotEmpty ? 'Hapus Filter' : 'Muat Ulang',
              onAction: () {
                ref.read(katalogProvider.notifier).loadData(
                      search: null,
                      kategoriId: null,
                    );
                setState(() {
                  _currentSearch = '';
                  _selectedCategoryId = null;
                });
              },
            ),
          ),
        ),
      );
    }

    final books = state.bukuList;
    final left = <_IndexedBook>[];
    final right = <_IndexedBook>[];
    double leftH = 0;
    double rightH = 0;

    for (var i = 0; i < books.length; i++) {
      final book = books[i];
      final h = _cardHeight(book);
      if (leftH <= rightH) {
        left.add(_IndexedBook(book, i));
        leftH += h + AppSpacing.md;
      } else {
        right.add(_IndexedBook(book, i));
        rightH += h + AppSpacing.md;
      }
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: left
                    .map((b) => _buildMasonryCard(b.book, b.index))
                    .toList()
                    .cast<Widget>(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                children: right
                    .map((b) => _buildMasonryCard(b.book, b.index))
                    .toList()
                    .cast<Widget>(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasonryCard(BukuEntity book, int index) {
    final cell = _masonryCardContent(book);
    return StaggerCell(index: index, child: cell);
  }

  double _cardHeight(BukuEntity book) {
    final coverHeights = [150.0, 172.0, 194.0, 216.0];
    final cover = coverHeights[book.id % coverHeights.length];
    return cover + 86; // approx info block height
  }

  Widget _masonryCardContent(BukuEntity book) {
    final coverHeights = [150.0, 172.0, 194.0, 216.0];
    final coverHeight = coverHeights[book.id % coverHeights.length];
    final isAvailable = (book.stokTersedia ?? 0) > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: () => context.push(RouteNames.bookDetail, extra: book),
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
              Stack(
                children: [
                  Hero(
                    tag: 'book_cover_${book.id}',
                    child: ProceduralBookCover(
                      title: book.judul,
                      author: book.penulis,
                      bookId: book.id,
                      height: coverHeight,
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.successContainer
                            : AppColors.dangerContainer,
                        borderRadius: AppRadius.badge,
                      ),
                      child: Text(
                        isAvailable ? 'Tersedia' : 'Habis',
                        style: AppTypography.labelSm.copyWith(
                          color: isAvailable
                              ? AppColors.onSuccessContainer
                              : AppColors.onDangerContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      book.penulis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (book.namaKategori != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        book.namaKategori!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<CategoryItem> _buildCategories(KatalogState state) {
    final apiCategories = state.filters['kategori'];
    final dynamicCategories = apiCategories is List
        ? CategoryItem.fromApiData(apiCategories)
        : const <CategoryItem>[];

    return [const CategoryItem(label: 'Semua'), ...dynamicCategories];
  }

  int _resolveSelectedIndex(List<CategoryItem> categories) {
    if (_selectedCategoryId == null) {
      return 0;
    }

    final index = categories.indexWhere(
      (category) => category.id == _selectedCategoryId,
    );
    return index >= 0 ? index : 0;
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyFilterDelegate({required this.child});

  @override
  double get minExtent => 120;

  @override
  double get maxExtent => 120;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) => false;
}

class _IndexedBook {
  final BukuEntity book;
  final int index;

  _IndexedBook(this.book, this.index);
}
