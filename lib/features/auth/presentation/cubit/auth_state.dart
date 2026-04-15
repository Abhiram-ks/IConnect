import 'package:equatable/equatable.dart';
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
  final ProfileEntity? profile;

  const AuthLoginSuccess({this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Signup success state
class AuthSignupSuccess extends AuthState {
  const AuthSignupSuccess();

  @override
  List<Object?> get props => [];
}

/// Email verification pending state
class AuthEmailVerificationPending extends AuthState {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  const AuthEmailVerificationPending({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName];
}

/// OTP verification loading state
class AuthOtpVerificationLoading extends AuthState {}

/// Forgot password email sent state
class AuthForgotPasswordEmailSent extends AuthState {
  final String email;
  const AuthForgotPasswordEmailSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Forgot password loading state
class AuthForgotPasswordLoading extends AuthState {}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
