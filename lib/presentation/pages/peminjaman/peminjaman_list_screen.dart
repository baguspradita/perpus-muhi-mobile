import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/empty_state.dart';

class PeminjamanScreen extends ConsumerWidget {
  const PeminjamanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Peminjaman'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Peminjaman',
              style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            EmptyState(
              icon: Icons.history_outlined,
              title: 'Belum Ada Data Peminjaman',
              subtitle: 'Daftar peminjaman akan muncul di sini setelah diambil dari server.',
              actionLabel: 'Muat Ulang',
              onAction: () {},
            ),
          ],
        ),
      ),
    );
  }
}