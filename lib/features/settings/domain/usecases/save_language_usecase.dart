import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class SaveLanguageUseCase {
  final SettingsRepository repository;

  SaveLanguageUseCase(this.repository);

  Future<Either<Failure, void>> call(Locale locale) async {
    return await repository.saveLanguage(locale);
  }
}
