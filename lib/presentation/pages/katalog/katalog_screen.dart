import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/buku_entity.dart';
import '../../providers/katalog_provider.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/book_card.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';

class KatalogScreen extends ConsumerStatefulWidget {
  const KatalogScreen({super.key});

  @override
  ConsumerState<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends ConsumerState<KatalogScreen> {
  String _currentSearch = '';
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final katalogState = ref.watch(katalogProvider);
    final categories = _buildCategories(katalogState);
    final selectedIndex = _resolveSelectedIndex(categories);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Katalog'),
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifikasi',
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: AppSearchBar(
              hintText: 'Cari buku, penulis, atau ISBN...',
              onChanged: (value) {
                setState(() => _currentSearch = value);
                ref
                    .read(katalogProvider.notifier)
                    .loadData(search: value, kategoriId: _selectedCategoryId);
              },
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.outline,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Category Chips
          katalogState.isFiltersLoading
              ? _buildCategoryLoadingState()
              : CategoryChipsScroll(
                  categories: categories,
                  selectedIndex: selectedIndex,
                  onCategorySelected: (index) {
                    final selectedCategoryId = index == 0
                        ? null
                        : categories[index].id;
                    setState(() => _selectedCategoryId = selectedCategoryId);
                    ref
                        .read(katalogProvider.notifier)
                        .loadData(
                          search: _currentSearch.isEmpty
                              ? null
                              : _currentSearch,
                          kategoriId: selectedCategoryId,
                        );
                  },
                ),
          const SizedBox(height: AppSpacing.md),
          // Book Grid
          Expanded(
            child: katalogState.isLoading
                ? _buildLoadingState()
                : katalogState.errorMessage.isNotEmpty
                ? _buildErrorState(katalogState.errorMessage)
                : _buildBookGrid(katalogState),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          const CircularProgressIndicator(
            color: AppColors.outline,
            strokeWidth: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Memuat buku lainnya...',
            style: AppTypography.bodySm.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLoadingState() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final widths = [72.0, 64.0, 80.0, 76.0];
          return LoadingShimmer(
            width: widths[index],
            height: 32,
            borderRadius: 999,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
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

  Widget _buildBookGrid(KatalogState state) {
    if (state.bukuList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: EmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Belum Ada Buku',
            subtitle: state.searchQuery.isNotEmpty
                ? 'Tidak ada buku yang cocok dengan "${state.searchQuery}"'
                : 'Data buku akan muncul di sini.',
            actionLabel: state.searchQuery.isNotEmpty
                ? 'Hapus Filter'
                : 'Muat Ulang',
            onAction: () {
              ref
                  .read(katalogProvider.notifier)
                  .loadData(search: null, kategoriId: null);
              setState(() {
                _currentSearch = '';
                _selectedCategoryId = null;
              });
            },
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: state.bukuList.length,
      itemBuilder: (context, index) {
        final buku = state.bukuList[index];
        return BookCard(
          title: buku.judul,
          author: buku.penulis,
          coverColor: _getCoverColor(buku.id),
          isAvailable: (buku.stokTersedia ?? 0) > 0,
          onTap: () {},
          isGridMode: true,
        );
      },
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

  Color _getCoverColor(int id) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.primaryContainer,
      AppColors.info,
    ];
    return colors[id % colors.length];
  }
}
