import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/buku_entity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';

class BookDetailScreen extends ConsumerWidget {
  final BukuEntity book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Center(
                    child: Hero(
                      tag: 'book_cover_${book.id}',
                      child: Container(
                        width: 160,
                        height: 220,
                        margin: const EdgeInsets.only(top: 40),
                        decoration: BoxDecoration(
                          color: _getCoverColor(book.id),
                          borderRadius: AppRadius.rMd,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.menu_book,
                            size: 60,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text('Detail Buku', style: TextStyle(color: Colors.white)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.judul,
                    style: AppTypography.heading2.copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    book.penulis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Detail', style: AppTypography.heading3),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow('Nomor Salinan', book.nomorSalinan ?? '-'),
                  _buildDetailRow('Penerbit', book.penerbit),
                  _buildDetailRow('Tahun Terbit', book.tahunTerbit.toString()),
                  _buildDetailRow('Kategori', book.namaKategori ?? '-'),
                  _buildDetailRow('Subjek', book.namaSubjek ?? '-'),
                  _buildDetailRow('Lokasi', book.namaLokasi ?? '-'),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        Icons.library_books,
                        book.totalSalinan?.toString() ?? book.jumlah.toString(),
                        'Total Salinan',
                      ),
                      _buildStatItem(
                        Icons.check_circle,
                        book.stokTersedia?.toString() ?? book.jumlah.toString(),
                        'Tersedia',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: AppButton(
            label: 'Pinjam',
            type: AppButtonType.primary,
            isExpanded: true,
            icon: Icons.book_online,
            onPressed: book.status == 'aktif'
                ? () => _showBorrowDialog(context, ref)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.heading3.copyWith(fontSize: 16),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          Text(value, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  void _showBorrowDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        title: const Text('Konfirmasi Peminjaman'),
        content: Text('Pinjam "${book.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Peminjaman "${book.judul}" berhasil!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Pinjam'),
          ),
        ],
      ),
    );
  }

  Color _getCoverColor(int id) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00B894),
      const Color(0xFFE17055),
      const Color(0xFF74B9FF),
      const Color(0xFFA29BFE),
      const Color(0xFFFD79A8),
    ];
    return colors[id % colors.length];
  }
}