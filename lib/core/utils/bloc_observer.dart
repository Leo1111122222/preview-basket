import 'package:flutter_bloc/flutter_bloc.dart';
import 'logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    AppLogger.info('BLoC Created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.debug('BLoC Event: ${bloc.runtimeType} - $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    AppLogger.debug('BLoC Change: ${bloc.runtimeType} - $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    AppLogger.debug('BLoC Transition: ${bloc.runtimeType} - $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppLogger.error('BLoC Error: ${bloc.runtimeType}', error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    AppLogger.info('BLoC Closed: ${bloc.runtimeType}');
  }
}
