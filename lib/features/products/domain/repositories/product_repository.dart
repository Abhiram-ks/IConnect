import 'package:dartz/dartz.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/features/products/domain/entities/banner_entity.dart';
import 'package:iconnect/features/products/domain/entities/brand_entity.dart';
import 'package:iconnect/features/products/domain/entities/collection_entity.dart';
import 'package:iconnect/features/products/domain/entities/home_screen_entity.dart';
import 'package:iconnect/features/products/domain/entities/offer_entity.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';

/// Abstract Product Repository Interface
abstract class ProductRepository {
  /// Get products with pagination
  Future<Either<Failure, ProductsResult>> getProducts({
    int first = 20,
    String? after,
    String? query,
    String? sortKey,
    bool? reverse,
  });

  /// Get product by handle
  Future<Either<Failure, ProductEntity>> getProductByHandle(String handle);

  /// Get product by ID
  Future<Either<Failure, ProductEntity>> getProductById(String id);

  /// Get collections
  Future<Either<Failure, List<CollectionEntity>>> getCollections({
    int first = 10,
  });

  /// Get collection by handle with products
  Future<Either<Failure, CollectionWithProducts>> getCollectionByHandle({
    required String handle,
    int first = 20,
    String? after,
  });

  /// Get all unique brands (vendors) from products
  Future<Either<Failure, List<BrandEntity>>> getBrands({int first = 250});

  /// Get product recommendations
  Future<Either<Failure, List<ProductEntity>>> getProductRecommendations(
      String productId);

  /// Get home banners from metaobjects
  Future<Either<Failure, List<BannerEntity>>> getHomeBanners({int first = 10});

  /// Get offer blocks from metaobjects
  Future<Either<Failure, List<OfferBlockEntity>>> getOfferBlocks();

  /// Get home screen sections
  Future<Either<Failure, List<HomeScreenSectionEntity>>> getHomeScreenSections();
}

/// Collection with products result
class CollectionWithProducts {
  final CollectionEntity collection;
  final ProductsResult products;

  const CollectionWithProducts({
    required this.collection,
    required this.products,
  });
}
