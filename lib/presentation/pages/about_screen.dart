import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_effects.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            // Brand illustration + App Name
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppGradients.buttonPrimary,
                  borderRadius: AppRadius.rXl,
                  boxShadow: AppGradients.elevation3,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppGradients.heroCenterRadial(
                              primaryColor: Colors.white.withValues(alpha: 0.03),
                              accentColor: AppColors.accent.withValues(alpha: 0.04),
                              radius: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.auto_stories,
                      size: 60,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Perpustakaan Muhi',
              style: AppTypography.headlineLg,
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentContainer,
                borderRadius: AppRadius.badge,
              ),
              child: Text(
                'Versi 1.0.0',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Deskripsi
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tentang',
                    style: AppTypography.headlineMd,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Perpustakaan Muhi adalah aplikasi mobile untuk '
                    'sistem manajemen perpustakaan di SMK Muhi. '
                    'Aplikasi ini memudahkan siswa dan guru dalam '
                    'meminjam, mengembalikan, dan mengelola buku '
                    'secara digital.',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Fitur
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitur Utama',
                    style: AppTypography.headlineMd,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildFeatureItem(
                    Icons.search_rounded,
                    'Katalog Buku',
                    'Cari dan jelajahi koleksi buku perpustakaan',
                  ),
                  _buildFeatureItem(
                    Icons.menu_book,
                    'Peminjaman',
                    'Pinjam buku secara online dan kelola riwayat',
                  ),
                  _buildFeatureItem(
                    Icons.history_outlined,
                    'Riwayat',
                    'Lihat riwayat peminjaman dan pengembalian',
                  ),
                  _buildFeatureItem(
                    Icons.person,
                    'Profil',
                    'Kelola data profil dan identitas Anda',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Developer
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengembang',
                    style: AppTypography.headlineMd,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildInfoRow('Dikembangkan oleh', 'Tim IT SMK Muhi'),
                  _buildInfoRow('Platform', 'Flutter (Cross-platform)'),
                  _buildInfoRow('Backend', 'Laravel REST API'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Legal links
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Legal',
                    style: AppTypography.headlineMd,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildLegalRow(
                    Icons.policy_outlined,
                    'Kebijakan Privasi',
                  ),
                  const Divider(height: AppSpacing.lg, thickness: 1),
                  _buildLegalRow(
                    Icons.description_outlined,
                    'Syarat & Ketentuan',
                  ),
                  const Divider(height: AppSpacing.lg, thickness: 1),
                  _buildLegalRow(
                    Icons.contact_support_outlined,
                    'Hubungi Kami',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Copyright
            Text(
              '© 2025 SMK Muhi. Hak Cipta Dilindungi.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalRow(IconData icon, String title) {
    return InkWell(
      onTap: () {
        // Placeholder: legal pages coming soon
      },
      borderRadius: AppRadius.rMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentContainer,
                borderRadius: AppRadius.rMd,
              ),
              child: Icon(icon, color: AppColors.accent, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.outline,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: child,
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: AppRadius.rMd,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.outline,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}