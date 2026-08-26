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
      throw ServerException(_getErrorMessage(e));
    } catch (e) {
      throw ServerException('Terjadi kesalahan: $e');
    }
  }

  Future<void> markAsRead(String id) async {
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
      await _apiClient.dio.post('${ApiConstants.notifications}/mark-all-read');
    } on DioException catch (e) {
      // Fire-and-forget: ignore 404 (endpoint not ready), log others
      if (e.response?.statusCode != 404) {
        throw ServerException(_getErrorMessage(e));
      }
    } catch (_) {
      // Ignore any other errors for local-first UX
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.notifications}/fetch',
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) {
          return inner['unread'] as int? ?? 0;
        }
      }

      return 0;
    } on DioException catch (e) {
      throw ServerException(_getErrorMessage(e));
    } catch (_) {
      return 0;
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return e.response?.data['message'] as String? ?? 'Terjadi kesalahan server';
    }
    return e.message ?? 'Terjadi kesalahan jaringan';
  }
}