import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      child: Icon(Icons.person, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.nama ?? '-',
                            style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
                          ),
                          Text(
                            user?.email ?? '-',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              _roleLabel(user?.role),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Akun',
                      style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    _infoRow('Nama', user?.nama ?? '-'),
                    _infoRow('Email', user?.email ?? '-'),
                    _infoRow('Role', _roleLabel(user?.role)),
                    if (user?.role == 'siswa') ...[
                      _infoRow('NISN', user?.nisn ?? '-'),
                      _infoRow('Kelas', user?.kelas?.toString() ?? '-'),
                      _infoRow('Jurusan', user?.jurusan ?? '-'),
                    ],
                    if (user?.role == 'guru') ...[
                      _infoRow('NIP', user?.nip ?? '-'),
                      _infoRow('Mapel', user?.mapel ?? '-'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Keluar',
                type: AppButtonType.danger,
                icon: Icons.logout,
                isExpanded: true,
                onPressed: () => _confirmLogout(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'siswa': return 'Siswa';
      case 'guru': return 'Guru';
      case 'petugas': return 'Petugas';
      default: return role ?? '-';
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        context.go(RouteNames.login);
      }
    }
  }
}