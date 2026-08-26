import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<Either<Failure, NotificationResponse>> call({
    int page = 1,
    int perPage = 20,
    bool unreadOnly = false,
  }) {
    return _repository.getNotifications(
      page: page,
      perPage: perPage,
      unreadOnly: unreadOnly,
    );
  }
}

class MarkNotificationAsReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationAsReadUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.markAsRead(id);
  }
}

class MarkAllNotificationsAsReadUseCase {
  final NotificationRepository _repository;

  MarkAllNotificationsAsReadUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.markAllAsRead();
  }
}

class GetUnreadCountUseCase {
  final NotificationRepository _repository;

  GetUnreadCountUseCase(this._repository);

  Future<Either<Failure, int>> call() {
    return _repository.getUnreadCount();
  }
}