import 'package:bloc/bloc.dart';
import 'package:iconnect/features/orders/domain/entities/order_entity.dart';
import 'package:iconnect/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:iconnect/features/orders/presentation/cubit/orders_state.dart';

/// Orders Cubit - Manages orders state and operations
class OrdersCubit extends Cubit<OrdersState> {
  final GetOrdersUsecase getOrdersUsecase;

  OrdersCubit({required this.getOrdersUsecase}) : super(OrdersInitial());

  /// Load customer orders
  Future<void> loadOrders({bool refresh = false}) async {
    List<OrderEntity> currentOrders = [];
    if (state is OrdersLoaded) {
      currentOrders = (state as OrdersLoaded).orders;
    } else if (state is OrdersError) {
      currentOrders = (state as OrdersError).orders;
    } else if (state is OrdersLoading) {
      currentOrders = (state as OrdersLoading).orders;
    }

    if (refresh) {
      emit(OrdersLoading(orders: currentOrders));
    } else if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      if (!currentState.hasMore) return;
      emit(OrdersLoading(orders: currentOrders));
    } else {
      emit(OrdersLoading(orders: currentOrders));
    }

    try {
      String? after;
      if (!refresh && state is OrdersLoaded) {
        after = (state as OrdersLoaded).nextCursor;
      } else if (!refresh && state is OrdersLoading) {
        // Try to get cursor from previous loaded state
        // For pagination, we need to track this better
        after = null;
      }

      final result = await getOrdersUsecase(
        GetOrdersParams(first: 10, after: after),
      );

      result.fold(
        (failure) {
          emit(OrdersError(failure.message, orders: currentOrders));
        },
        (orders) {
          if (refresh) {
            emit(
              OrdersLoaded(
                orders: orders,
                hasMore: orders.length >= 10, // Assuming pagination
                nextCursor: orders.isNotEmpty ? orders.last.id : null,
              ),
            );
          } else if (currentOrders.isNotEmpty) {
            emit(
              OrdersLoaded(
                orders: [...currentOrders, ...orders],
                hasMore: orders.length >= 10,
                nextCursor: orders.isNotEmpty ? orders.last.id : null,
              ),
            );
          } else {
            emit(
              OrdersLoaded(
                orders: orders,
                hasMore: orders.length >= 10,
                nextCursor: orders.isNotEmpty ? orders.last.id : null,
              ),
            );
          }
        },
      );
    } catch (e) {
      final currentOrders =
          state is OrdersLoaded
              ? (state as OrdersLoaded).orders
              : <OrderEntity>[];
      emit(OrdersError(e.toString(), orders: currentOrders));
    }
  }
}
