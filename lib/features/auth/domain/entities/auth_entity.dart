import 'package:equatable/equatable.dart';

/// Auth Entity - Domain layer representation of authentication data
class AuthEntity extends Equatable {
  final String accessToken;
  final String? expiresAt;
  final String? userId;
  final String? email;
  final String? firstName;
  final String? lastName;

  const AuthEntity({
    required this.accessToken,
    this.expiresAt,
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [
        accessToken,
        expiresAt,
        userId,
        email,
        firstName,
        lastName,
      ];
}


