import 'package:equatable/equatable.dart';

/// Order Entity - Domain layer representation of order data
class OrderEntity extends Equatable {
  final String id;
  final String name;
  final int orderNumber;
  final String? processedAt;
  final MoneyEntity totalPrice;
  final String? fulfillmentStatus;
  final String? financialStatus;
  final List<OrderLineItemEntity> lineItems;

  const OrderEntity({
    required this.id,
    required this.name,
    required this.orderNumber,
    this.processedAt,
    required this.totalPrice,
    this.fulfillmentStatus,
    this.financialStatus,
    this.lineItems = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    orderNumber,
    processedAt,
    totalPrice,
    fulfillmentStatus,
    financialStatus,
    lineItems,
  ];
}

/// Order Line Item Entity
class OrderLineItemEntity extends Equatable {
  final String title;
  final int quantity;
  final MoneyEntity originalTotalPrice;
  final OrderVariantEntity? variant;

  const OrderLineItemEntity({
    required this.title,
    required this.quantity,
    required this.originalTotalPrice,
    this.variant,
  });

  @override
  List<Object?> get props => [title, quantity, originalTotalPrice, variant];
}

/// Order Variant Entity
class OrderVariantEntity extends Equatable {
  final String id;
  final String? title;
  final String? imageUrl;

  const OrderVariantEntity({required this.id, this.title, this.imageUrl});

  @override
  List<Object?> get props => [id, title, imageUrl];
}

/// Money Entity
class MoneyEntity extends Equatable {
  final String amount;
  final String currencyCode;

  const MoneyEntity({required this.amount, required this.currencyCode});

  String get formattedAmount {
    final amountValue = double.tryParse(amount) ?? 0.0;
    return '${currencyCode} ${amountValue.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [amount, currencyCode];
}
