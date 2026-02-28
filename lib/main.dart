import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/bloc_observer.dart';
import 'core/utils/error_handler.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/collections/presentation/pages/collections_page.dart';
import 'features/settings/presentation/bloc/theme_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Configure Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Setup Dependency Injection
  await configureDependencies();

  // Setup BLoC Observer
  Bloc.observer = AppBlocObserver();

  // Setup Error Handler
  FlutterError.onError = (details) {
    ErrorHandler.handleError(details.exception, details.stack);
  };

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ThemeBloc>()..add(LoadThemeEvent()),
        ),
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'سلة المعاينات',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState is ThemeLoaded
                    ? themeState.themeMode
                    : ThemeMode.system,
                home: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthLoading || authState is AuthInitial) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    if (authState is Authenticated) {
                      return const CollectionsPage();
                    }
                    
                    return const LoginPage();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
