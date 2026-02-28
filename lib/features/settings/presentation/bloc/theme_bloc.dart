import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/get_theme_usecase.dart';
import '../../domain/usecases/save_theme_usecase.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class LoadThemeEvent extends ThemeEvent {}

class ChangeThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeThemeEvent(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

// States
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoading extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeMode themeMode;

  const ThemeLoaded(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class ThemeError extends ThemeState {
  final String message;

  const ThemeError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final GetThemeUseCase getThemeUseCase;
  final SaveThemeUseCase saveThemeUseCase;

  ThemeBloc({
    required this.getThemeUseCase,
    required this.saveThemeUseCase,
  }) : super(ThemeInitial()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(ThemeLoading());

    final result = await getThemeUseCase();

    result.fold(
      (failure) => emit(ThemeError(failure.message)),
      (themeMode) => emit(ThemeLoaded(themeMode)),
    );
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(ThemeLoading());

    final result = await saveThemeUseCase(event.themeMode);

    result.fold(
      (failure) => emit(ThemeError(failure.message)),
      (_) => emit(ThemeLoaded(event.themeMode)),
    );
  }
}
