import 'package:dartz/dartz.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/features/auth/domain/entities/auth_entity.dart';

/// Abstract Auth Repository Interface
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  });

  /// Signup with email and password
  Future<Either<Failure, AuthEntity>> signup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  });
}


