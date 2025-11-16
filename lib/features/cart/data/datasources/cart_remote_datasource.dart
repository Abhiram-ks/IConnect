import 'package:iconnect/core/graphql/graphql_queries.dart';
import 'package:iconnect/features/cart/data/models/cart_model.dart';
import 'package:iconnect/features/cart/domain/repositories/cart_repository.dart';
import 'package:iconnect/services/graphql_base_service.dart';

/// Abstract Cart Remote Data Source
abstract class CartRemoteDataSource {
  /// Create a new checkout (cart)
  Future<CartModel> createCheckout({
    required List<CheckoutLineItem> lineItems,
  });

  /// Get checkout by ID
  Future<CartModel> getCheckout(String checkoutId);

  /// Add line items to existing checkout
  Future<CartModel> addLineItems({
    required String checkoutId,
    required List<CheckoutLineItem> lineItems,
  });

  /// Update line item quantities in checkout
  Future<CartModel> updateLineItems({
    required String checkoutId,
    required List<CheckoutLineItemUpdate> lineItems,
  });

  /// Remove line items from checkout
  Future<CartModel> removeLineItems({
    required String checkoutId,
    required List<String> lineItemIds,
  });
}

/// Cart Remote Data Source Implementation
class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ShopifyGraphQLService graphQLService;

  CartRemoteDataSourceImpl({required this.graphQLService});

  @override
  Future<CartModel> createCheckout({
    required List<CheckoutLineItem> lineItems,
  }) async {
    final result = await graphQLService.executeMutation(
      GraphQLQueries.cartCreate,
      variables: {
        'input': {
          'lines': lineItems.map((item) => item.toJson()).toList(),
        },
      },
    );

    final cartData = result['cartCreate'] as Map<String, dynamic>;
    return CartModel.fromJson(cartData);
  }

  @override
  Future<CartModel> getCheckout(String checkoutId) async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getCart,
      variables: {
        'id': checkoutId,
      },
    );

    final cartData = result['cart'] as Map<String, dynamic>?;
    if (cartData == null) {
      throw Exception('Cart not found');
    }

    return CartModel.fromJson({'cart': cartData});
  }

  @override
  Future<CartModel> addLineItems({
    required String checkoutId,
    required List<CheckoutLineItem> lineItems,
  }) async {
    final result = await graphQLService.executeMutation(
      GraphQLQueries.cartLinesAdd,
      variables: {
        'cartId': checkoutId,
        'lines': lineItems.map((item) => item.toJson()).toList(),
      },
    );

    final cartData = result['cartLinesAdd'] as Map<String, dynamic>;
    return CartModel.fromJson(cartData);
  }

  @override
  Future<CartModel> updateLineItems({
    required String checkoutId,
    required List<CheckoutLineItemUpdate> lineItems,
  }) async {
    final result = await graphQLService.executeMutation(
      GraphQLQueries.cartLinesUpdate,
      variables: {
        'cartId': checkoutId,
        'lines': lineItems.map((item) => item.toJson()).toList(),
      },
    );

    final cartData = result['cartLinesUpdate'] as Map<String, dynamic>;
    return CartModel.fromJson(cartData);
  }

  @override
  Future<CartModel> removeLineItems({
    required String checkoutId,
    required List<String> lineItemIds,
  }) async {
    final result = await graphQLService.executeMutation(
      GraphQLQueries.cartLinesRemove,
      variables: {
        'cartId': checkoutId,
        'lineIds': lineItemIds,
      },
    );

    final cartData = result['cartLinesRemove'] as Map<String, dynamic>;
    return CartModel.fromJson(cartData);
  }
}

