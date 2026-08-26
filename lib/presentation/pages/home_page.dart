import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/buku_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/dashboard_buku_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/user_avatar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static bool _notifCountInitialized = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    if (!_notifCountInitialized) {
      _notifCountInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(notificationProvider.notifier).loadUnreadCount();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Beranda'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final unreadCount = ref.watch(notificationProvider).unreadBadge;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Notifikasi',
                    onPressed: () => context.push(RouteNames.notifications),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
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
          UserAvatar(
            name: user?.nama ?? 'U',
            size: 44,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            showBorder: false,
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
              ),
            ),
          ],
        ),
      ],
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
