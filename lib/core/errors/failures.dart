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

  ValidationFailure(String message, {required this.errors, super.statusCode})
      : super(_combineErrors(message, errors));

  static String _combineErrors(String message, Map<String, dynamic> errors) {
    if (errors.isEmpty) return message;
    final details = errors.entries
        .map((e) => '${e.key}: ${(e.value as List).join(', ')}')
        .join('\n');
    return details;
  }
}

class NotFoundFailure extends Failure {
  NotFoundFailure(super.message, {super.statusCode});
}

class CacheFailure extends Failure {
  CacheFailure(super.message, {super.statusCode});
}