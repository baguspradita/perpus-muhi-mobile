import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/peminjaman_entity.dart';
import '../../providers/peminjaman_provider.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/page_header.dart';

class PeminjamanScreen extends ConsumerStatefulWidget {
  const PeminjamanScreen({super.key});

  @override
  ConsumerState<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends ConsumerState<PeminjamanScreen> {
  @override
  Widget build(BuildContext context) {
    final peminjamanState = ref.watch(peminjamanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Peminjaman',
                  subtitle: 'Kelola transaksi peminjaman buku',
                  actions: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppSearchBar(
                  hintText: 'Cari nama siswa atau buku...',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: peminjamanState.isLoading
                ? _buildLoadingState()
                : peminjamanState.errorMessage.isNotEmpty
                    ? _buildErrorState(peminjamanState.errorMessage)
                    : _buildPeminjamanList(peminjamanState.peminjaman),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 4,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: LoadingShimmer(
          height: 100,
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
            ref.read(peminjamanProvider.notifier).loadPeminjaman();
          },
        ),
      ),
    );
  }

  Widget _buildPeminjamanList(List<PeminjamanEntity> peminjaman) {
    if (peminjaman.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: EmptyState(
            icon: Icons.history_outlined,
            title: 'Belum Ada Data Peminjaman',
            subtitle: 'Daftar peminjaman akan muncul di sini.',
            actionLabel: 'Muat Ulang',
            onAction: () {
              ref.read(peminjamanProvider.notifier).loadPeminjaman();
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
      itemCount: peminjaman.length,
      itemBuilder: (context, index) => _buildPeminjamanCard(context, peminjaman[index]),
    );
  }

  Widget _buildPeminjamanCard(BuildContext context, PeminjamanEntity peminjaman) {
    final isReturned = peminjaman.status.toLowerCase() == 'dikembalikan' ||
        peminjaman.tglKembali != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReturned ? AppColors.successLight : AppColors.warningLight,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isReturned ? AppColors.successLight : AppColors.warningLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isReturned ? Icons.check_circle : Icons.book,
                color: isReturned ? AppColors.success : AppColors.warning,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peminjaman.userName,
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    peminjaman.tglPinjam,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isReturned ? AppColors.successLight : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isReturned ? 'Dikembalikan' : peminjaman.status,
                      style: AppTypography.bodySmall.copyWith(
                        color: isReturned ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _showPeminjamanDetail(context, peminjaman),
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Lihat Detail',
                ),
                if (!isReturned)
                  IconButton(
                    onPressed: () => _confirmKembaliPeminjaman(context, peminjaman.id),
                    icon: const Icon(Icons.check_circle_outline),
                    color: AppColors.success,
                    tooltip: 'Kembalikan Buku',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPeminjamanDetail(BuildContext context, PeminjamanEntity peminjaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Detail Peminjaman'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', peminjaman.id.toString()),
              _buildDetailRow('Peminjam', peminjaman.userName),
              _buildDetailRow('Tanggal Pinjam', peminjaman.tglPinjam),
              _buildDetailRow('Jatuh Tempo', peminjaman.tglJatuhTempo),
              _buildDetailRow('Status', peminjaman.status),
              if (peminjaman.denda != null && peminjaman.denda! > 0)
                _buildDetailRow('Denda', 'Rp ${peminjaman.denda}'),
              const SizedBox(height: AppSpacing.md),
              Text('Detail Buku:', style: AppTypography.heading3.copyWith(fontSize: 14)),
              ...peminjaman.details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(Icons.book, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${detail.judulBuku} (x${detail.jumlah})',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
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
            child: Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  void _confirmKembaliPeminjaman(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Pengembalian'),
        content: const Text('Apakah Anda yakin buku ini sudah dikembalikan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _kembaliPeminjaman(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  void _kembaliPeminjaman(int id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    ref.read(peminjamanProvider.notifier).kembaliPeminjaman(id).then((_) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil dikembalikan'), backgroundColor: AppColors.success),
        );
      }
    });
  }
}
