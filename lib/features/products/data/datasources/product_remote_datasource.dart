import 'package:flutter/foundation.dart';
import 'package:iconnect/core/graphql/graphql_queries.dart';
import 'package:iconnect/features/products/data/models/banner_model.dart';
import 'package:iconnect/features/products/data/models/brand_model.dart';
import 'package:iconnect/features/products/data/models/collection_model.dart';
import 'package:iconnect/features/products/data/models/home_screen_model.dart';
import 'package:iconnect/features/products/data/models/offer_model.dart';
import 'package:iconnect/features/products/data/models/product_model.dart';
import 'package:iconnect/features/products/data/parsers/product_parsers.dart';
import 'package:iconnect/services/graphql_base_service.dart';

/// Abstract Product Remote Data Source
abstract class ProductRemoteDataSource {
  /// Get products with pagination
  Future<ProductsResultModel> getProducts({
    int first = 20,
    String? after,
    String? query,
    String? sortKey,
    bool? reverse,
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
    String? after,
    String? sortKey,
    bool? reverse,
  });

  /// Get all unique brands (vendors) from products
  Future<List<BrandModel>> getBrands({int first = 250});

  /// Get product recommendations
  Future<List<ProductModel>> getProductRecommendations(String productId);

  /// Get home banners from metaobjects
  Future<List<BannerModel>> getHomeBanners({int first = 10});

  /// Get offer blocks from metaobjects
  Future<List<OfferBlockModel>> getOfferBlocks();

  /// Get home screen sections
  Future<List<HomeScreenSectionModel>> getHomeScreenSections();

  /// Get collection filters
  Future<Map<String, dynamic>> getCollectionWithFilters({
    required String handle,
  });
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
    String? sortKey,
    bool? reverse,
  }) async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getProducts,
      variables: {
        'first': first,
        if (after != null) 'after': after,
        if (query != null) 'query': query,
        if (sortKey != null) 'sortKey': sortKey,
        if (reverse != null) 'reverse': reverse,
      },
    );

    // Heavy parsing offloaded to isolate
    final flattened = await compute(parseFlattenedProducts, result);
    final products =
        flattened.map((m) => ProductModel.fromFlattenedJson(m)).toList();

    final pageInfo =
        result['products']?['pageInfo'] as Map<String, dynamic>? ?? {};

    return ProductsResultModel(
      products: products,
      pageInfo: ProductsPageInfoModel.fromJson(pageInfo),
    );
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

    final flattened = await compute(parseFlattenedProduct, productData);
    return ProductModel.fromFlattenedJson(flattened);
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

    final flattened = await compute(parseFlattenedProduct, productData);
    return ProductModel.fromFlattenedJson(flattened);
  }

  @override
  Future<List<CollectionModel>> getCollections({int first = 10}) async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getCollections,
      variables: {'first': first},
    );

    final flattened = await compute(parseFlattenedCollections, result);
    return flattened.map((m) => CollectionModel.fromFlattenedJson(m)).toList();
  }

  @override
  Future<Map<String, dynamic>> getCollectionByHandle({
    required String handle,
    int first = 20,
    String? after,
    String? sortKey,
    bool? reverse,
  }) async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getCollectionByHandle,
      variables: {
        'handle': handle,
        'first': first,
        if (after != null) 'after': after,
        if (sortKey != null) 'sortKey': sortKey,
        if (reverse != null) 'reverse': reverse,
      },
    );

    return result;
  }

  @override
  Future<List<BrandModel>> getBrands({int first = 250}) async {
    // Fetch brands from metaobjects
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getBrandsFromMetaobjects,
      variables: {'first': first},
    );

    final flattened = await compute(parseFlattenedBrands, result);
    return flattened.map((m) => BrandModel.fromFlattenedJson(m)).toList();
  }

  @override
  Future<List<ProductModel>> getProductRecommendations(String productId) async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getProductRecommendations,
      variables: {'productId': productId},
    );

    final flattened = await compute(parseFlattenedRecommendations, result);
    return flattened.map((m) => ProductModel.fromFlattenedJson(m)).toList();
  }

  @override
  Future<List<BannerModel>> getHomeBanners({int first = 10}) async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getHomeBanners,
      variables: {'first': first},
    );

    final flattened = await compute(parseFlattenedBanners, result);
    return flattened.map((m) => BannerModel.fromFlattenedJson(m)).toList();
  }

  @override
  Future<List<OfferBlockModel>> getOfferBlocks() async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getOfferBlocks,
      variables: {},
    );

    final flattened = await compute(parseFlattenedOfferBlocks, result);
    return flattened.map((m) => OfferBlockModel.fromFlattenedJson(m)).toList();
  }

  @override
  Future<List<HomeScreenSectionModel>> getHomeScreenSections() async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getHomeScreen,
      variables: {},
    );

    final metaobjects = result['metaobjects'] as Map<String, dynamic>?;
    final nodes = metaobjects?['nodes'] as List<dynamic>? ?? [];

    return nodes
        .map(
          (node) =>
              HomeScreenSectionModel.fromJson(node as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getCollectionWithFilters({
    required String handle,
  }) async {
    final result = await graphQLService.executeQuery(
      GraphQLQueries.getCollectionWithFilters,
      variables: {'handle': handle},
    );

    return result;
  }
}
