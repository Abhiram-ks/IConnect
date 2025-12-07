import 'package:equatable/equatable.dart';
import 'package:iconnect/features/orders/domain/entities/order_entity.dart';

/// Orders State
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OrdersInitial extends OrdersState {
  final List<OrderEntity> orders;
  const OrdersInitial({this.orders = const []});
  
  @override
  List<Object?> get props => [orders];
}

/// Loading state
class OrdersLoading extends OrdersState {
  final List<OrderEntity> orders;
  const OrdersLoading({this.orders = const []});
  
  @override
  List<Object?> get props => [orders];
}

/// Loaded state
class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  final bool hasMore;
  final String? nextCursor;

  const OrdersLoaded({
    required this.orders,
    this.hasMore = false,
    this.nextCursor,
  });

  @override
  List<Object?> get props => [orders, hasMore, nextCursor];
}

/// Error state
class OrdersError extends OrdersState {
  final String message;
  final List<OrderEntity> orders;

  const OrdersError(this.message, {this.orders = const []});

  @override
  List<Object?> get props => [message, orders];
}

