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
import '../../widgets/user_avatar.dart';

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
    final activeCount = ref.read(peminjamanProvider).peminjamanAktif.length;

    await notifier.loadAllData();
    final active = ref.read(peminjamanProvider).peminjamanAktif;
    int dendaAktif = 0;
    print('=== PINJAMAN AKTIF COUNT: ${active.length} ===');
    for (final p in active) {
      final d = p.hitungDenda();
      if (d > 0) {
        dendaAktif += d;
        print(
          'ID:${p.id} | Status:${p.status} | TglKembali:${p.tglKembali} | Denda:$d',
        );
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primary),
            onPressed: () {
              _showSettingsOptions(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: AppSpacing.lg),
            _buildMenuListSection(context),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    final peminjamanState = ref.watch(peminjamanProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          UserAvatar(
            name: user?.nama ?? 'U',
            size: 84,
            showBorder: true,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            user?.nama ?? 'Nama Pengguna',
            style: AppTypography.headlineMd.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.badge_outlined, size: 16, color: AppColors.outline),
              const SizedBox(width: 6),
              Text(
                user?.role == 'siswa'
                    ? 'NIS: ${user?.nisn ?? ''}'
                    : 'NIP: ${user?.nip ?? ''}',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_outlined, size: 16, color: AppColors.outline),
              const SizedBox(width: 6),
              Text(
                user?.role == 'siswa'
                    ? 'Kelas ${user?.kelas ?? '-'}'
                    : user?.mapel ?? _roleLabel(user?.role),
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (user?.jurusan != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category_outlined, size: 16, color: AppColors.outline),
                const SizedBox(width: 6),
                Text(
                  user!.jurusan!,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${peminjamanState.peminjamanAktif.length}',
                        style: AppTypography.headlineLgMobile.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dipinjam',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${peminjamanState.peminjamanRiwayat.length}',
                        style: AppTypography.headlineLgMobile.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Riwayat',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuListSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('AKUN'),
        _buildMenuCard([
          _buildMenuRowItem(
            icon: Icons.person_outlined,
            iconBgColor: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF1D4ED8),
            title: 'Edit Profil',
            onTap: () => context.push(RouteNames.editProfile),
          ),
          _buildMenuRowItem(
            icon: Icons.lock_outline,
            iconBgColor: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF1D4ED8),
            title: 'Ubah Password',
            onTap: () => context.push(RouteNames.changePassword),
          ),
          _buildMenuRowItem(
            icon: Icons.notifications_none_outlined,
            iconBgColor: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF1D4ED8),
            title: 'Pengaturan Notifikasi',
            onTap: () => context.push(RouteNames.notifications),
            showDivider: false,
          ),
        ]),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionHeader('INFORMASI'),
        _buildMenuCard([
          _buildMenuRowItem(
            icon: Icons.info_outline,
            iconBgColor: const Color(0xFFF1F5F9),
            iconColor: const Color(0xFF475569),
            title: 'Tentang Perpustakaan',
            onTap: () => context.push(RouteNames.about),
          ),
          _buildMenuRowItem(
            icon: Icons.help_outline,
            iconBgColor: const Color(0xFFF1F5F9),
            iconColor: const Color(0xFF475569),
            title: 'Bantuan / FAQ',
            onTap: () => _showHelpBottomSheet(context),
            showDivider: false,
          ),
        ]),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: 8),
      child: Text(
        title,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuRowItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  void _showSettingsOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: AppRadius.rPill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Pengaturan Akun',
              style: AppTypography.heading3.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(
                'Keluar dari Akun',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmLogout(context, ref);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: AppRadius.rPill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Bantuan & FAQ', style: AppTypography.headlineMd),
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
            const SizedBox(height: AppSpacing.md),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            answer,
            style: AppTypography.bodySm.copyWith(color: AppColors.outline),
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
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Keluar'),
                ),
              ),
            ],
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
