class ApiConstants {
  // Base URL - Change this to your API URL
  static const String baseUrl = 'https://api.example.com/v1';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  static const String users = '/users';
  static const String profile = '/profile';
  
  // Add your endpoints here...
}
