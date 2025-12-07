import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/auth/domain/entities/auth_entity.dart';
import 'package:iconnect/features/auth/domain/repositories/auth_repository.dart';

/// Signup Use Case
class SignupUsecase implements Usecase<AuthEntity, SignupParams> {
  final AuthRepository repository;

  SignupUsecase(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call(SignupParams params) async {
    return await repository.signup(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }
}

/// Signup Parameters
class SignupParams extends Equatable {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  const SignupParams({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName];
}

