import 'package:bloc/bloc.dart';
import 'package:iconnect/models/cart_item.dart';

class CartState {
  final List<CartItem> items;
  final bool isDrawerOpen;

  CartState({
    required this.items,
    this.isDrawerOpen = false,
  });

  CartState copyWith({
    List<CartItem>? items,
    bool? isDrawerOpen,
  }) {
    return CartState(
      items: items ?? this.items,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
    );
  }

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState(items: [])) {
    // Add some sample items for testing
    _addSampleItems();
  }

  void _addSampleItems() {
    final sampleItems = [
      CartItem(
        id: 1,
        imageUrl: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop&crop=center",
        productName: "Samsung Galaxy Z Fold 6 12GB",
        description: "256GB - White",
        originalPrice: 4799.00,
        discountedPrice: 4409.00,
        offerText: "-8%",
        quantity: 1,
      ),
    ];
    emit(CartState(items: sampleItems));
  }

  void addToCart(CartItem item) {
    final existingIndex = state.items.indexWhere((cartItem) => cartItem.id == item.id);
    
    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      emit(state.copyWith(items: updatedItems));
    } else {
      emit(state.copyWith(items: [...state.items, item]));
    }
  }

  void removeFromCart(int productId) {
    final updatedItems = state.items.where((item) => item.id != productId).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.id == productId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
  }

  void incrementQuantity(int productId) {
    final item = state.items.firstWhere((item) => item.id == productId);
    updateQuantity(productId, item.quantity + 1);
  }

  void decrementQuantity(int productId) {
    final item = state.items.firstWhere((item) => item.id == productId);
    updateQuantity(productId, item.quantity - 1);
  }

  void toggleCartDrawer() {
    emit(state.copyWith(isDrawerOpen: !state.isDrawerOpen));
  }

  void closeCartDrawer() {
    emit(state.copyWith(isDrawerOpen: false));
  }

  void clearCart() {
    emit(state.copyWith(items: []));
  }
}
