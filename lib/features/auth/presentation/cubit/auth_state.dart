import 'package:equatable/equatable.dart';
import 'package:iconnect/features/auth/domain/entities/auth_entity.dart';

/// Auth State
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading state
class AuthLoading extends AuthState {}

/// Login success state
class AuthLoginSuccess extends AuthState {
  final AuthEntity authEntity;

  const AuthLoginSuccess(this.authEntity);

  @override
  List<Object?> get props => [authEntity];
}

/// Signup success state
class AuthSignupSuccess extends AuthState {
  final AuthEntity authEntity;

  const AuthSignupSuccess(this.authEntity);

  @override
  List<Object?> get props => [authEntity];
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

