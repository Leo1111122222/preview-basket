import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),
      
      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RegisterPage(),
        ),
      ),
      
      // Home
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomePage(),
        ),
      ),
      
      // Add more routes here...
    ],
    
    // Error Page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
