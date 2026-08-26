import 'package:equatable/equatable.dart';

enum NotificationType {
  info,
  warning,
  success,
  error;

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'warning':
        return NotificationType.warning;
      case 'success':
        return NotificationType.success;
      case 'error':
        return NotificationType.error;
      case 'info':
      default:
        return NotificationType.info;
    }
  }

  String get value => name;
}

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String createdAt;
  final String? actionUrl;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.actionUrl,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ??
          json['judul'] as String? ??
          'Notifikasi',
      message: json['message'] as String? ?? json['pesan'] as String? ?? '',
      type: NotificationType.fromString(json['type'] as String? ?? 'info'),
      isRead: json['is_read'] as bool? ?? (json['read_at'] != null),
      createdAt: json['created_at'] as String? ?? '',
      actionUrl: json['action_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.value,
      'is_read': isRead,
      'created_at': createdAt,
      'action_url': actionUrl,
    };
  }

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    String? createdAt,
    String? actionUrl,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  @override
  List<Object?> get props => [id, title, message, type, isRead, createdAt, actionUrl];
}

class NotificationResponse extends Equatable {
  final List<NotificationEntity> data;
  final NotificationMeta meta;

  const NotificationResponse({
    required this.data,
    required this.meta,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return NotificationResponse(
      data: dataList.map((e) => NotificationEntity.fromJson(e as Map<String, dynamic>)).toList(),
      meta: NotificationMeta.fromJson(
        json['pagination'] as Map<String, dynamic>? ??
            json['meta'] as Map<String, dynamic>? ??
            {},
      ),
    );
  }

  @override
  List<Object?> get props => [data, meta];
}

class NotificationMeta extends Equatable {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const NotificationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}