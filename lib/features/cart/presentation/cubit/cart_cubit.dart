import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/features/cart/domain/entities/cart_entity.dart';
import 'package:iconnect/features/cart/domain/repositories/cart_repository.dart';
import 'package:iconnect/features/cart/domain/usecases/add_line_items_usecase.dart';
import 'package:iconnect/features/cart/domain/usecases/create_checkout_usecase.dart';
import 'package:iconnect/features/cart/domain/usecases/get_checkout_usecase.dart';
import 'package:iconnect/features/cart/domain/usecases/remove_line_items_usecase.dart';
import 'package:iconnect/features/cart/domain/usecases/update_line_items_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cart_state.dart';

/// Cart Cubit - Manages cart state and operations
class CartCubit extends Cubit<CartState> {
  final CreateCheckoutUsecase createCheckoutUsecase;
  final GetCheckoutUsecase getCheckoutUsecase;
  final AddLineItemsUsecase addLineItemsUsecase;
  final UpdateLineItemsUsecase updateLineItemsUsecase;
  final RemoveLineItemsUsecase removeLineItemsUsecase;

  static const String _checkoutIdKey = 'checkout_id';
  String? _currentCheckoutId;

  CartCubit({
    required this.createCheckoutUsecase,
    required this.getCheckoutUsecase,
    required this.addLineItemsUsecase,
    required this.updateLineItemsUsecase,
    required this.removeLineItemsUsecase,
  }) : super(const CartInitial()) {
    _initializeCart();
  }

  /// Initialize cart by loading saved checkout ID
  Future<void> _initializeCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentCheckoutId = prefs.getString(_checkoutIdKey);

      if (_currentCheckoutId != null) {
        await loadCart();
      } else {
        emit(const CartEmpty());
      }
    } catch (e) {
      emit(const CartEmpty());
    }
  }

  /// Load cart from saved checkout ID
  Future<void> loadCart() async {
    if (_currentCheckoutId == null) {
      emit(const CartEmpty());
      return;
    }

    emit(const CartLoading());

    final result = await getCheckoutUsecase(
      GetCheckoutParams(checkoutId: _currentCheckoutId!),
    );

    result.fold(
      (failure) {
        // If checkout not found or expired, clear it
        _clearCheckoutId();
        emit(CartError(message: failure.message));
      },
      (cart) {
        if (cart.isEmpty) {
          emit(const CartEmpty());
        } else {
          emit(CartLoaded(cart: cart));
        }
      },
    );
  }

  /// Add item to cart
  Future<void> addToCart({
    required String variantId,
    int quantity = 1,
  }) async {
    final lineItem = CheckoutLineItem(
      variantId: variantId,
      quantity: quantity,
    );

    // If no checkout exists, create one
    if (_currentCheckoutId == null) {
      await _createNewCheckout([lineItem]);
    } else {
      await _addToExistingCheckout([lineItem]);
    }
  }

  /// Create new checkout
  Future<void> _createNewCheckout(List<CheckoutLineItem> lineItems) async {
    emit(const CartLoading());

    final result = await createCheckoutUsecase(
      CreateCheckoutParams(lineItems: lineItems),
    );

    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (cart) {
        _currentCheckoutId = cart.id;
        _saveCheckoutId(cart.id);
        emit(CartLoaded(cart: cart));
      },
    );
  }

  /// Add to existing checkout
  Future<void> _addToExistingCheckout(List<CheckoutLineItem> lineItems) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(CartOperationInProgress(
        currentCart: currentState.cart,
        operation: 'Adding to cart',
      ));
    } else {
      emit(const CartLoading());
    }

    final result = await addLineItemsUsecase(
      AddLineItemsParams(
        checkoutId: _currentCheckoutId!,
        lineItems: lineItems,
      ),
    );

    result.fold(
      (failure) {
        // Restore previous state or show error
        if (currentState is CartLoaded) {
          emit(currentState);
        }
        emit(CartError(
          message: failure.message,
          cart: currentState is CartLoaded ? currentState.cart : null,
        ));
      },
      (cart) => emit(CartLoaded(cart: cart)),
    );
  }

  /// Update item quantity
  Future<void> updateQuantity({
    required String lineItemId,
    required int quantity,
  }) async {
    if (_currentCheckoutId == null) return;

    final currentState = state;
    if (currentState is CartLoaded) {
      emit(CartOperationInProgress(
        currentCart: currentState.cart,
        operation: 'Updating quantity',
      ));
    }

    final result = await updateLineItemsUsecase(
      UpdateLineItemsParams(
        checkoutId: _currentCheckoutId!,
        lineItems: [
          CheckoutLineItemUpdate(
            id: lineItemId,
            quantity: quantity,
          ),
        ],
      ),
    );

    result.fold(
      (failure) {
        if (currentState is CartLoaded) {
          emit(currentState);
        }
        emit(CartError(
          message: failure.message,
          cart: currentState is CartLoaded ? currentState.cart : null,
        ));
      },
      (cart) {
        if (cart.isEmpty) {
          emit(const CartEmpty());
        } else {
          emit(CartLoaded(cart: cart));
        }
      },
    );
  }

  /// Remove item from cart
  Future<void> removeFromCart(String lineItemId) async {
    if (_currentCheckoutId == null) return;

    final currentState = state;
    if (currentState is CartLoaded) {
      emit(CartOperationInProgress(
        currentCart: currentState.cart,
        operation: 'Removing item',
      ));
    }

    final result = await removeLineItemsUsecase(
      RemoveLineItemsParams(
        checkoutId: _currentCheckoutId!,
        lineItemIds: [lineItemId],
      ),
    );

    result.fold(
      (failure) {
        if (currentState is CartLoaded) {
          emit(currentState);
        }
        emit(CartError(
          message: failure.message,
          cart: currentState is CartLoaded ? currentState.cart : null,
        ));
      },
      (cart) {
        if (cart.isEmpty) {
          emit(const CartEmpty());
        } else {
          emit(CartLoaded(cart: cart));
        }
      },
    );
  }

  /// Increment item quantity
  Future<void> incrementQuantity(String lineItemId) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final item = currentState.cart.items.firstWhere(
      (item) => item.id == lineItemId,
    );

    await updateQuantity(
      lineItemId: lineItemId,
      quantity: item.quantity + 1,
    );
  }

  /// Decrement item quantity
  Future<void> decrementQuantity(String lineItemId) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final item = currentState.cart.items.firstWhere(
      (item) => item.id == lineItemId,
    );

    if (item.quantity <= 1) {
      await removeFromCart(lineItemId);
    } else {
      await updateQuantity(
        lineItemId: lineItemId,
        quantity: item.quantity - 1,
      );
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    await _clearCheckoutId();
    emit(const CartEmpty());
  }

  /// Toggle cart drawer
  void toggleCartDrawer() {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWith(isDrawerOpen: !currentState.isDrawerOpen));
    } else if (currentState is CartEmpty) {
      emit(currentState.copyWith(isDrawerOpen: !currentState.isDrawerOpen));
    }
  }

  /// Close cart drawer
  void closeCartDrawer() {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWith(isDrawerOpen: false));
    } else if (currentState is CartEmpty) {
      emit(currentState.copyWith(isDrawerOpen: false));
    }
  }

  /// Open cart drawer
  void openCartDrawer() {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWith(isDrawerOpen: true));
    } else if (currentState is CartEmpty) {
      emit(currentState.copyWith(isDrawerOpen: true));
    }
  }

  /// Get checkout URL for completing purchase
  String? get checkoutUrl {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.cart.webUrl;
    }
    return null;
  }

  /// Get current cart
  CartEntity? get currentCart {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.cart;
    }
    return null;
  }

  /// Save checkout ID to local storage
  Future<void> _saveCheckoutId(String checkoutId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_checkoutIdKey, checkoutId);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Clear checkout ID from local storage
  Future<void> _clearCheckoutId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_checkoutIdKey);
      _currentCheckoutId = null;
    } catch (e) {
      // Handle error silently
    }
  }
}

