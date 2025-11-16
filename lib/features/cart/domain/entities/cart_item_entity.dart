import 'package:equatable/equatable.dart';

/// Cart Item Entity - Represents a line item in the cart/checkout
class CartItemEntity extends Equatable {
  final String id; // Line item ID from Shopify
  final String variantId; // Product variant ID
  final String productId; // Product ID
  final String title;
  final String? productTitle;
  final int quantity;
  final double price;
  final String currencyCode;
  final String? imageUrl;
  final double? compareAtPrice;

  const CartItemEntity({
    required this.id,
    required this.variantId,
    required this.productId,
    required this.title,
    this.productTitle,
    required this.quantity,
    required this.price,
    required this.currencyCode,
    this.imageUrl,
    this.compareAtPrice,
  });

  /// Calculate total price for this line item
  double get totalPrice => price * quantity;

  /// Calculate total compare at price if available
  double? get totalCompareAtPrice =>
      compareAtPrice != null ? compareAtPrice! * quantity : null;

  /// Check if item has discount
  bool get hasDiscount =>
      compareAtPrice != null && compareAtPrice! > price;

  /// Calculate discount percentage
  double? get discountPercentage {
    if (!hasDiscount) return null;
    return ((compareAtPrice! - price) / compareAtPrice!) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        variantId,
        productId,
        title,
        productTitle,
        quantity,
        price,
        currencyCode,
        imageUrl,
        compareAtPrice,
      ];
}

