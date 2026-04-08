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

/// Shopify customerCreate returned "email already taken" — the user has an
/// existing Shopify web account. Firebase registration succeeded, so they
/// should now sign in with the password they just set.
class AuthShopifyAccountAlreadyExists extends AuthState {
  final String email;
  const AuthShopifyAccountAlreadyExists(this.email);

  @override
  List<Object?> get props => [email];
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
