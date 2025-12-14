import 'package:bloc/bloc.dart';
import 'package:iconnect/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:iconnect/features/orders/presentation/cubit/orders_state.dart';

/// Orders Cubit - Manages orders state and operations
class OrdersCubit extends Cubit<OrdersState> {
  final GetOrdersUsecase getOrdersUsecase;

  OrdersCubit({required this.getOrdersUsecase}) : super(OrdersInitial());

  /// Load customer orders
  Future<void> loadOrders({bool refresh = false}) async {
    emit(OrdersLoading(orders: []));

    try {
      final result = await getOrdersUsecase(
        GetOrdersParams(first: 250, after: null), // Fetch up to 250 orders
      );

      result.fold(
        (failure) {
          emit(OrdersError(failure.message, orders: []));
        },
        (orders) {
          emit(OrdersLoaded(orders: orders, hasMore: false, nextCursor: null));
        },
      );
    } catch (e) {
      emit(OrdersError(e.toString(), orders: []));
    }
  }
}
