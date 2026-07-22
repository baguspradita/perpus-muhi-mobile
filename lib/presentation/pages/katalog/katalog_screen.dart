import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/buku_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/katalog_provider.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/book_scroll_widgets.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import 'book_detail_screen.dart';

class KatalogScreen extends ConsumerStatefulWidget {
  const KatalogScreen({super.key});

  @override
  ConsumerState<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends ConsumerState<KatalogScreen> {
  final _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  bool _filtersLoaded = false;

  @override
  void initState() {
    super.initState();
    // Trigger load data when provider is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_filtersLoaded) {
        ref.read(katalogProvider.notifier).loadData();
        _filtersLoaded = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final katalogState = ref.watch(katalogProvider);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('iPustaka', style: AppTypography.display),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_outlined),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSearchBar(
                hintText: 'Cari judul buku atau penulis...',
                onChanged: (value) {
                  ref.read(katalogProvider.notifier).loadData(search: value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (katalogState.isLoading || !_filtersLoaded) ...[
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.categoryBg,
                    borderRadius: AppRadius.rXl,
                    border: Border.all(color: AppColors.borderLight, width: 1),
                  ),
                );
              },
            ),
          ),
        ] else ...[
          CategoryChipsScroll(
            categories: CategoryItem.fromApiData(
                (katalogState.filters['kategori'] as List? ?? []),
            ),
            selectedIndex: _selectedCategoryIndex,
            onCategorySelected: (index) {
              setState(() => _selectedCategoryIndex = index);
            },
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: katalogState.isLoading
              ? _buildLoadingState()
              : katalogState.errorMessage.isNotEmpty
                  ? _buildErrorState(katalogState.errorMessage)
                  : _buildKatalogList(katalogState),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 6,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: LoadingShimmer(
          height: 140,
          width: double.infinity,
          borderRadius: 16,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Gagal Memuat Data',
          subtitle: error,
          actionLabel: 'Coba Lagi',
          onAction: () {
            ref.read(katalogProvider.notifier).loadData();
          },
        ),
      ),
    );
  }

  Widget _buildKatalogList(KatalogState state) {
    if (state.bukuList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: EmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Belum Ada Data Buku',
            subtitle: state.searchQuery.isNotEmpty
                ? 'Tidak ada buku yang cocok dengan "${state.searchQuery}"'
                : 'Data buku akan muncul di sini setelah diambil dari server.',
            actionLabel: state.searchQuery.isNotEmpty ? 'Hapus Filter' : 'Muat Ulang',
            onAction: () {
              ref.read(katalogProvider.notifier).loadData(
                    search: state.searchQuery.isEmpty ? null : '',
                  );
            },
          ),
        ),
      );
    }

    final popular = state.bukuList.take(6).toList();
    final recommended = state.bukuList.length > 6
        ? state.bukuList.sublist(6, state.bukuList.length.clamp(6, 12))
        : <BukuEntity>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          const BannerCarousel(),
          const SizedBox(height: AppSpacing.xxl),
          PopularBooksScroll(
            title: 'Populer',
            books: popular,
            onTap: (buku) => _showBookDetail(context, buku),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (recommended.isNotEmpty)
            RecommendedBooksGrid(
              title: 'Rekomendasi',
              books: recommended,
              onTap: (buku) => _showBookDetail(context, buku),
            ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _showBookDetail(BuildContext context, BukuEntity buku) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => BookDetailScreen(book: buku),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  Color _getCoverColor(int id) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
    ];
    return colors[id % colors.length];
  }
}
