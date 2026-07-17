import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

Failure mapExceptionToFailure(AppException exception) {
  if (exception is ServerException) {
    return ServerFailure(exception.message, statusCode: exception.statusCode);
  } else if (exception is NetworkException) {
    return NetworkFailure(exception.message);
  } else if (exception is UnauthorizedException) {
    return UnauthorizedFailure(exception.message, statusCode: exception.statusCode);
  } else if (exception is ValidationException) {
    return ValidationFailure(exception.message, errors: exception.errors, statusCode: exception.statusCode);
  } else if (exception is NotFoundException) {
    return NotFoundFailure(exception.message, statusCode: exception.statusCode);
  } else {
    return ServerFailure('Terjadi kesalahan yang tidak diketahui');
  }
}

AppException mapDioExceptionToAppException(DioException dioException) {
  switch (dioException.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkException('Koneksi timeout. Periksa koneksi internet Anda.');
    case DioExceptionType.connectionError:
      return NetworkException('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    case DioExceptionType.badResponse:
      final statusCode = dioException.response?.statusCode;
      final responseData = dioException.response?.data;
      final message = responseData is Map<String, dynamic>
          ? (responseData['message'] as String? ?? 'Terjadi kesalahan pada server')
          : 'Terjadi kesalahan pada server';

      if (statusCode == 422 && responseData is Map<String, dynamic>) {
        return ValidationException(
          message,
          errors: responseData['errors'] as Map<String, dynamic>? ?? {},
          statusCode: statusCode,
        );
      }
      if (statusCode == 401) {
        return UnauthorizedException(message, statusCode: statusCode);
      }
      if (statusCode == 404) {
        return NotFoundException(message, statusCode: statusCode);
      }
      if (statusCode != null && statusCode >= 500) {
        return ServerException(message, statusCode: statusCode);
      }
      return ServerException(message, statusCode: statusCode);
    case DioExceptionType.cancel:
      return ServerException('Permintaan dibatalkan');
    case DioExceptionType.badCertificate:
      return ServerException('Sertifikat keamanan tidak valid');
    case DioExceptionType.unknown:
      return NetworkException('Terjadi kesalahan jaringan. Periksa koneksi internet Anda.');
    default:
      return ServerException('Terjadi kesalahan yang tidak diketahui');
  }
}