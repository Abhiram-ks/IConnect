import 'package:iconnect/features/auth/domain/entities/auth_entity.dart';

/// Auth Model - Data layer representation with JSON serialization
class AuthModel extends AuthEntity {
  const AuthModel({
    required super.accessToken,
    super.expiresAt,
    super.userId,
    super.email,
    super.firstName,
    super.lastName,
  });

  /// Create AuthModel from JSON response
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // Handle customerAccessTokenCreate response
    if (json.containsKey('customerAccessTokenCreate')) {
      final data = json['customerAccessTokenCreate'];
      final tokenData = data['customerAccessToken'];
      if (tokenData != null) {
        return AuthModel(
          accessToken: tokenData['accessToken'] as String,
          expiresAt: tokenData['expiresAt'] as String?,
        );
      }
    }

    // Handle customerCreate response (signup)
    if (json.containsKey('customerCreate')) {
      final data = json['customerCreate'];
      final customer = data['customer'];
      if (customer != null) {
        return AuthModel(
          userId: customer['id'] as String?,
          email: customer['email'] as String?,
          firstName: customer['firstName'] as String?,
          lastName: customer['lastName'] as String?,
          accessToken: '', // Signup doesn't return token, need to login after
        );
      }
    }

    throw Exception('Invalid JSON format for AuthModel');
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'expiresAt': expiresAt,
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  /// Convert to AuthEntity
  AuthEntity toEntity() {
    return AuthEntity(
      accessToken: accessToken,
      expiresAt: expiresAt,
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
  }
}


