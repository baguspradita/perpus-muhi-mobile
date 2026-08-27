import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/peminjaman_entity.dart';
import '../../providers/peminjaman_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/page_header.dart';
import '../../widgets/procedural_book_cover.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
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
          ),
          if (peminjamanState.isLoading)
            SliverToBoxAdapter(child: _buildLoadingState())
          else if (peminjamanState.errorMessage.isNotEmpty)
            SliverToBoxAdapter(child: _buildErrorState(peminjamanState.errorMessage))
          else
            _buildRiwayatSliver(peminjamanState.peminjamanRiwayat),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: List.generate(
          4,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: LoadingShimmer(
              height: 100,
              width: double.infinity,
              borderRadius: 16,
            ),
          ),
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

  Widget _buildRiwayatSliver(List<PeminjamanEntity> riwayat) {
    if (riwayat.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
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
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildRiwayatCard(context, riwayat[index]),
        childCount: riwayat.length,
      ),
    );
  }

  Widget _buildRiwayatCard(BuildContext context, PeminjamanEntity peminjaman) {
    final isReturned = peminjaman.status.toLowerCase() == 'dikembalikan' ||
        peminjaman.tglKembali != null;

    final detail = peminjaman.details.isNotEmpty ? peminjaman.details.first : null;
    final judul = detail?.judulBuku ?? 'Buku Tidak Diketahui';
    final penulis = detail?.penulis ?? 'Penulis Tidak Diketahui';
    final coverUrl = detail?.coverUrl;
    final bookId = detail?.bukuId ?? peminjaman.id;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppGradients.elevation2,
      ),
      child: InkWell(
        onTap: () => _showRiwayatDetail(context, peminjaman),
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.rMd,
                child: SizedBox(
                  width: 56,
                  height: 76,
                  child: coverUrl != null && coverUrl.isNotEmpty
                      ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildCoverPlaceholder(bookId, judul),
                        )
                      : _buildCoverPlaceholder(bookId, judul),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peminjaman.userName,
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppDateUtils.formatDate(
                          DateTime.tryParse(peminjaman.tglPinjam) ?? DateTime.now()),
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (peminjaman.tglKembali != null) ...[
                      Text(
                        'Dikembalikan: ${AppDateUtils.formatDate(DateTime.tryParse(peminjaman.tglKembali!) ?? DateTime.now())}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    Row(
                      children: [
                        AppBadge(
                          text: isReturned ? 'Dikembalikan' : peminjaman.status,
                          variant: isReturned
                              ? AppBadgeVariant.success
                              : AppBadgeVariant.warning,
                        ),
                        if (peminjaman.denda != null && peminjaman.denda! > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Denda: ${_formatCurrency(peminjaman.denda!)}',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showRiwayatDetail(context, peminjaman),
                icon: const Icon(Icons.visibility_rounded),
                tooltip: 'Lihat Detail',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder(int id, String title) {
    return ProceduralBookCover(
      title: title,
      author: '',
      bookId: id,
      fit: BoxFit.cover,
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
              _buildDetailRow('Tanggal Pinjam',
                  AppDateUtils.formatDate(DateTime.tryParse(peminjaman.tglPinjam) ?? DateTime.now())),
              _buildDetailRow('Jatuh Tempo',
                  AppDateUtils.formatDate(DateTime.tryParse(peminjaman.tglJatuhTempo) ?? DateTime.now())),
              _buildDetailRow('Status', peminjaman.status),
              if (peminjaman.tglKembali != null)
                _buildDetailRow('Tanggal Kembali',
                    AppDateUtils.formatDate(DateTime.tryParse(peminjaman.tglKembali!) ?? DateTime.now())),
              if (peminjaman.denda != null && peminjaman.denda! > 0)
                _buildDetailRow('Denda', 'Rp ${peminjaman.denda}'),
              const SizedBox(height: AppSpacing.md),
              Text('Detail Buku:', style: AppTypography.heading3.copyWith(fontSize: 14)),
              ...peminjaman.details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book, size: 16),
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
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  String _formatCurrency(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }
}