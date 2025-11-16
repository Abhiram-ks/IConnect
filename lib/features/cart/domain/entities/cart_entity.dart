import 'package:equatable/equatable.dart';
import 'package:iconnect/features/cart/domain/entities/cart_item_entity.dart';

/// Cart Entity - Represents the checkout/cart
class CartEntity extends Equatable {
  final String id; // Checkout ID from Shopify
  final List<CartItemEntity> items;
  final double subtotalPrice;
  final double totalPrice;
  final String currencyCode;
  final String? webUrl; // Checkout URL for completing purchase

  const CartEntity({
    required this.id,
    required this.items,
    required this.subtotalPrice,
    required this.totalPrice,
    required this.currencyCode,
    this.webUrl,
  });

  /// Get total number of items in cart
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Calculate total savings if any items have discounts
  double get totalSavings {
    return items.fold(0.0, (sum, item) {
      if (item.compareAtPrice != null) {
        return sum + ((item.compareAtPrice! - item.price) * item.quantity);
      }
      return sum;
    });
  }

  @override
  List<Object?> get props => [
        id,
        items,
        subtotalPrice,
        totalPrice,
        currencyCode,
        webUrl,
      ];
}

