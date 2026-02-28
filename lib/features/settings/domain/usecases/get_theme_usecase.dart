import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class GetThemeUseCase {
  final SettingsRepository repository;

  GetThemeUseCase(this.repository);

  Future<Either<Failure, ThemeMode>> call() async {
    return await repository.getThemeMode();
  }
}
