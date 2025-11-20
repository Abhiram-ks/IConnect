import 'package:iconnect/core/graphql/graphql_queries.dart';
import 'package:iconnect/features/products/data/models/brand_model.dart';
import 'package:iconnect/features/products/data/models/collection_model.dart';
import 'package:iconnect/features/products/data/models/product_model.dart';
import 'package:iconnect/services/graphql_base_service.dart';

/// Abstract Product Remote Data Source
abstract class ProductRemoteDataSource {
  /// Get products with pagination
  Future<ProductsResultModel> getProducts({
    int first = 20,
    String? after,
    String? query,
  });

  /// Get product by handle
  Future<ProductModel> getProductByHandle(String handle);

  /// Get product by ID
  Future<ProductModel> getProductById(String id);

  /// Get collections
  Future<List<CollectionModel>> getCollections({int first = 10});

  /// Get collection by handle with products
  Future<Map<String, dynamic>> getCollectionByHandle({
    required String handle,
    int first = 20,
  });

  /// Get all unique brands (vendors) from products
  Future<List<BrandModel>> getBrands({int first = 250});
}

/// Product Remote Data Source Implementation
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ShopifyGraphQLService graphQLService;

  ProductRemoteDataSourceImpl({required this.graphQLService});

  @override
  Future<ProductsResultModel> getProducts({
    int first = 20,
    String? after,
    String? query,
  }) async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getProducts,
      variables: {
        'first': first,
        if (after != null) 'after': after,
        if (query != null) 'query': query,
      },
    );

    return ProductsResultModel.fromJson(result);
  }

  @override
  Future<ProductModel> getProductByHandle(String handle) async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getProductByHandle,
      variables: {'handle': handle},
    );

    final productData = result['product'] as Map<String, dynamic>?;
    if (productData == null) {
      throw Exception('Product not found');
    }

    return ProductModel.fromJson(productData);
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getProductById,
      variables: {'id': id},
    );

    final productData = result['product'] as Map<String, dynamic>?;
    if (productData == null) {
      throw Exception('Product not found');
    }

    return ProductModel.fromJson(productData);
  }

  @override
  Future<List<CollectionModel>> getCollections({int first = 10}) async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getCollections,
      variables: {'first': first},
    );

    final collectionsList = <CollectionModel>[];
    if (result['collections'] != null &&
        result['collections']['edges'] != null) {
      final edges = result['collections']['edges'] as List;
      for (final edge in edges) {
        collectionsList.add(CollectionModel.fromJson(edge['node']));
      }
    }

    return collectionsList;
  }

  @override
  Future<Map<String, dynamic>> getCollectionByHandle({
    required String handle,
    int first = 20,
  }) async {
    print(
      '🔍 DEBUG DataSource: Executing GraphQL query with handle: "$handle", first: $first',
    );
    print(
      '🔍 DEBUG DataSource: Query: ${GraphQLQueries.getCollectionByHandle}',
    );

    final result = await graphQLService.executeQuery(
      GraphQLQueries.getCollectionByHandle,
      variables: {'handle': handle, 'first': first},
    );

    print('🔍 DEBUG DataSource: GraphQL response: $result');
    return result;
  }

  @override
  Future<List<BrandModel>> getBrands({int first = 250}) async {
    // Fetch products to extract unique vendors
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getBrands,
      variables: {'first': first},
    );

    final vendorsSet = <String>{};

    if (result['products'] != null && result['products']['edges'] != null) {
      final edges = result['products']['edges'] as List;

      for (final edge in edges) {
        final node = edge['node'] as Map<String, dynamic>?;
        if (node == null) continue;

        final vendor = node['vendor'] as String?;
        if (vendor != null && vendor.isNotEmpty) {
          vendorsSet.add(vendor);
        }
      }
    }

    // Convert unique vendors to BrandModel list
    return vendorsSet.map((vendor) {
      return BrandModel.fromVendor(vendor: vendor);
    }).toList();
  }
}
