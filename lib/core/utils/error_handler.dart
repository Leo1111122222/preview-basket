import 'package:flutter/material.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';
import 'logger.dart';

class ErrorHandler {
  /// Handle and log errors globally
  static void handleError(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('Global Error Handler', error, stackTrace);

    // You can add crash reporting here (Firebase Crashlytics, Sentry, etc.)
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  /// Convert Exception to Failure
  static Failure exceptionToFailure(dynamic exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is NoInternetException) {
      return NetworkFailure(exception.message);
    } else if (exception is TimeoutException) {
      return TimeoutFailure(exception.message);
    } else if (exception is BadRequestException) {
      return BadRequestFailure(exception.message);
    } else if (exception is UnauthorizedException) {
      return UnauthorizedFailure(exception.message);
    } else if (exception is ForbiddenException) {
      return ForbiddenFailure(exception.message);
    } else if (exception is NotFoundException) {
      return NotFoundFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message, exception.errors);
    } else if (exception is FirebaseException) {
      return FirebaseFailure(exception.message);
    } else {
      return UnknownFailure(exception.toString());
    }
  }

  /// Get user-friendly error message
  static String getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً';
    } else if (failure is NetworkFailure) {
      return 'لا يوجد اتصال بالإنترنت';
    } else if (failure is TimeoutFailure) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
    } else if (failure is UnauthorizedFailure) {
      return 'غير مصرح لك بالوصول. يرجى تسجيل الدخول';
    } else if (failure is NotFoundFailure) {
      return 'البيانات المطلوبة غير موجودة';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, Failure failure) {
    final message = getErrorMessage(failure);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'حسناً',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
