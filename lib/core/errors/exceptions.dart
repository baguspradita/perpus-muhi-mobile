abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException: $message (status: $statusCode)';
}

class ServerException extends AppException {
  ServerException(super.message, {super.statusCode});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.statusCode});
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, {super.statusCode});
}

class ValidationException extends AppException {
  final Map<String, dynamic> errors;

  ValidationException(super.message, {required this.errors, super.statusCode});
}

class NotFoundException extends AppException {
  NotFoundException(super.message, {super.statusCode});
}

class CacheException extends AppException {
  CacheException(super.message, {super.statusCode});
}