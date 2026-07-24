import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

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
            // Logo & App Name
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.rXl,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowPrimary,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.rXl,
                  child: Image.asset(
                    'assets/images/logo-muhi.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Perpustakaan Muhi',
              style: AppTypography.headlineLgMobile,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Versi 1.0.0',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.outline,
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
                    Icons.search,
                    'Katalog Buku',
                    'Cari dan jelajahi koleksi buku perpustakaan',
                  ),
                  _buildFeatureItem(
                    Icons.book,
                    'Peminjaman',
                    'Pinjam buku secara online dan kelola riwayat',
                  ),
                  _buildFeatureItem(
                    Icons.history,
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