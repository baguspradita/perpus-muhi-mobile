import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bantuan & FAQ'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SizedBox(height: AppSpacing.sm),
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: AppRadius.rLg,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Ada yang bisa kami bantu?',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Peminjaman Section
          _buildSectionTitle('PEMINJAMAN BUKU'),
          const SizedBox(height: AppSpacing.sm),
          _buildExpandableTile(
            'Bagaimana cara meminjam buku?',
            'Buka menu Katalog, cari buku yang diinginkan, lalu tekan tombol "Pinjam" pada detail buku. Pastikan buku masih tersedia sebelum meminjam.',
          ),
          _buildExpandableTile(
            'Berapa batas maksimal peminjaman?',
            'Setiap siswa dapat meminjam maksimal 3 buku dalam waktu bersamaan dengan masa pinjaman 7 hari.',
          ),
          _buildExpandableTile(
            'Bagaimana cara mengembalikan buku?',
            'Buka menu Pinjaman, pilih buku yang ingin dikembalikan, lalu tekan tombol "Kembalikan". Serahkan buku ke petugas perpustakaan.',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Denda Section
          _buildSectionTitle('DENDA'),
          const SizedBox(height: AppSpacing.sm),
          _buildExpandableTile(
            'Apakah ada denda keterlambatan?',
            'Ya, denda sebesar Rp 1.000/hari akan dikenakan jika melewati batas waktu pengembalian. Hubungi petugas untuk informasi pembayaran denda.',
          ),
          _buildExpandableTile(
            'Bagaimana cara membayar denda?',
            'Hubungi petugas perpustakaan untuk melakukan pembayaran denda. Pembayaran dapat dilakukan secara tunai di perpustakaan.',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Akun Section
          _buildSectionTitle('AKUN & PROFIL'),
          const SizedBox(height: AppSpacing.sm),
          _buildExpandableTile(
            'Bagaimana cara mengubah password?',
            'Buka menu Profil, pilih "Ubah Password", masukkan password lama dan password baru, lalu tekan simpan.',
          ),
          _buildExpandableTile(
            'Data saya salah, bagaimana cara mengubahnya?',
            'Buka menu Profil, pilih "Edit Profil", ubah data yang diperlukan, lalu tekan "Simpan Perubahan".',
          ),
          _buildExpandableTile(
            'Lupa password, bagaimana cara reset?',
            'Hubungi petugas perpustakaan atau admin sekolah untuk melakukan reset password akun Anda.',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Hubungi Section
          _buildSectionTitle('HUBUNGI KAMI'),
          const SizedBox(height: AppSpacing.sm),
          Container(
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
                _buildContactItem(
                  Icons.email_outlined,
                  'Email',
                  'perpustakaan@smkmuhi.sch.id',
                ),
                const SizedBox(height: AppSpacing.md),
                _buildContactItem(
                  Icons.phone_outlined,
                  'Telepon',
                  '(021) 1234-5678',
                ),
                const SizedBox(height: AppSpacing.md),
                _buildContactItem(
                  Icons.location_on_outlined,
                  'Alamat',
                  'Jl. Pendidikan No. 1, Jakarta Selatan',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelMd.copyWith(
        color: AppColors.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildExpandableTile(String question, String answer) {
    return _ExpandableTile(question: question, answer: answer);
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: AppRadius.rMd,
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
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
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpandableTile extends StatefulWidget {
  final String question;
  final String answer;

  const _ExpandableTile({required this.question, required this.answer});

  @override
  State<_ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<_ExpandableTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.rMd,
        border: Border.all(
          color: _isExpanded ? AppColors.primary : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: AppRadius.rMd,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.outline,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Text(
                widget.answer,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}