import 'package:dartz/dartz.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/features/cart/domain/entities/cart_entity.dart';

/// Abstract Cart Repository Interface
abstract class CartRepository {
  /// Create a new checkout (cart)
  Future<Either<Failure, CartEntity>> createCheckout({
    required List<CheckoutLineItem> lineItems,
  });

  /// Get checkout by ID
  Future<Either<Failure, CartEntity>> getCheckout(String checkoutId);

  /// Add line items to existing checkout
  Future<Either<Failure, CartEntity>> addLineItems({
    required String checkoutId,
    required List<CheckoutLineItem> lineItems,
  });

  /// Update line item quantities in checkout
  Future<Either<Failure, CartEntity>> updateLineItems({
    required String checkoutId,
    required List<CheckoutLineItemUpdate> lineItems,
  });

  /// Remove line items from checkout
  Future<Either<Failure, CartEntity>> removeLineItems({
    required String checkoutId,
    required List<String> lineItemIds,
  });
}

/// Checkout line item input for creating/adding items (Cart API format)
class CheckoutLineItem {
  final String variantId;
  final int quantity;

  const CheckoutLineItem({
    required this.variantId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'merchandiseId': variantId, // Cart API uses merchandiseId
      'quantity': quantity,
    };
  }
}

/// Checkout line item update input for updating quantities
class CheckoutLineItemUpdate {
  final String id; // Line item ID
  final int quantity;

  const CheckoutLineItemUpdate({
    required this.id,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
    };
  }
}

