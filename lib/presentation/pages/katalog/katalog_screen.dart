import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/empty_state.dart';

class KatalogScreen extends ConsumerWidget {
  const KatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Katalog Buku'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Katalog Buku',
              style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Belum Ada Data Buku',
              subtitle: 'Data buku akan muncul di sini setelah diambil dari server.',
              actionLabel: 'Muat Ulang',
              onAction: () {},
            ),
          ],
        ),
      ),
    );
  }
}