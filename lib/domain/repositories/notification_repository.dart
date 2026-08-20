import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationResponse>> getNotifications({
    int page = 1,
    int perPage = 20,
    bool unreadOnly = false,
  });

  Future<Either<Failure, void>> markAsRead(int id);

  Future<Either<Failure, void>> markAllAsRead();
}