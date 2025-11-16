import 'package:iconnect/features/cart/data/models/cart_item_model.dart';
import 'package:iconnect/features/cart/domain/entities/cart_entity.dart';
import 'package:iconnect/features/cart/domain/entities/cart_item_entity.dart';

/// Cart Model - Data layer representation
class CartModel extends CartEntity {
  const CartModel({
    required super.id,
    required super.items,
    required super.subtotalPrice,
    required super.totalPrice,
    required super.currencyCode,
    super.webUrl,
  });

  /// Create from JSON (Shopify Cart API)
  factory CartModel.fromJson(Map<String, dynamic> json) {
    final cart = json['cart'] ?? json;
    final lines = cart['lines'] as Map<String, dynamic>?;
    final edges = lines?['edges'] as List<dynamic>? ?? [];
    
    final cost = cart['cost'] as Map<String, dynamic>?;
    final totalAmountData = cost?['totalAmount'] as Map<String, dynamic>?;
    final subtotalAmountData = cost?['subtotalAmount'] as Map<String, dynamic>?;

    return CartModel(
      id: cart['id'] as String,
      items: edges
          .map((edge) => CartItemModel.fromJson(edge as Map<String, dynamic>))
          .toList(),
      subtotalPrice: double.tryParse(
            subtotalAmountData?['amount']?.toString() ?? 
            totalAmountData?['amount']?.toString() ?? '0'
          ) ?? 0.0,
      totalPrice: double.tryParse(totalAmountData?['amount']?.toString() ?? '0') ?? 0.0,
      currencyCode: totalAmountData?['currencyCode'] as String? ?? 'USD',
      webUrl: cart['checkoutUrl'] as String?,
    );
  }

  /// Create empty cart
  factory CartModel.empty() {
    return const CartModel(
      id: '',
      items: [],
      subtotalPrice: 0.0,
      totalPrice: 0.0,
      currencyCode: 'USD',
    );
  }

  /// Convert to JSON for API requests (Cart API format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lines': items.map((item) {
        if (item is CartItemModel) {
          return item.toJson();
        }
        return {
          'merchandiseId': item.variantId,
          'quantity': item.quantity,
        };
      }).toList(),
    };
  }

  /// Create a copy with updated fields
  CartModel copyWith({
    String? id,
    List<CartItemEntity>? items,
    double? subtotalPrice,
    double? totalPrice,
    String? currencyCode,
    String? webUrl,
  }) {
    return CartModel(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotalPrice: subtotalPrice ?? this.subtotalPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      currencyCode: currencyCode ?? this.currencyCode,
      webUrl: webUrl ?? this.webUrl,
    );
  }
}

