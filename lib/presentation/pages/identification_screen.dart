import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../widgets/user_avatar.dart';

class IdentificationScreen extends ConsumerWidget {
  const IdentificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Identitas'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Avatar & Nama
            UserAvatar(
              name: user?.nama ?? 'U',
              size: 100,
              showBorder: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              user?.nama ?? '-',
              style: AppTypography.headlineLgMobile,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Identitas Perpustakaan',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Identitas Card
            _buildIdentityCard(user),
            const SizedBox(height: AppSpacing.lg),

            // Role Badge
            _buildRoleBadge(user?.role),
            const SizedBox(height: AppSpacing.xl),

            // Info tambahan
            _buildInfoCard(user),
            const SizedBox(height: AppSpacing.xl),

            // Tombol edit profil
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(RouteNames.editProfile),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Profil'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.rMd,
                  ),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard(UserEntity? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            'Nomor Identitas',
            style: AppTypography.headlineMd,
          ),
          const SizedBox(height: AppSpacing.xl),

          // NISN atau NIP
          if (user?.nisn != null) ...[
            _buildIdentityRow(
              icon: Icons.badge_outlined,
              label: 'NISN',
              value: user!.nisn!,
              iconColor: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (user?.nip != null) ...[
            _buildIdentityRow(
              icon: Icons.badge_outlined,
              label: 'NIP',
              value: user!.nip!,
              iconColor: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Kelas & Jurusan (untuk siswa)
          if (user?.kelas != null && user?.kelas != 0) ...[
            _buildIdentityRow(
              icon: Icons.class_outlined,
              label: 'Kelas',
              value: user!.kelas!.toString(),
              iconColor: AppColors.info,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (user?.jurusan != null && user!.jurusan!.isNotEmpty) ...[
            _buildIdentityRow(
              icon: Icons.school_outlined,
              label: 'Jurusan',
              value: user.jurusan!,
              iconColor: AppColors.tertiary,
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Mapel (untuk guru)
          if (user?.mapel != null && user!.mapel!.isNotEmpty) ...[
            _buildIdentityRow(
              icon: Icons.menu_book_outlined,
              label: 'Mata Pelajaran',
              value: user.mapel!,
              iconColor: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIdentityRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: AppRadius.rMd,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String? role) {
    String roleLabel;
    AppBadgeVariant variant;

    switch (role) {
      case 'siswa':
        roleLabel = 'Siswa';
        variant = AppBadgeVariant.info;
        break;
      case 'guru':
        roleLabel = 'Guru';
        variant = AppBadgeVariant.success;
        break;
      case 'petugas':
        roleLabel = 'Petugas';
        variant = AppBadgeVariant.warning;
        break;
      default:
        roleLabel = 'User';
        variant = AppBadgeVariant.neutral;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: AppRadius.rPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(role),
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            roleLabel,
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(UserEntity? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Lengkap',
            style: AppTypography.headlineMd,
          ),
          const SizedBox(height: AppSpacing.md),
          if (user?.email != null && user!.email.isNotEmpty)
            _buildInfoRow(Icons.email_outlined, 'Email', user.email),
          if (user?.noTelp != null && user!.noTelp!.isNotEmpty)
            _buildInfoRow(Icons.phone_outlined, 'Telepon', user.noTelp!),
          if (user?.alamat != null && user!.alamat!.isNotEmpty)
            _buildInfoRow(Icons.location_on_outlined, 'Alamat', user.alamat!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.outline),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String? role) {
    switch (role) {
      case 'siswa':
        return Icons.school;
      case 'guru':
        return Icons.person;
      case 'petugas':
        return Icons.admin_panel_settings;
      default:
        return Icons.person_outline;
    }
  }
}

// Simple AppBadgeVariant enum for IdentificationScreen
enum AppBadgeVariant {
  info,
  success,
  warning,
  neutral,
}