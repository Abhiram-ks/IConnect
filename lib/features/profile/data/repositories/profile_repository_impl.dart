import 'package:dartz/dartz.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:iconnect/features/profile/domain/entities/profile_entity.dart';
import 'package:iconnect/features/profile/domain/repositories/profile_repository.dart';
import 'package:iconnect/services/api_exception.dart';

/// Profile Repository Implementation
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final result = await remoteDataSource.getProfile();
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
