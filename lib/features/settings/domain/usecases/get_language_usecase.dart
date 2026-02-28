import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class GetLanguageUseCase {
  final SettingsRepository repository;

  GetLanguageUseCase(this.repository);

  Future<Either<Failure, Locale>> call() async {
    return await repository.getLanguage();
  }
}
