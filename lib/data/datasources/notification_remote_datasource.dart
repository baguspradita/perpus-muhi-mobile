import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/notification_entity.dart';

class NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSource(this._apiClient);

  Future<NotificationResponse> getNotifications({
    int page = 1,
    int perPage = 20,
    bool unreadOnly = false,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (unreadOnly) queryParams['unread_only'] = true;

    try {
      final response = await _apiClient.dio.get(
        ApiConstants.notifications,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return NotificationResponse.fromJson(data);
      }

      return const NotificationResponse(data: [], meta: NotificationMeta(currentPage: 1, lastPage: 1, perPage: 20, total: 0));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Endpoint not found - return mock data for development
        return _getMockNotifications(page: page, perPage: perPage);
      }
      throw ServerException(_getErrorMessage(e));
    } catch (_) {
      // Any other error (network, etc.) - return mock data for development
      return _getMockNotifications(page: page, perPage: perPage);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiClient.dio.post('${ApiConstants.notifications}/$id/read');
    } on DioException catch (e) {
      // Fire-and-forget: ignore 404 (endpoint not ready), log others
      if (e.response?.statusCode != 404) {
        throw ServerException(_getErrorMessage(e));
      }
    } catch (_) {
      // Ignore any other errors for local-first UX
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.post('${ApiConstants.notifications}/read-all');
    } on DioException catch (e) {
      // Fire-and-forget: ignore 404 (endpoint not ready), log others
      if (e.response?.statusCode != 404) {
        throw ServerException(_getErrorMessage(e));
      }
    } catch (_) {
      // Ignore any other errors for local-first UX
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return e.response?.data['message'] as String? ?? 'Terjadi kesalahan server';
    }
    return e.message ?? 'Terjadi kesalahan jaringan';
  }

  // Mock data untuk development (akan dihapus saat backend ready)
  NotificationResponse _getMockNotifications({int page = 1, int perPage = 20}) {
    final mockNotifications = [
      NotificationEntity(
        id: 1,
        title: 'Buku berhasil dikembalikan',
        message: 'Buku "Fisika Kuantum" berhasil dikembalikan ke perpustakaan.',
        type: NotificationType.success,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        actionUrl: '/peminjaman/123',
      ),
      NotificationEntity(
        id: 2,
        title: 'Pengingat jatuh tempo',
        message: 'Buku "Algoritma Pemrograman" akan jatuh tempo besok.',
        type: NotificationType.warning,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        actionUrl: '/peminjaman/456',
      ),
      NotificationEntity(
        id: 3,
        title: 'Status peminjaman diperbarui',
        message: 'Status peminjaman Anda telah diperbarui.',
        type: NotificationType.info,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        actionUrl: '/peminjaman/789',
      ),
      NotificationEntity(
        id: 4,
        title: 'Buku baru tersedia',
        message: 'Buku baru "Machine Learning Praktis" tersedia.',
        type: NotificationType.info,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        actionUrl: '/katalog/101',
      ),
      NotificationEntity(
        id: 5,
        title: 'Ulasan buku baru',
        message: 'Terima kasih telah memberikan ulasan.',
        type: NotificationType.success,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationEntity(
        id: 6,
        title: 'Sistem peminjaman updated',
        message: 'Maintenance sistem akan berlangsung malam ini.',
        type: NotificationType.warning,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NotificationEntity(
        id: 7,
        title: 'Koleksi buku terbaru',
        message: 'Koleksi buku terbaru tersedia untuk anggota.',
        type: NotificationType.info,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      NotificationEntity(
        id: 8,
        title: 'Selamat datang!',
        message: 'Selamat bergabung di perpustakaan.',
        type: NotificationType.success,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    final start = (page - 1) * perPage;
    final end = start + perPage;
    final paginatedData = mockNotifications.skip(start).take(perPage).toList();

    return NotificationResponse(
      data: paginatedData,
      meta: NotificationMeta(
        currentPage: page,
        lastPage: (mockNotifications.length / perPage).ceil(),
        perPage: perPage,
        total: mockNotifications.length,
      ),
    );
  }
}