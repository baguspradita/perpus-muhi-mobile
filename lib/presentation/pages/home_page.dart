import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/peminjaman_entity.dart';
import '../../domain/entities/buku_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/peminjaman_provider.dart';
import '../providers/dashboard_buku_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/stat_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Perpustakaan Muhi'),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifikasi',
                onPressed: () => context.push(RouteNames.notifications),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(context, user),
            const SizedBox(height: AppSpacing.lg),
            _buildStatsSection(context, ref),
            const SizedBox(height: AppSpacing.lg),
            _buildActiveLoansSection(context, ref),
            const SizedBox(height: AppSpacing.lg),
            _buildBookSection(
              context,
              'Rekomendasi Untuk Anda',
              ref.watch(dashboardBukuProvider).rekomendasiBuku,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildBookSection(
              context,
              'Buku Baru',
              ref.watch(dashboardBukuProvider).bukuBaru,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildBookSection(
              context,
              'Buku Populer Bulan Ini',
              ref.watch(dashboardBukuProvider).bukuPopuler,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, UserEntity? user) {
    final hour = DateTime.now().hour;
    final greeting = switch (hour) {
      < 11 => 'Selamat pagi',
      < 15 => 'Selamat siang',
      < 18 => 'Selamat sore',
      _ => 'Selamat malam',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.rMd,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.nama ?? 'User',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineLgMobile.copyWith(
                    fontSize: 20,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Perpustakaan Muhi',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final d = dashboardState.dashboard;

    return Column(
      children: [
        // Main stat card (full width)
        StatCard(
          title: 'Buku Tersedia',
          value: d?.totalBuku.toString() ?? '1,240',
          icon: Icons.menu_book,
          iconColor: AppColors.primaryContainer,
          bgColor: AppColors.surfaceContainerLowest,
          shadowColor: AppColors.shadowPrimary,
          isExpanded: true,
        ),
        const SizedBox(height: AppSpacing.md),
        // Row with 2 smaller cards
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Pinjaman Aktif',
                value: d?.peminjamanAktif.toString() ?? '2',
                icon: Icons.book_outlined,
                iconColor: AppColors.primary,
                bgColor: AppColors.surfaceContainerLowest,
                shadowColor: AppColors.shadowPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'Terlambat',
                value: d?.peminjamanTerlambat.toString() ?? '0',
                icon: Icons.warning_outlined,
                iconColor: AppColors.error,
                bgColor: AppColors.surfaceContainerLowest,
                shadowColor: AppColors.shadowPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveLoansSection(BuildContext context, WidgetRef ref) {
    final peminjamanState = ref.watch(peminjamanProvider);

    // Get only active loans
    final activeLoans = peminjamanState.peminjamanAktif
        .where((loan) => loan.status.toLowerCase() == 'dipinjam')
        .take(3)
        .toList();

    if (activeLoans.isEmpty && !peminjamanState.isLoading) {
      return const SizedBox.shrink();
    }

    if (peminjamanState.isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pinjaman Aktif', style: AppTypography.headlineMd),
            TextButton(
              onPressed: () {
                context.go(RouteNames.peminjaman);
              },
              child: Text(
                'Lihat Semua',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: activeLoans.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) =>
                _buildBookLoanCard(activeLoans[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildBookLoanCard(PeminjamanEntity loan) {
    final detail = loan.details.firstOrNull;
    final dueDate = loan.tglJatuhTempo;

    String formatDate(String dateStr) {
      if (dateStr.isEmpty) return '';
      try {
        final date = DateTime.parse(dateStr);
        return '${date.day.toString().padLeft(2, '0')} ${['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agus', 'Sep', 'Okt', 'Nov', 'Des'][date.month - 1]}, ${date.year}';
      } catch (e) {
        return dateStr;
      }
    }

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.rMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: Icon(Icons.book, size: 48, color: AppColors.primary),
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: AppRadius.rPill,
                    ),
                    child: Text(
                      'Dipinjam',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    detail?.judulBuku ?? 'Buku Pinjaman',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tempo: ${formatDate(dueDate)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookSection(
    BuildContext context,
    String title,
    List<BukuEntity> books,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.headlineMd),
            TextButton(
              onPressed: () {
                context.go(RouteNames.katalog);
              },
              child: Text(
                'Lihat Semua',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) =>
                _buildBookCard(context, books[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(BuildContext context, BukuEntity book) {
    const colors = [
      Color(0xFF6C63FF),
      Color(0xFF00B894),
      Color(0xFFE17055),
      Color(0xFF74B9FF),
      Color(0xFFA29BFE),
      Color(0xFFFD79A8),
    ];
    final coverColor = colors[book.id % colors.length];

    return GestureDetector(
      onTap: () {
        context.go(RouteNames.katalog);
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.rMd,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowPrimary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Icon(Icons.menu_book, size: 40, color: Colors.white70),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.penulis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
