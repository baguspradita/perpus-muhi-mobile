import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/notification_entity.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../../../domain/usecases/notification_usecases.dart';

class NotificationState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<NotificationEntity> notifications;
  final String? errorMessage;
  final int currentPage;
  final int lastPage;
  final bool hasMore;
  final int unreadBadge;

  const NotificationState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.notifications = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasMore = true,
    this.unreadBadge = 0,
  });

  NotificationState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<NotificationEntity>? notifications,
    String? errorMessage,
    int? currentPage,
    int? lastPage,
    bool? hasMore,
    int? unreadBadge,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasMore: hasMore ?? this.hasMore,
      unreadBadge: unreadBadge ?? this.unreadBadge,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase _markAllAsReadUseCase;
  final GetUnreadCountUseCase _getUnreadCountUseCase;

  NotificationNotifier({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationAsReadUseCase markAsReadUseCase,
    required MarkAllNotificationsAsReadUseCase markAllAsReadUseCase,
    required GetUnreadCountUseCase getUnreadCountUseCase,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _markAsReadUseCase = markAsReadUseCase,
        _markAllAsReadUseCase = markAllAsReadUseCase,
        _getUnreadCountUseCase = getUnreadCountUseCase,
        super(const NotificationState());

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, errorMessage: null, currentPage: 1);
    } else if (state.isLoading || state.isLoadingMore) {
      return;
    }

    try {
      final page = refresh ? 1 : state.currentPage;
      final result = await _getNotificationsUseCase(page: page);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          );
        },
        (response) {
          final newNotifications = refresh
              ? response.data
              : [...state.notifications, ...response.data];

          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            notifications: newNotifications,
            currentPage: response.meta.currentPage,
            lastPage: response.meta.lastPage,
            hasMore: response.meta.currentPage < response.meta.lastPage,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }

    // Also load unread badge count
    await loadUnreadCount();
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    final result = await _getNotificationsUseCase(page: nextPage);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
      (response) {
        state = state.copyWith(
          isLoadingMore: false,
          notifications: [...state.notifications, ...response.data],
          currentPage: response.meta.currentPage,
          lastPage: response.meta.lastPage,
          hasMore: response.meta.currentPage < response.meta.lastPage,
        );
      },
    );
  }

  Future<void> markAsRead(String id) async {
    final index = state.notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final notification = state.notifications[index];
    if (notification.isRead) return;

    // Optimistic update
    final updatedNotifications = List<NotificationEntity>.from(state.notifications);
    updatedNotifications[index] = notification.copyWith(isRead: true);
    state = state.copyWith(notifications: updatedNotifications);

    final result = await _markAsReadUseCase(id);
    result.fold(
      (failure) {
        // Rollback on failure
        updatedNotifications[index] = notification;
        state = state.copyWith(notifications: updatedNotifications);
      },
      (_) {},
    );

    await loadUnreadCount();
  }

  Future<void> markAllAsRead() async {
    final unreadNotifications = state.notifications.where((n) => !n.isRead).toList();
    if (unreadNotifications.isEmpty) return;

    // Optimistic update
    final updatedNotifications = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updatedNotifications);

    final result = await _markAllAsReadUseCase();
    result.fold(
      (failure) {
        // Rollback on failure - reload to get correct state
        loadNotifications(refresh: true);
      },
      (_) {},
    );

    await loadUnreadCount();
  }

  Future<void> loadUnreadCount() async {
    final result = await _getUnreadCountUseCase();
    result.fold(
      (failure) {
        // Keep current badge on failure
      },
      (count) {
        state = state.copyWith(unreadBadge: count);
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(
    getNotificationsUseCase: ref.read(getNotificationsUseCaseProvider),
    markAsReadUseCase: ref.read(markNotificationAsReadUseCaseProvider),
    markAllAsReadUseCase: ref.read(markAllNotificationsAsReadUseCaseProvider),
    getUnreadCountUseCase: ref.read(getUnreadCountUseCaseProvider),
  );
});

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  return GetNotificationsUseCase(ref.read(notificationRepositoryProvider));
});

final markNotificationAsReadUseCaseProvider = Provider<MarkNotificationAsReadUseCase>((ref) {
  return MarkNotificationAsReadUseCase(ref.read(notificationRepositoryProvider));
});

final markAllNotificationsAsReadUseCaseProvider = Provider<MarkAllNotificationsAsReadUseCase>((ref) {
  return MarkAllNotificationsAsReadUseCase(ref.read(notificationRepositoryProvider));
});

final getUnreadCountUseCaseProvider = Provider<GetUnreadCountUseCase>((ref) {
  return GetUnreadCountUseCase(ref.read(notificationRepositoryProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  // This will be overridden in injection_container.dart
  throw UnimplementedError('notificationRepositoryProvider not initialized');
});