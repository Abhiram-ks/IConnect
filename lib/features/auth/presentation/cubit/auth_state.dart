import 'package:equatable/equatable.dart';
import 'package:iconnect/features/auth/domain/entities/auth_entity.dart';
import 'package:iconnect/features/profile/domain/entities/profile_entity.dart';

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
  final ProfileEntity? profile;

  const AuthLoginSuccess(this.authEntity, {this.profile});

  @override
  List<Object?> get props => [authEntity, profile];
}

/// Signup success state
class AuthSignupSuccess extends AuthState {
  final AuthEntity authEntity;
  final ProfileEntity? profile;

  const AuthSignupSuccess(this.authEntity, {this.profile});

  @override
  List<Object?> get props => [authEntity, profile];
}

/// Profile loading state
class AuthProfileLoading extends AuthState {
  final AuthEntity authEntity;

  const AuthProfileLoading(this.authEntity);

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
