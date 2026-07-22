import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/stat_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perpustakaan Muhi'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(context, user),
            const SizedBox(height: AppSpacing.xl),
            _buildStatsSection(context, ref),
            const SizedBox(height: AppSpacing.xxl),
            _buildMenuSection(context, authState),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, ${user?.nama ?? 'User'}',
          style: AppTypography.heading1.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Perpustakaan Muhi',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final d = dashboardState.dashboard;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          StatCard(
            title: 'TOTAL BUKU',
            value: d?.totalBuku.toString() ?? '-',
            icon: Icons.library_books,
            iconColor: AppColors.primary,
            bgColor: AppColors.primaryLight,
            shadowColor: AppColors.shadowPrimary,
          ),
          const SizedBox(width: AppSpacing.md),
          StatCard(
            title: 'TOTAL ANGGOTA',
            value: d?.totalAnggota.toString() ?? '-',
            icon: Icons.people,
            iconColor: AppColors.success,
            bgColor: AppColors.successLight,
            shadowColor: AppColors.shadowLight,
          ),
          const SizedBox(width: AppSpacing.md),
          StatCard(
            title: 'DIPINJAM',
            value: d?.peminjamanAktif.toString() ?? '-',
            icon: Icons.book,
            iconColor: AppColors.warning,
            bgColor: AppColors.warningLight,
            shadowColor: AppColors.shadowLight,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthState authState) {
    final isPetugas = authState.user?.role == 'petugas';

    final items = [
      {'title': 'Katalog', 'icon': Icons.menu_book, 'color': AppColors.primary, 'onTap': () => context.go(RouteNames.katalog)},
      {'title': 'Peminjaman', 'icon': Icons.history, 'color': AppColors.secondary, 'onTap': () => context.go(RouteNames.peminjaman)},
      {'title': 'Riwayat', 'icon': Icons.list_alt, 'color': AppColors.warning, 'onTap': () => context.go('/riwayat')},
      {'title': 'Profil', 'icon': Icons.person, 'color': AppColors.success, 'onTap': () => context.go(RouteNames.profile)},
      if (isPetugas) {'title': 'Master', 'icon': Icons.settings, 'color': AppColors.textSecondary, 'onTap': () {}},
      if (isPetugas) {'title': 'Anggota', 'icon': Icons.group, 'color': AppColors.textSecondary, 'onTap': () {}},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akses Cepat',
          style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.9,
          children: items.map((item) => _MenuCard(
            title: item['title'] as String,
            icon: item['icon'] as IconData,
            color: item['color'] as Color,
            onTap: item['onTap'] as VoidCallback,
          )).toList(),
        ),
      ],
    );
  }

}


class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}