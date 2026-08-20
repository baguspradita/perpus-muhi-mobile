import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final LocalStorageService _localStorage;

  static const String _readNotificationsKey = 'read_notification_ids';

  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
    required LocalStorageService localStorage,
  })  : _remoteDataSource = remoteDataSource,
        _localStorage = localStorage;

  Future<Set<int>> _getReadNotificationIds() async {
    final jsonString = await _localStorage.read(_readNotificationsKey);
    if (jsonString == null || jsonString.isEmpty) return <int>{};
    try {
      final ids = jsonString
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toSet();
      return ids;
    } catch (_) {
      return <int>{};
    }
  }

  Future<void> _saveReadNotificationIds(Set<int> ids) async {
    final jsonString = ids.map((e) => e.toString()).join(',');
    await _localStorage.write(_readNotificationsKey, jsonString);
  }

  @override
  Future<Either<Failure, NotificationResponse>> getNotifications({
    int page = 1,
    int perPage = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _remoteDataSource.getNotifications(
        page: page,
        perPage: perPage,
        unreadOnly: unreadOnly,
      );

      final readIds = await _getReadNotificationIds();

      final mergedData = response.data.map((notification) {
        if (readIds.contains(notification.id)) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      final filteredData = unreadOnly
          ? mergedData.where((n) => !n.isRead).toList()
          : mergedData;

      return Right(
        NotificationResponse(
          data: filteredData,
          meta: NotificationMeta(
            currentPage: response.meta.currentPage,
            lastPage: response.meta.lastPage,
            perPage: response.meta.perPage,
            total: filteredData.length,
          ),
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int id) async {
    try {
      final readIds = await _getReadNotificationIds();
      readIds.add(id);
      await _saveReadNotificationIds(readIds);

      // Fire-and-forget API call
      _remoteDataSource.markAsRead(id).catchError((_) {});

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      final response = await _remoteDataSource.getNotifications(page: 1, perPage: 100);
      final allIds = response.data.map((n) => n.id).toSet();

      final readIds = await _getReadNotificationIds();
      readIds.addAll(allIds);
      await _saveReadNotificationIds(readIds);

      // Fire-and-forget API call
      _remoteDataSource.markAllAsRead().catchError((_) {});

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}