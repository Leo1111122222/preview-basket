import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class SaveThemeUseCase {
  final SettingsRepository repository;

  SaveThemeUseCase(this.repository);

  Future<Either<Failure, void>> call(ThemeMode themeMode) async {
    return await repository.saveThemeMode(themeMode);
  }
}
