import 'package:iconnect/features/cart/domain/entities/cart_item_entity.dart';

/// Cart Item Model - Data layer representation
class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.variantId,
    required super.productId,
    required super.title,
    super.productTitle,
    required super.quantity,
    required super.price,
    required super.currencyCode,
    super.imageUrl,
    super.compareAtPrice,
  });

  /// Create from JSON (Shopify Cart API line item)
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final node = json['node'] ?? json;
    final merchandise = node['merchandise'] as Map<String, dynamic>?;
    final product = merchandise?['product'] as Map<String, dynamic>?;
    final priceData = merchandise?['price'] as Map<String, dynamic>?;
    final compareAtPriceData = merchandise?['compareAtPrice'] as Map<String, dynamic>?;
    final image = merchandise?['image'] as Map<String, dynamic>?;

    // Extract product ID from variant ID (format: gid://shopify/ProductVariant/123)
    String extractProductId(String variantId) {
      // Shopify variant IDs contain the product info
      // For now, we'll use the variant ID as a fallback
      return variantId;
    }

    final variantId = merchandise?['id'] as String? ?? '';
    final variantTitle = merchandise?['title'] as String? ?? '';
    final productTitle = product?['title'] as String? ?? '';

    return CartItemModel(
      id: node['id'] as String,
      variantId: variantId,
      productId: extractProductId(variantId),
      title: variantTitle,
      productTitle: productTitle,
      quantity: node['quantity'] as int? ?? 1,
      price: double.tryParse(priceData?['amount']?.toString() ?? '0') ?? 0.0,
      currencyCode: priceData?['currencyCode'] as String? ?? 'USD',
      imageUrl: image?['url'] as String?,
      compareAtPrice: compareAtPriceData != null
          ? double.tryParse(compareAtPriceData['amount']?.toString() ?? '0')
          : null,
    );
  }

  /// Convert to JSON for API requests (Cart API format)
  Map<String, dynamic> toJson() {
    return {
      'merchandiseId': variantId,
      'quantity': quantity,
    };
  }

  /// Create a copy with updated fields
  CartItemModel copyWith({
    String? id,
    String? variantId,
    String? productId,
    String? title,
    String? productTitle,
    int? quantity,
    double? price,
    String? currencyCode,
    String? imageUrl,
    double? compareAtPrice,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      variantId: variantId ?? this.variantId,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      productTitle: productTitle ?? this.productTitle,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      currencyCode: currencyCode ?? this.currencyCode,
      imageUrl: imageUrl ?? this.imageUrl,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
    );
  }
}

