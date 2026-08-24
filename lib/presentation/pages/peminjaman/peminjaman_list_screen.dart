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
                  color: Colors.white,
                  borderRadius: AppRadius.rPill,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.primary,
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
          height: 110,
          width: double.infinity,
          borderRadius: 12,
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
      itemBuilder: (context, index) =>
          _buildPeminjamanCard(context, peminjaman[index]),
    );
  }

  Widget _buildPeminjamanCard(
      BuildContext context, PeminjamanEntity peminjaman) {
    final detail = peminjaman.details.isNotEmpty ? peminjaman.details.first : null;
    final judul = detail?.judulBuku ?? 'Buku Tidak Diketahui';
    final penulis = detail?.penulis ?? 'Penulis Tidak Diketahui';
    final coverUrl = detail?.coverUrl;

    final isReturned = peminjaman.status.toLowerCase() == 'dikembalikan' ||
        peminjaman.status.toLowerCase() == 'kembali' ||
        peminjaman.tglKembali != null;

    final tglPinjamFormatted = formatDateShort(peminjaman.tglPinjam);
    final tglJatuhTempoFormatted = formatDateShort(peminjaman.tglJatuhTempo);

    Widget badge;
    bool isLate = false;

    if (isReturned) {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: AppRadius.rPill,
        ),
        child: Text(
          'Dikembalikan',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      );
    } else {
      final now = DateTime.now();
      final jatuhTempo = DateTime.tryParse(peminjaman.tglJatuhTempo);
      if (jatuhTempo != null) {
        final today = DateTime(now.year, now.month, now.day);
        final jatuh = DateTime(jatuhTempo.year, jatuhTempo.month, jatuhTempo.day);
        if (today.isAfter(jatuh)) {
          isLate = true;
          badge = Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: AppRadius.rPill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 10),
                const SizedBox(width: 4),
                Text(
                  'Terlambat',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        } else {
          final diffDays = jatuh.difference(today).inDays;
          badge = Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: AppRadius.rPill,
            ),
            child: Text(
              'Sisa $diffDays Hari',
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF7E22CE),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          );
        }
      } else {
        badge = Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: AppRadius.rPill,
          ),
          child: Text(
            peminjaman.status,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        );
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.rMd,
        side: BorderSide(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _showPeminjamanDetail(context, peminjaman),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isLate && !isReturned)
                Container(
                  width: 4,
                  color: AppColors.danger,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.rSm,
                        child: Container(
                          width: 56,
                          height: 76,
                          color: Colors.grey.shade100,
                          child: coverUrl != null && coverUrl.isNotEmpty
                              ? Image.network(
                                  coverUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildCoverPlaceholder(peminjaman.id, judul),
                                )
                              : _buildCoverPlaceholder(peminjaman.id, judul),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    judul,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodyLg.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                badge,
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              penulis.isNotEmpty ? penulis : 'Penulis Tidak Diketahui',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TGL PINJAM',
                                        style: AppTypography.bodySmall.copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textSecondary.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        tglPinjamFormatted,
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSurface,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isReturned ? 'TGL KEMBALI' : 'TGL KEMBALI',
                                        style: AppTypography.bodySmall.copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textSecondary.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        isReturned ? formatDateShort(peminjaman.tglKembali ?? '') : tglJatuhTempoFormatted,
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSurface,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildCoverPlaceholder(int id, String title) {
    final colors = [
      const Color(0xFFEFF6FF),
      const Color(0xFFFEF2F2),
      const Color(0xFFECFDF5),
      const Color(0xFFFFFBEB),
    ];
    final textColors = [
      const Color(0xFF1D4ED8),
      const Color(0xFFB91C1C),
      const Color(0xFF047857),
      const Color(0xFFB45309),
    ];
    final colorIndex = id % colors.length;
    return Container(
      color: colors[colorIndex],
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: Text(
        title.isNotEmpty ? title[0].toUpperCase() : 'B',
        style: AppTypography.headlineMd.copyWith(
          color: textColors[colorIndex],
          fontWeight: FontWeight.bold,
          fontSize: 18,
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
              const SizedBox(height: AppSpacing.sm),
              Text('Detail Buku:',
                  style: AppTypography.heading3.copyWith(fontSize: 14)),
              ...peminjaman.details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(top: 2),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
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
}
