import '../../../../core/graphql/graphql_queries.dart';
import '../../../../services/api_exception.dart';
import '../../../../services/graphql_base_service.dart';
import '../models/menu_model.dart';

/// Menu Remote Data Source
/// Handles all menu-related API calls to Shopify Storefront API
abstract class MenuRemoteDataSource {
  /// Get menu by handle
  Future<MenuModel> getMenuByHandle(String handle);
}

/// Implementation of Menu Remote Data Source
class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final ShopifyGraphQLService graphQLService;

  MenuRemoteDataSourceImpl({required this.graphQLService});

  @override
  Future<MenuModel> getMenuByHandle(String handle) async {
    try {
      final result = await graphQLService.executeQuery(
        GraphQLQueries.getMenu,
        variables: {
          'menuHandle': handle,
        },
      );

      // Extract menu data from response
      final menuData = result['menu'];
      
      if (menuData == null) {
        throw ApiException(
          message: 'Menu not found with handle: $handle',
        );
      }

      return MenuModel.fromJson(menuData as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch menu: ${e.toString()}',
      );
    }
  }
}

