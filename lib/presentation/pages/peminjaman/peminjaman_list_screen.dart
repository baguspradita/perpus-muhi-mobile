import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
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

class _PeminjamanScreenState extends ConsumerState<PeminjamanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 1) {
      ref.read(peminjamanProvider.notifier).loadPeminjamanRiwayat();
    } else {
      ref.read(peminjamanProvider.notifier).loadPeminjamanAktif();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_tabController.index == 0 ? 'Pinjaman' : 'Riwayat Peminjaman'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.rPill,
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.rPill,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.outline,
                labelStyle: AppTypography.labelMd,
                unselectedLabelStyle: AppTypography.labelMd,
                dividerHeight: 0,
                tabs: const [
                  Tab(text: 'Aktif'),
                  Tab(text: 'Riwayat'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _tabController.index == 0
                ? _buildActiveTab(context)
                : _buildHistoryTab(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab(BuildContext context) {
    final peminjamanState = ref.watch(peminjamanProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AppSearchBar(
            hintText: 'Cari nama siswa atau buku...',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: peminjamanState.isLoading
              ? _buildLoadingState()
              : peminjamanState.errorMessage.isNotEmpty
                  ? _buildErrorState(peminjamanState.errorMessage)
                  : _buildPeminjamanList(peminjamanState.peminjamanAktif),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final peminjamanState = ref.watch(peminjamanProvider);

    return Column(
      children: [
        Expanded(
          child: peminjamanState.isLoading
              ? _buildLoadingState()
              : peminjamanState.errorMessage.isNotEmpty
                  ? _buildErrorState(peminjamanState.errorMessage)
                  : _buildPeminjamanList(peminjamanState.peminjamanRiwayat),
        ),
      ],
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

  Widget _buildPeminjamanList(List<PeminjamanEntity> peminjaman) {
    if (peminjaman.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: EmptyState(
            icon: Icons.history_outlined,
            title: _tabController.index == 0
                ? 'Belum Ada Pinjaman Aktif'
                : 'Belum Ada Riwayat',
            subtitle: _tabController.index == 0
                ? 'Pinjaman aktif Anda akan muncul di sini.'
                : 'Riwayat peminjaman Anda akan muncul di sini.',
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
      itemCount: peminjaman.length,
      itemBuilder: (context, index) =>
          _buildPeminjamanCard(context, peminjaman[index]),
    );
  }

  Widget _buildPeminjamanCard(
      BuildContext context, PeminjamanEntity peminjaman) {
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
                    style: AppTypography.bodyLg
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    peminjaman.tglPinjam,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isReturned
                          ? AppColors.successLight
                          : AppColors.warningLight,
                      borderRadius: AppRadius.rSm,
                    ),
                    child: Text(
                      isReturned ? 'Dikembalikan' : peminjaman.status,
                      style: AppTypography.bodySmall.copyWith(
                        color:
                            isReturned ? AppColors.success : AppColors.warning,
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
                  onPressed: () =>
                      _showPeminjamanDetail(context, peminjaman),
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Lihat Detail',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPeminjamanDetail(
      BuildContext context, PeminjamanEntity peminjaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        title: const Text('Detail Peminjaman'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Peminjam', peminjaman.userName),
              _buildDetailRow('Tanggal Pinjam', formatDate(peminjaman.tglPinjam)),
              _buildDetailRow('Jatuh Tempo', formatDate(peminjaman.tglJatuhTempo)),
              _buildDetailRow('Status', peminjaman.status),
              if (peminjaman.denda != null && peminjaman.denda! > 0)
                _buildDetailRow('Denda', 'Rp ${peminjaman.denda}'),
              const SizedBox(height: AppSpacing.md),
              Text('Detail Buku:',
                  style: AppTypography.heading3.copyWith(fontSize: 14)),
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
            child: Text(label,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  String formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
