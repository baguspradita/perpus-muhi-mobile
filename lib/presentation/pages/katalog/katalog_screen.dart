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
  final _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(katalogProvider.notifier).loadData();
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
                ref.read(katalogProvider.notifier).loadData(search: value);
              },
              prefixIcon: const Icon(Icons.search, color: AppColors.outline, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Category Chips
          CategoryChipsScroll(
            categories: CategoryItem.staticCategories(),
            selectedIndex: _selectedCategoryIndex,
            onCategorySelected: (index) {
              setState(() => _selectedCategoryIndex = index);
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
            style: AppTypography.bodySm.copyWith(
              color: AppColors.outline,
            ),
          ),
        ],
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
            actionLabel: state.searchQuery.isNotEmpty ? 'Hapus Filter' : 'Muat Ulang',
            onAction: () {
              ref.read(katalogProvider.notifier).loadData(
                    search: null,
                  );
            },
          ),
        ),
      );
    }

    final bukuBuku = _searchController.text.isNotEmpty
        ? state.bukuList
        : state.bukuList;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: bukuBuku.length,
      itemBuilder: (context, index) {
        final buku = bukuBuku[index];
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
