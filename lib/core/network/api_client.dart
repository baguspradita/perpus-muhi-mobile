import 'package:dio/dio.dart';
import 'api_response.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Dio get dio => _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _parseResponse<T>(response.data, fromJsonT);
    } on DioException {
      rethrow;
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _parseResponse<T>(response.data, fromJsonT);
    } on DioException {
      rethrow;
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _parseResponse<T>(response.data, fromJsonT);
    } on DioException {
      rethrow;
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _parseResponse<T>(response.data, fromJsonT);
    } on DioException {
      rethrow;
    }
  }

  ApiResponse<T> _parseResponse<T>(
    Map<String, dynamic>? json,
    T Function(dynamic)? fromJsonT,
  ) {
    if (json == null) {
      return ApiResponse(
        success: false,
        message: 'Response kosong dari server',
      );
    }
    return ApiResponse.fromJson(json, fromJsonT);
  }
}