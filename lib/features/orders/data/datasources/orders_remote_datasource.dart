import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:iconnect/core/storage/local_storage_service.dart';
import 'package:iconnect/features/orders/data/models/order_model.dart';
import 'package:iconnect/features/orders/domain/entities/order_entity.dart';
import 'package:iconnect/services/graphql_base_service.dart';

/// Recursively converts a [Map] (any key/value types) returned by Firebase
/// Cloud Functions into a [Map<String, dynamic>] so model parsers can safely
/// cast nested objects.
Map<String, dynamic> _deepConvert(Map<dynamic, dynamic> map) {
  return map.map((key, value) {
    final converted = value is Map
        ? _deepConvert(value)
        : value is List
            ? _deepConvertList(value)
            : value;
    return MapEntry(key.toString(), converted);
  });
}

List<dynamic> _deepConvertList(List<dynamic> list) {
  return list.map((item) {
    if (item is Map) return _deepConvert(item);
    if (item is List) return _deepConvertList(item);
    return item;
  }).toList();
}

/// Abstract Orders Remote Data Source
abstract class OrdersRemoteDataSource {
  Future<List<OrderEntity>> getOrders({int first = 10, String? after});
}

/// Orders Remote Data Source Implementation
///
/// Fetches orders by calling the `getOrdersByEmail` Cloud Function.
/// The Cloud Function queries the Shopify Admin API by email, so no customer
/// access token is required on the client side.
///
/// If the Cloud Function is not yet deployed (`not-found` error), an empty
/// list is returned so the UI shows the "No orders yet" state instead of
/// crashing.
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ShopifyGraphQLService graphQLService;

  OrdersRemoteDataSourceImpl({required this.graphQLService});

  @override
  Future<List<OrderEntity>> getOrders({int first = 10, String? after}) async {
    final email = LocalStorageService.email;
    if (email == null || email.isEmpty) {
      throw Exception('User not logged in. Please sign in to view orders.');
    }

    try {
      // Note: email is read server-side from the Firebase Auth token,
      // not passed as a parameter, so a user can never query another user's orders.
      final result = await FirebaseFunctions.instanceFor(region: 'asia-south1')
          .httpsCallable('getOrdersByEmail')
          .call({
            'first': first,
            if (after != null) 'after': after,
          });

      // The Cloud Function returns the same shape as the Shopify Storefront
      // customer orders query: { customer: { orders: { edges: [...] } } }
      // Deep-convert to Map<String, dynamic> because Firebase Functions returns
      // nested maps as Map<Object?, Object?> which breaks model parsing.
      final data = _deepConvert(result.data as Map);
      return OrderModel.listFromJson(data);
    } on FirebaseFunctionsException catch (e) {
      switch (e.code) {
        case 'not-found':
          // Cloud Function not yet deployed — return empty list gracefully.
          log('orders: getOrdersByEmail function not found (not deployed yet). Returning empty list.');
          return [];
        case 'unauthenticated':
          throw Exception('Your session has expired. Please sign in again to view orders.');
        case 'internal':
          // Log the full message (includes Shopify error) for debugging.
          log('orders: getOrdersByEmail internal error — ${e.message}');
          throw Exception('Unable to load orders at this time. Please try again later.');
        default:
          log('orders: getOrdersByEmail error [${e.code}] — ${e.message}');
          throw Exception('Failed to load orders (${e.code}). Please try again.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
