part of 'cart_cubit.dart';

/// Cart State
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CartInitial extends CartState {
  const CartInitial();
}

/// Loading state
class CartLoading extends CartState {
  const CartLoading();
}

/// Cart loaded successfully
class CartLoaded extends CartState {
  final CartEntity cart;
  final bool isDrawerOpen;

  const CartLoaded({required this.cart, this.isDrawerOpen = false});

  CartLoaded copyWith({CartEntity? cart, bool? isDrawerOpen}) {
    return CartLoaded(
      cart: cart ?? this.cart,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
    );
  }

  @override
  List<Object?> get props => [cart, isDrawerOpen];
}

/// Empty cart state
class CartEmpty extends CartState {
  final bool isDrawerOpen;

  const CartEmpty({this.isDrawerOpen = false});

  CartEmpty copyWith({bool? isDrawerOpen}) {
    return CartEmpty(isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen);
  }

  @override
  List<Object?> get props => [isDrawerOpen];
}

/// Error state
class CartError extends CartState {
  final String message;
  final CartEntity? cart; // Keep cart data if available

  const CartError({required this.message, this.cart});

  @override
  List<Object?> get props => [message, cart];
}

/// Operation in progress (add/update/remove)
class CartOperationInProgress extends CartState {
  final CartEntity currentCart;
  final String operation;

  const CartOperationInProgress({
    required this.currentCart,
    required this.operation,
  });

  @override
  List<Object?> get props => [currentCart, operation];
}
