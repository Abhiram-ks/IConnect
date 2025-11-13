import 'package:equatable/equatable.dart';

/// Base Failure class
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server Failure
class ServerFailure extends Failure {
  const ServerFailure({
    String? message,
    super.statusCode,
  }) : super(
          message: message ?? 'Server error occurred. Please try again later.',
        );
}

/// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    String? message,
  }) : super(
          message: message ?? 'No internet connection. Please check your network.',
        );
}

/// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure({
    String? message,
  }) : super(
          message: message ?? 'Failed to load cached data.',
        );
}

/// Auth Failure
class AuthFailure extends Failure {
  const AuthFailure({
    String? message,
  }) : super(
          message: message ?? 'Authentication failed.',
          statusCode: 401,
        );
}

/// Not Found Failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String? message,
  }) : super(
          message: message ?? 'Requested resource not found.',
          statusCode: 404,
        );
}

/// GraphQL Failure
class GraphQLFailure extends Failure {
  final String? errorCode;

  const GraphQLFailure({
    required super.message,
    this.errorCode,
    super.statusCode,
  });

  @override
  List<Object?> get props => [message, errorCode, statusCode];
}

