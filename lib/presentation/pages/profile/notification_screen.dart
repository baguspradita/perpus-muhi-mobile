import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/notification_entity.dart';
import '../../../../presentation/providers/notification_provider.dart';
import '../../../../presentation/widgets/loading_shimmer.dart';
import '../../../../presentation/widgets/empty_state.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !ref.read(notificationProvider).isLoadingMore &&
        ref.read(notificationProvider).hasMore) {
      ref.read(notificationProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(notificationProvider.notifier).loadNotifications(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: () => notifier.markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Tandai Semua Dibaca'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: state.isLoading && state.notifications.isEmpty
            ? _buildLoadingState()
            : state.errorMessage != null && state.notifications.isEmpty
                ? _buildErrorState(state.errorMessage!)
                : state.notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(state, notifier),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: const LoadingShimmer(
          height: 80,
          width: double.infinity,
          borderRadius: 12,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Gagal Memuat Notifikasi',
          subtitle: message,
          actionLabel: 'Coba Lagi',
          onAction: () =>
              ref.read(notificationProvider.notifier).loadNotifications(refresh: true),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: EmptyState(
          icon: Icons.notifications_outlined,
          title: 'Belum Ada Notifikasi',
          subtitle: 'Notifikasi akan muncul di sini ketika ada aktivitas baru',
        ),
      ),
    );
  }

  Widget _buildNotificationsList(NotificationState state, NotificationNotifier notifier) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.notifications.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final notification = state.notifications[index];
        return _NotificationItem(
          notification: notification,
          onMarkAsRead: () => notifier.markAsRead(notification.id),
          onTap: notification.actionUrl != null
              ? () => _handleNotificationTap(notification.actionUrl!)
              : null,
        );
      },
    );
  }

  void _handleNotificationTap(String actionUrl) {
    try {
      final segments = actionUrl.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty) {
        context.push(RouteNames.home);
        return;
      }
      final basePath = '/${segments.first}';
      const validRoutes = {
        RouteNames.home,
        RouteNames.katalog,
        RouteNames.peminjaman,
        RouteNames.profile,
        RouteNames.about,
        RouteNames.faq,
      };
      final target = validRoutes.contains(basePath) ? basePath : RouteNames.home;
      context.push(target);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka halaman: $e')),
      );
    }
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback? onTap;

  const _NotificationItem({
    required this.notification,
    required this.onMarkAsRead,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final color = _getColor(notification.type);
    final icon = _getIcon(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.rMd,
        border: Border.all(
          color: isUnread ? color.withValues(alpha: 0.4) : AppColors.outlineVariant,
          width: isUnread ? 1.5 : 1,
        ),
        boxShadow: isUnread
            ? null
            : [
                BoxShadow(
                  color: AppColors.shadowPrimary,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppRadius.rMd,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        notification.createdAt,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notification.message,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: AppSpacing.sm),
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IconButton(
                    onPressed: onMarkAsRead,
                    icon: Icon(Icons.check_circle, color: color, size: 20),
                    tooltip: 'Tandai Sudah Dibaca',
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.warning:
        return Icons.warning_amber;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.info:
      default:
        return Icons.info_outline;
    }
  }

  Color _getColor(NotificationType type) {
    switch (type) {
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.info:
      default:
        return AppColors.primary;
    }
  }
}