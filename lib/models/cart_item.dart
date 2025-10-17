class CartItem {
  final int id;
  final String imageUrl;
  final String productName;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final String? offerText;
  int quantity;

  CartItem({
    required this.id,
    required this.imageUrl,
    required this.productName,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    this.offerText,
    this.quantity = 1,
  });

  double get totalPrice => discountedPrice * quantity;

  CartItem copyWith({
    int? id,
    String? imageUrl,
    String? productName,
    String? description,
    double? originalPrice,
    double? discountedPrice,
    String? offerText,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      offerText: offerText ?? this.offerText,
      quantity: quantity ?? this.quantity,
    );
  }
}
