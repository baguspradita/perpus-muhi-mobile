abstract class Failure {
  final String message;
  final int? statusCode;

  Failure(this.message, {this.statusCode});

  @override
  String toString() => 'Failure: $message';
}

class ServerFailure extends Failure {
  ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message, {super.statusCode});
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure(super.message, {super.statusCode});
}

class ValidationFailure extends Failure {
  final Map<String, dynamic> errors;

  ValidationFailure(super.message, {required this.errors, super.statusCode});
}

class NotFoundFailure extends Failure {
  NotFoundFailure(super.message, {super.statusCode});
}

class CacheFailure extends Failure {
  CacheFailure(super.message, {super.statusCode});
}