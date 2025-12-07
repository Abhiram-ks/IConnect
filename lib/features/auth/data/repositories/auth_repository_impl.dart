import 'package:dartz/dartz.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:iconnect/features/auth/domain/entities/auth_entity.dart';
import 'package:iconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:iconnect/services/api_exception.dart';

/// Auth Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(result.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> signup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final result = await remoteDataSource.signup(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      return Right(result.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

