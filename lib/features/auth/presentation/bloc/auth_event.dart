part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignUpEvent({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class SignOutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class AuthStateChangedEvent extends AuthEvent {
  final User? user;

  const AuthStateChangedEvent(this.user);

  @override
  List<Object?> get props => [user];
}
