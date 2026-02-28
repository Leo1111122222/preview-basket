import 'package:dio/dio.dart';

import '../../error/exceptions.dart';
import '../../utils/logger.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('Error Interceptor: ${err.type}');

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException(err.message ?? 'Connection timeout');

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = err.response?.data['message'] ?? 'Unknown error';

        switch (statusCode) {
          case 400:
            throw BadRequestException(message);
          case 401:
            throw UnauthorizedException(message);
          case 403:
            throw ForbiddenException(message);
          case 404:
            throw NotFoundException(message);
          case 500:
            throw ServerException(message);
          default:
            throw ServerException(message);
        }

      case DioExceptionType.cancel:
        throw CancelledException('Request cancelled');

      case DioExceptionType.connectionError:
        throw NoInternetException('No internet connection');

      case DioExceptionType.badCertificate:
        throw ServerException('Bad certificate');

      case DioExceptionType.unknown:
        throw UnknownException(err.message ?? 'Unknown error occurred');
    }
  }
}
