import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/loading_shimmer.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: _isLoading ? _buildLoadingState() : _buildNotificationsList(),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: LoadingShimmer(
          height: 80,
          width: double.infinity,
          borderRadius: 12,
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 8,
      itemBuilder: (context, index) {
        final isUnread = index == 0;
        final type = ['info', 'warning', 'success'][index % 3];
        final icon = _getIcon(type);
        final color = _getColor(type);

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.rMd,
            border: Border.all(
              color: isUnread ? AppColors.primary : AppColors.outlineVariant,
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowPrimary,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: AppRadius.rMd,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTitle(index),
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        Text(
                          _getTime(index),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _getMessage(index),
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'info':
        return Icons.info_outline;
      case 'warning':
        return Icons.warning_amber;
      case 'success':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'info':
        return AppColors.primary;
      case 'warning':
        return AppColors.warning;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.outline;
    }
  }

  String _getTitle(int index) {
    final titles = [
      'Buku berhasil dikembalikan',
      'Pengingat jatuh tempo',
      'Status peminjaman diperbarui',
      'Buku baru tersedia',
      'Ulasan buku baru',
      'Sistem peminjaman updated',
      'Diskon tersedia',
      'Selamat datang!',
    ];
    return titles[index % titles.length];
  }

  String _getMessage(int index) {
    final messages = [
      'Buku "Fisika Kuantum" berhasil dikembalikan ke perpustakaan.',
      'Buku "Algoritma Pemrograman" akan jatuh tempo besok.',
      'Status peminjaman Anda telah diperbarui.',
      'Buku baru "Machine Learning Praktis" tersedia.',
      'Terima kasih telah memberikan ulasan.',
      'Maintenance sistem akan berlangsung malam ini.',
      'Koleksi buku terbaru tersedia untuk anggota.',
      'Selamat bergabung di perpustakaan.',
    ];
    return messages[index % messages.length];
  }

  String _getTime(int index) {
    final times = [
      '5 menit lalu',
      '1 jam lalu',
      '2 jam lalu',
      'Kemarin',
      'Kemarin',
      '2 hari lalu',
      '3 hari lalu',
      '4 hari lalu',
    ];
    return times[index % times.length];
  }
}
