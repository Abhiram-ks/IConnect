import 'package:iconnect/core/storage/secure_storage_service.dart';
import 'package:iconnect/features/orders/data/models/order_model.dart';
import 'package:iconnect/features/orders/domain/entities/order_entity.dart';
import 'package:iconnect/services/graphql_base_service.dart';

/// Abstract Orders Remote Data Source
abstract class OrdersRemoteDataSource {
  Future<List<OrderEntity>> getOrders({int first = 10, String? after});
}

/// Orders Remote Data Source Implementation
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ShopifyGraphQLService graphQLService;

  OrdersRemoteDataSourceImpl({required this.graphQLService});

  @override
  Future<List<OrderEntity>> getOrders({int first = 10, String? after}) async {
    try {
      final accessToken = await SecureStorageService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please login again.');
      }

      final result = await graphQLService.getCustomerOrders(
        customerAccessToken: accessToken,
        first: first,
        after: after,
      );
      return OrderModel.listFromJson(result);
    } catch (e) {
      rethrow;
    }
  }
}

