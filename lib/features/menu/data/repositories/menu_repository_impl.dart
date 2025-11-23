import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../services/api_exception.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_datasource.dart';

/// Implementation of Menu Repository
class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;

  MenuRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MenuEntity>> getMenuByHandle(String handle) async {
    try {
      final menu = await remoteDataSource.getMenuByHandle(handle);
      return Right(menu);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get menu: ${e.toString()}'));
    }
  }
}

