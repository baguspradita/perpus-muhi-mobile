import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_effects.dart';
import '../../../domain/entities/peminjaman_entity.dart';
import '../../providers/peminjaman_provider.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_button.dart';
import '../../widgets/procedural_book_cover.dart';
import '../../widgets/staggered_list.dart';

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
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peminjamanState = ref.watch(peminjamanProvider);
    final activeCount = peminjamanState.peminjamanAktif.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Pinjaman'),
        centerTitle: true,
        actions: [],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              height: 46,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.rPill,
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.rPill,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowPrimary.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.onPrimary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                labelStyle: AppTypography.labelMd.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: AppTypography.labelMd.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                dividerHeight: 0,
                tabs: [
                  Tab(text: 'Aktif ($activeCount)'),
                  const Tab(text: 'Riwayat'),
                ],
              ),
            ),
          ),
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
        const SizedBox(height: AppSpacing.sm),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 4,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: LoadingShimmer(
          height: 120,
          width: double.infinity,
          borderRadius: 16,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
          padding: const EdgeInsets.all(AppSpacing.md),
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      itemCount: peminjaman.length,
      itemBuilder: (context, index) => StaggerCell(
        index: index,
        child: _buildPeminjamanCard(context, peminjaman[index]),
      ),
    );
  }

  Widget _buildPeminjamanCard(
      BuildContext context, PeminjamanEntity peminjaman) {
    final detail = peminjaman.details.isNotEmpty ? peminjaman.details.first : null;
    final judul = detail?.judulBuku ?? 'Buku Tidak Diketahui';
    final penulis = detail?.penulis ?? 'Penulis Tidak Diketahui';
    final coverUrl = detail?.coverUrl;
    final bookId = detail?.bukuId ?? peminjaman.id;

    final isReturned = peminjaman.status.toLowerCase() == 'dikembalikan' ||
        peminjaman.status.toLowerCase() == 'kembali' ||
        peminjaman.tglKembali != null;

    final tglPinjamFormatted = formatDateShort(peminjaman.tglPinjam);
    final tglJatuhTempoFormatted = formatDateShort(peminjaman.tglJatuhTempo);
    final denda = peminjaman.hitungDenda();

    bool isLate = false;
    if (!isReturned) {
      final jatuhTempo = DateTime.tryParse(peminjaman.tglJatuhTempo);
      if (jatuhTempo != null) {
        final today = DateTime.now();
        final jatuh = DateTime(jatuhTempo.year, jatuhTempo.month, jatuhTempo.day);
        final nowDay = DateTime(today.year, today.month, today.day);
        if (nowDay.isAfter(jatuh)) isLate = true;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: isLate && !isReturned
            ? Border.all(color: AppColors.danger, width: 1.5)
            : null,
        boxShadow: AppGradients.elevation2,
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _showPeminjamanDetail(context, peminjaman),
        borderRadius: AppRadius.card,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 64,
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              judul,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyLg.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildStatusBadge(isReturned, isLate, peminjaman),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        penulis.isNotEmpty ? penulis : 'Penulis Tidak Diketahui',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _MetaDate(
                              label: 'Pinjam',
                              value: tglPinjamFormatted,
                            ),
                          ),
                          Expanded(
                            child: _MetaDate(
                              label: isReturned ? 'Kembali' : 'Tempo',
                              value: isReturned
                                  ? formatDateShort(peminjaman.tglKembali ?? '')
                                  : tglJatuhTempoFormatted,
                              danger: isLate && !isReturned,
                            ),
                          ),
                        ],
                      ),
                      if (isLate && !isReturned && denda > 0) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Denda: ${_formatCurrency(denda)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      // CTA for active loans
                      if (!isReturned) ...[
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Kembalikan',
                                type: AppButtonType.filled,
                                icon: Icons.assignment_return_rounded,
                                onPressed: () => _confirmReturn(context, peminjaman),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    bool isReturned,
    bool isLate,
    PeminjamanEntity peminjaman,
  ) {
    if (isReturned) {
      return AppBadge(
        text: 'Dikembalikan',
        variant: AppBadgeVariant.success,
        fontSize: 10,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      );
    }
    if (isLate) {
      return AppBadge(
        text: 'Terlambat',
        variant: AppBadgeVariant.danger,
        fontSize: 10,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      );
    }
    if (peminjaman.tglJatuhTempo.isNotEmpty) {
      final jatuh = DateTime.tryParse(peminjaman.tglJatuhTempo);
      if (jatuh != null) {
        final diff = jatuh.difference(DateTime.now()).inDays;
        return AppBadge(
          text: 'Sisa $diff Hari',
          variant: AppBadgeVariant.info,
          fontSize: 10,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        );
      }
    }
    return AppBadge(
      text: peminjaman.status,
      variant: AppBadgeVariant.warning,
      fontSize: 10,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  void _confirmReturn(BuildContext context, PeminjamanEntity peminjaman) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        title: const Text('Konfirmasi Pengembalian'),
        content: const Text('Yakin ingin mengembalikan buku ini?'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Batal',
                  type: AppButtonType.text,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Kembalikan',
                  type: AppButtonType.filled,
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ref
                        .read(peminjamanProvider.notifier)
                        .kembaliPeminjaman(peminjaman.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Buku berhasil dikembalikan'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.rMd,
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
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
              const SizedBox(height: AppSpacing.sm),
              Text('Detail Buku:',
                  style: AppTypography.heading3.copyWith(fontSize: 14)),
              ...peminjaman.details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(top: 2),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
            ),
          ),
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

  String formatDateShort(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final shortMonths = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${shortMonths[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatCurrency(int value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(value);
  }
}

class _MetaDate extends StatelessWidget {
  final String label;
  final String value;
  final bool danger;

  const _MetaDate({
    required this.label,
    required this.value,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.dataXs.copyWith(
            fontWeight: FontWeight.w600,
            color: danger ? AppColors.danger : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
