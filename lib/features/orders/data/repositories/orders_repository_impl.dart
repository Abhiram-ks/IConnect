import 'package:dartz/dartz.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:iconnect/features/orders/domain/entities/order_entity.dart';
import 'package:iconnect/features/orders/domain/repositories/orders_repository.dart';
import 'package:iconnect/services/api_exception.dart';

/// Orders Repository Implementation
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders({
    int first = 10,
    String? after,
  }) async {
    try {
      final result = await remoteDataSource.getOrders(
        first: first,
        after: after,
      );
      return Right(result);
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
