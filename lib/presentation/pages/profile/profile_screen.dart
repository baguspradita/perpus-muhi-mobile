import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/peminjaman_provider.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/profile_stats_section.dart';
import '../../widgets/profile_menu_list.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _totalDenda = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDenda());
  }

  Future<void> _loadDenda() async {
    final notifier = ref.read(peminjamanProvider.notifier);
    final activeCount = ref.read(peminjamanProvider).peminjaman.length;

    // Hanya hitung denda dari pinjaman AKTIF (belum dikembalikan)
    await notifier.loadPeminjaman(isRiwayat: false);
    final active = ref.read(peminjamanProvider).peminjaman;
    int dendaAktif = 0;
    print('=== PINJAMAN AKTIF COUNT: ${active.length} ===');
    for (final p in active) {
      final d = p.hitungDenda();
      if (d > 0) {
        dendaAktif += d;
        print('ID:${p.id} | Status:${p.status} | TglKembali:${p.tglKembali} | Denda:$d');
      }
    }
    print('=== TOTAL DENDA AKTIF: $dendaAktif ===');

    if (mounted) {
      setState(() {
        _totalDenda = dendaAktif;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final peminjamanState = ref.watch(peminjamanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: AppSpacing.lg),
            ProfileStatsSection(
              totalPinjam: peminjamanState.peminjaman.length,
              dendaAktif: _totalDenda,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildMenuList(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          UserAvatar(
            name: user?.nama ?? 'U',
            size: 100,
            showBorder: true,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            user?.nama ?? '-',
            style: AppTypography.headlineMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppBadge(
                text: _roleLabel(user?.role),
                variant: AppBadgeVariant.info,
              ),
              if (user?.nisn != null) ...[
                const SizedBox(width: AppSpacing.sm),
                AppBadge(
                  text: 'NISN: ${user?.nisn}',
                ),
              ],
              if (user?.nip != null) ...[
                const SizedBox(width: AppSpacing.sm),
                AppBadge(
                  text: 'NIP: ${user?.nip}',
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Membaca adalah jendela dunia. Mari jelajahi koleksi Perpustakaan Muhi.',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.outline,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, WidgetRef ref) {
    return ProfileMenuList(
      items: [
        ProfileMenuItem(
          icon: Icons.person_outlined,
          title: 'Edit Profil',
          onTap: () => context.go(RouteNames.editProfile),
        ),
        ProfileMenuItem(
          icon: Icons.lock_outlined,
          title: 'Ubah Password',
          onTap: () => context.go(RouteNames.changePassword),
        ),
        ProfileMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notifikasi',
          onTap: () => context.go(RouteNames.notifications),
        ),
        ProfileMenuItem(
          icon: Icons.help_outline,
          title: 'Bantuan',
          onTap: () => _showHelpBottomSheet(context),
        ),
        ProfileMenuItem(
          icon: Icons.logout,
          title: 'Keluar',
          onTap: () => _confirmLogout(context, ref),
          isDestructive: true,
          showDivider: false,
        ),
      ],
    );
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: AppRadius.rPill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Bantuan & FAQ',
              style: AppTypography.headlineMd,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFAQItem(
              'Bagaimana cara meminjam buku?',
              'Buka menu Katalog, pilih buku yang diinginkan, lalu tekan tombol Pinjam.',
            ),
            _buildFAQItem(
              'Bagaimana cara mengembalikan buku?',
              'Buka menu Pinjaman, pilih buku yang ingin dikembalikan, lalu tekan tombol Kembalikan.',
            ),
            _buildFAQItem(
              'Apakah ada denda keterlambatan?',
            'Ya, denda akan dikenakan jika melewati batas waktu pengembalian. Hubungi petugas untuk informasi lebih lanjut.',
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            answer,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'siswa':
        return 'Siswa';
      case 'guru':
        return 'Guru';
      case 'petugas':
        return 'Petugas';
      default:
        return role ?? '-';
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
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