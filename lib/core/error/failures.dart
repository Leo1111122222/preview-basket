import 'package:equatable/equatable.dart';

/// Base Failure Class
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => message;
}

/// Server Failure
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message, 500);
}

/// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Timeout Failure
class TimeoutFailure extends Failure {
  const TimeoutFailure(String message) : super(message, 408);
}

/// Bad Request Failure
class BadRequestFailure extends Failure {
  const BadRequestFailure(String message) : super(message, 400);
}

/// Unauthorized Failure
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message) : super(message, 401);
}

/// Forbidden Failure
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(String message) : super(message, 403);
}

/// Not Found Failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message, 404);
}

/// Validation Failure
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure(String message, [this.errors]) : super(message, 422);

  @override
  List<Object?> get props => [message, statusCode, errors];
}

/// Unknown Failure
class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}

/// Firebase Failure
class FirebaseFailure extends Failure {
  const FirebaseFailure(String message) : super(message);
}
