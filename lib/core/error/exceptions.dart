/// Base Exception Class
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Server Exception (5xx errors)
class ServerException extends AppException {
  ServerException(String message) : super(message, 500);
}

/// Cache Exception (Local storage errors)
class CacheException extends AppException {
  CacheException(String message) : super(message);
}

/// Network Exception (No internet)
class NoInternetException extends AppException {
  NoInternetException(String message) : super(message);
}

/// Timeout Exception
class TimeoutException extends AppException {
  TimeoutException(String message) : super(message, 408);
}

/// Bad Request Exception (400)
class BadRequestException extends AppException {
  BadRequestException(String message) : super(message, 400);
}

/// Unauthorized Exception (401)
class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, 401);
}

/// Forbidden Exception (403)
class ForbiddenException extends AppException {
  ForbiddenException(String message) : super(message, 403);
}

/// Not Found Exception (404)
class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, 404);
}

/// Cancelled Exception
class CancelledException extends AppException {
  CancelledException(String message) : super(message);
}

/// Unknown Exception
class UnknownException extends AppException {
  UnknownException(String message) : super(message);
}

/// Validation Exception
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  ValidationException(String message, [this.errors]) : super(message, 422);
}

/// Firebase Exception
class FirebaseException extends AppException {
  FirebaseException(String message) : super(message);
}
