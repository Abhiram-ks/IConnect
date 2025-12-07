import 'package:dartz/dartz.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/features/orders/domain/entities/order_entity.dart';

/// Abstract Orders Repository Interface
abstract class OrdersRepository {
  /// Get customer orders
  Future<Either<Failure, List<OrderEntity>>> getOrders({
    int first = 10,
    String? after,
  });
}
