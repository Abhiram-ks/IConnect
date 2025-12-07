import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/orders/domain/entities/order_entity.dart';
import 'package:iconnect/features/orders/domain/repositories/orders_repository.dart';

/// Get Orders Use Case
class GetOrdersUsecase implements Usecase<List<OrderEntity>, GetOrdersParams> {
  final OrdersRepository repository;

  GetOrdersUsecase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(
    GetOrdersParams params,
  ) async {
    return await repository.getOrders(first: params.first, after: params.after);
  }
}

/// Get Orders Parameters
class GetOrdersParams extends Equatable {
  final int first;
  final String? after;

  const GetOrdersParams({this.first = 10, this.after});

  @override
  List<Object?> get props => [first, after];
}
