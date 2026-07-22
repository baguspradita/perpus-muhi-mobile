import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/buku_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/katalog_provider.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/book_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/page_header.dart';

class KatalogScreen extends ConsumerStatefulWidget {
  const KatalogScreen({super.key});

  @override
  ConsumerState<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends ConsumerState<KatalogScreen> {
  final _searchController = TextEditingController();

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
        title: const Text('Katalog Buku'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Katalog Buku',
                  subtitle: 'Jelajahi dan temukan buku favoritmu',
                ),
                const SizedBox(height: AppSpacing.md),
                AppSearchBar(
                  hintText: 'Cari judul buku atau penulis...',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: katalogState.isLoading
                ? _buildLoadingState()
                : katalogState.errorMessage.isNotEmpty
                    ? _buildErrorState(katalogState.errorMessage)
                    : _buildKatalogList(katalogState),
          ),
        ],
      ),
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
            ref.read(katalogProvider.notifier).loadBuku();
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
              ref.read(katalogProvider.notifier).loadBuku(
                    search: state.searchQuery.isEmpty ? null : '',
                  );
            },
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: state.bukuList.length,
      itemBuilder: (context, index) {
        final buku = state.bukuList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: BookCard(
            title: buku.judul,
            author: buku.penulis,
            kategori: buku.namaKategori ?? 'Umum',
            isAvailable: buku.status == 'tersedia',
            coverColor: _getCoverColor(buku.id),
            onTap: () => _showBookDetail(context, buku),
          ),
        );
      },
    );
  }

  void _showBookDetail(BuildContext context, BukuEntity buku) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBookDetailSheet(context, buku),
    );
  }

  Widget _buildBookDetailSheet(BuildContext context, BukuEntity buku) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(buku.judul, style: AppTypography.heading2),
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow('Penulis', buku.penulis),
            _buildDetailRow('Penerbit', buku.penerbit),
            _buildDetailRow('Tahun Terbit', buku.tahunTerbit.toString()),
            _buildDetailRow('Kategori', buku.namaKategori ?? '-'),
            _buildDetailRow('Subjek', buku.namaSubjek ?? '-'),
            _buildDetailRow('Lokasi', buku.namaLokasi ?? '-'),
            _buildDetailRow('Jumlah', '${buku.jumlah} eksemplar'),
            _buildDetailRow('Status', buku.status),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: buku.status == 'tersedia'
                    ? () {
                        Navigator.pop(context);
                        _showPinjamDialog(context, buku);
                      }
                    : null,
                icon: const Icon(Icons.book_online),
                label: const Text('Pinjam Buku'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: AppTypography.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showPinjamDialog(BuildContext context, BukuEntity buku) {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Peminjaman'),
        content: Text('Pinjam "${buku.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createPeminjaman(context, buku, user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Pinjam'),
          ),
        ],
      ),
    );
  }

  void _createPeminjaman(BuildContext context, BukuEntity buku, int userId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Peminjaman "${buku.judul}" berhasil!'),
        backgroundColor: AppColors.success,
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
