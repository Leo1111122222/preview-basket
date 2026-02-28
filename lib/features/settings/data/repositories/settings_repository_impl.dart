import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, ThemeMode>> getThemeMode() async {
    try {
      final themeModeString = await localDataSource.getThemeMode();
      final themeMode = _stringToThemeMode(themeModeString);
      return Right(themeMode);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get theme mode'));
    }
  }

  @override
  Future<Either<Failure, void>> saveThemeMode(ThemeMode themeMode) async {
    try {
      final themeModeString = _themeModeToString(themeMode);
      await localDataSource.saveThemeMode(themeModeString);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to save theme mode'));
    }
  }

  @override
  Future<Either<Failure, Locale>> getLanguage() async {
    try {
      final languageCode = await localDataSource.getLanguageCode();
      return Right(Locale(languageCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get language'));
    }
  }

  @override
  Future<Either<Failure, void>> saveLanguage(Locale locale) async {
    try {
      await localDataSource.saveLanguageCode(locale.languageCode);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to save language'));
    }
  }

  // Helper methods
  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
