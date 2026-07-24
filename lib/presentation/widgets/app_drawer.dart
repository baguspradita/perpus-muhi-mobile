import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Drawer(
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 0,
      shape: const Border(
        right: BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, user),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  _DrawerSection(
                    title: 'MENU UTAMA',
                    children: [
                      _DrawerItem(
                        icon: Icons.person_outline,
                        label: 'Profil Saya',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(RouteNames.profile);
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.settings_outlined,
                        label: 'Pengaturan',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(RouteNames.profile);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DrawerSection(
                    title: 'BANTUAN',
                    children: [
                      _DrawerItem(
                        icon: Icons.help_outline,
                        label: 'Bantuan & FAQ',
                        onTap: () {
                          Navigator.pop(context);
                          context.push(RouteNames.faq);
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.info_outline,
                        label: 'Tentang Aplikasi',
                        onTap: () {
                          Navigator.pop(context);
                          context.push(RouteNames.about);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildFooter(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserEntity? user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  user?.nama?.isNotEmpty == true
                      ? user!.nama[0].toUpperCase()
                      : 'U',
                  style: AppTypography.heading1.copyWith(
                    color: AppColors.primary,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.nama ?? 'User',
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.rPill,
                      ),
                      child: Text(
                        user?.role?.toUpperCase() ?? 'SISWA',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _HeaderAction(
                  icon: Icons.badge_outlined,
                  label: 'Identitas',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(RouteNames.identification);
                  },
                ),
              ),
              Expanded(
                child: _HeaderAction(
                  icon: Icons.history_outlined,
                  label: 'Riwayat',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouteNames.peminjaman);
                  },
                ),
              ),
              Expanded(
                child: _HeaderAction(
                  icon: Icons.favorite_outline,
                  label: 'Favorit',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(RouteNames.katalog);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          _DrawerItem(
            icon: Icons.logout,
            label: 'Keluar',
            isDestructive: true,
            onTap: () => _showLogoutDialog(context, ref),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'v1.0.0',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DrawerSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            title,
            style: AppTypography.labelMd.copyWith(
              color: AppColors.outline,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.onSurfaceVariant;
    final bgColor = isDestructive ? AppColors.errorLight : AppColors.surfaceContainerLow;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.rMd,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: AppTypography.bodyLg.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
        dense: true,
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.rMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.rMd,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}