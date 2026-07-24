import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/peminjaman_entity.dart';
import '../../providers/peminjaman_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/page_header.dart';

class RiwayatScreen extends ConsumerStatefulWidget {
  const RiwayatScreen({super.key});

  @override
  ConsumerState<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends ConsumerState<RiwayatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(peminjamanProvider.notifier).loadPeminjamanRiwayat();
    });
  }

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
                  title: 'Riwayat Peminjaman',
                  subtitle: 'Lihat history peminjaman Anda',
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: peminjamanState.isLoading
                ? _buildLoadingState()
                : peminjamanState.errorMessage.isNotEmpty
                    ? _buildErrorState(peminjamanState.errorMessage)
                    : _buildRiwayatList(peminjamanState.peminjamanRiwayat),
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
            ref.read(peminjamanProvider.notifier).loadAllData();
          },
        ),
      ),
    );
  }

  Widget _buildRiwayatList(List<PeminjamanEntity> riwayat) {
    if (riwayat.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: EmptyState(
            icon: Icons.history_outlined,
            title: 'Belum Ada Riwayat',
            subtitle: 'Riwayat peminjaman akan muncul di sini.',
            actionLabel: 'Muat Ulang',
            onAction: () {
              ref.read(peminjamanProvider.notifier).loadAllData();
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
      itemCount: riwayat.length,
      itemBuilder: (context, index) => _buildRiwayatCard(context, riwayat[index]),
    );
  }

  Widget _buildRiwayatCard(BuildContext context, PeminjamanEntity peminjaman) {
    final isReturned = peminjaman.status.toLowerCase() == 'dikembalikan' ||
        peminjaman.tglKembali != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.rMd,
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
                borderRadius: AppRadius.rMd,
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
                  if (peminjaman.tglKembali != null) ...[
                    Text(
                      'Dikembalikan: ${peminjaman.tglKembali}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isReturned ? AppColors.successLight : AppColors.warningLight,
                      borderRadius: AppRadius.rSm,
                    ),
                    child: Text(
                      isReturned ? 'Dikembalikan' : peminjaman.status,
                      style: AppTypography.bodySmall.copyWith(
                        color: isReturned ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (peminjaman.denda != null && peminjaman.denda! > 0) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Denda: Rp ${peminjaman.denda}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showRiwayatDetail(context, peminjaman),
              icon: const Icon(Icons.visibility_outlined),
              tooltip: 'Lihat Detail',
            ),
          ],
        ),
      ),
    );
  }

  void _showRiwayatDetail(BuildContext context, PeminjamanEntity peminjaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        title: const Text('Detail Riwayat'),
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
              if (peminjaman.tglKembali != null)
                _buildDetailRow('Tanggal Kembali', peminjaman.tglKembali!),
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
}