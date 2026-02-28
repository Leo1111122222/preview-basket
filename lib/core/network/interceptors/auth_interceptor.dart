import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/storage_constants.dart';
import '../../utils/logger.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from storage
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageConstants.authToken);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.info('Auth token added to request');
    }

    // Add other headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.success('Response: ${response.statusCode}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('Request Error: ${err.message}');
    return handler.next(err);
  }
}
