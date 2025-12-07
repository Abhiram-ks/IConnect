import 'package:iconnect/features/orders/domain/entities/order_entity.dart';

/// Order Model - Data layer representation with JSON serialization
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.name,
    required super.orderNumber,
    super.processedAt,
    required super.totalPrice,
    super.fulfillmentStatus,
    super.financialStatus,
    super.lineItems,
  });

  /// Create OrderModel from JSON response
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final orders = json['customer']?['orders']?['edges'] as List?;
    if (orders == null) {
      return const OrderModel(
        id: '',
        name: '',
        orderNumber: 0,
        totalPrice: MoneyEntity(amount: '0', currencyCode: 'USD'),
      );
    }

    final orderList =
        orders
            .map((edge) => _OrderNodeModel.fromJson(edge['node']))
            .toList()
            .cast<OrderEntity>();

    // This is a list, so we need to handle it differently
    // For now, return the first order as an example
    if (orderList.isNotEmpty) {
      return orderList.first as OrderModel;
    }

    throw Exception('No orders found');
  }

  /// Create list of orders from JSON
  static List<OrderEntity> listFromJson(Map<String, dynamic> json) {
    final orders = json['customer']?['orders']?['edges'] as List?;
    if (orders == null) {
      return [];
    }

    return orders
        .map((edge) => _OrderNodeModel.fromJson(edge['node']))
        .toList();
  }

  /// Convert to OrderEntity
  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      name: name,
      orderNumber: orderNumber,
      processedAt: processedAt,
      totalPrice: totalPrice,
      fulfillmentStatus: fulfillmentStatus,
      financialStatus: financialStatus,
      lineItems: lineItems,
    );
  }
}

/// Internal model for parsing order node
class _OrderNodeModel extends OrderModel {
  const _OrderNodeModel({
    required super.id,
    required super.name,
    required super.orderNumber,
    super.processedAt,
    required super.totalPrice,
    super.fulfillmentStatus,
    super.financialStatus,
    super.lineItems,
  });

  factory _OrderNodeModel.fromJson(Map<String, dynamic> json) {
    final totalPriceData = json['totalPrice'] as Map<String, dynamic>?;
    final totalPrice =
        totalPriceData != null
            ? MoneyModel.fromJson(totalPriceData)
            : const MoneyEntity(amount: '0', currencyCode: 'USD');

    List<OrderLineItemEntity> lineItems = [];
    if (json['lineItems'] != null) {
      final lineItemsData = json['lineItems']['edges'] as List?;
      if (lineItemsData != null) {
        lineItems =
            lineItemsData
                .map((edge) => OrderLineItemModel.fromJson(edge['node']))
                .toList();
      }
    }

    return _OrderNodeModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      orderNumber: json['orderNumber'] as int? ?? 0,
      processedAt: json['processedAt'] as String?,
      totalPrice: totalPrice,
      fulfillmentStatus: json['fulfillmentStatus'] as String?,
      financialStatus: json['financialStatus'] as String?,
      lineItems: lineItems,
    );
  }
}

/// Order Line Item Model
class OrderLineItemModel extends OrderLineItemEntity {
  const OrderLineItemModel({
    required super.title,
    required super.quantity,
    required super.originalTotalPrice,
    super.variant,
  });

  factory OrderLineItemModel.fromJson(Map<String, dynamic> json) {
    final priceData = json['originalTotalPrice'] as Map<String, dynamic>?;
    final price =
        priceData != null
            ? MoneyModel.fromJson(priceData)
            : const MoneyEntity(amount: '0', currencyCode: 'USD');

    OrderVariantEntity? variant;
    if (json['variant'] != null) {
      variant = OrderVariantModel.fromJson(json['variant']);
    }

    return OrderLineItemModel(
      title: json['title'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      originalTotalPrice: price,
      variant: variant,
    );
  }
}

/// Order Variant Model
class OrderVariantModel extends OrderVariantEntity {
  const OrderVariantModel({required super.id, super.title, super.imageUrl});

  factory OrderVariantModel.fromJson(Map<String, dynamic> json) {
    final imageData = json['image'] as Map<String, dynamic>?;
    return OrderVariantModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String?,
      imageUrl: imageData?['url'] as String?,
    );
  }
}

/// Money Model
class MoneyModel extends MoneyEntity {
  const MoneyModel({required super.amount, required super.currencyCode});

  factory MoneyModel.fromJson(Map<String, dynamic> json) {
    return MoneyModel(
      amount: json['amount'] as String? ?? '0',
      currencyCode: json['currencyCode'] as String? ?? 'USD',
    );
  }
}
