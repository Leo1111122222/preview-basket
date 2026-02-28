import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/get_language_usecase.dart';
import '../../domain/usecases/save_language_usecase.dart';

// Events
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class LoadLanguageEvent extends LanguageEvent {}

class ChangeLanguageEvent extends LanguageEvent {
  final Locale locale;

  const ChangeLanguageEvent(this.locale);

  @override
  List<Object> get props => [locale];
}

// States
abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final Locale locale;

  const LanguageLoaded(this.locale);

  @override
  List<Object> get props => [locale];
}

class LanguageError extends LanguageState {
  final String message;

  const LanguageError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final GetLanguageUseCase getLanguageUseCase;
  final SaveLanguageUseCase saveLanguageUseCase;

  LanguageBloc({
    required this.getLanguageUseCase,
    required this.saveLanguageUseCase,
  }) : super(LanguageInitial()) {
    on<LoadLanguageEvent>(_onLoadLanguage);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }

  Future<void> _onLoadLanguage(
    LoadLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());

    final result = await getLanguageUseCase();

    result.fold(
      (failure) => emit(LanguageError(failure.message)),
      (locale) => emit(LanguageLoaded(locale)),
    );
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());

    final result = await saveLanguageUseCase(event.locale);

    result.fold(
      (failure) => emit(LanguageError(failure.message)),
      (_) => emit(LanguageLoaded(event.locale)),
    );
  }
}
