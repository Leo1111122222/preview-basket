import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, ThemeMode>> getThemeMode();
  Future<Either<Failure, void>> saveThemeMode(ThemeMode themeMode);
  Future<Either<Failure, Locale>> getLanguage();
  Future<Either<Failure, void>> saveLanguage(Locale locale);
}
