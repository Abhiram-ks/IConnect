import 'package:dartz/dartz.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/features/products/data/datasources/product_remote_datasource.dart';
import 'package:iconnect/features/products/data/models/collection_model.dart';
import 'package:iconnect/features/products/data/models/product_model.dart';
import 'package:iconnect/features/products/domain/entities/banner_entity.dart';
import 'package:iconnect/features/products/domain/entities/brand_entity.dart';
import 'package:iconnect/features/products/domain/entities/collection_entity.dart';
import 'package:iconnect/features/products/domain/entities/home_screen_entity.dart';
import 'package:iconnect/features/products/domain/entities/offer_entity.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';
import 'package:iconnect/services/api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:iconnect/features/products/data/parsers/product_parsers.dart';

/// Product Repository Implementation
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProductsResult>> getProducts({
    int first = 20,
    String? after,
    String? query,
    String? sortKey,
    bool? reverse,
  }) async {
    try {
      final result = await remoteDataSource.getProducts(
        first: first,
        after: after,
        query: query,
        sortKey: sortKey,
        reverse: reverse,
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductByHandle(
    String handle,
  ) async {
    try {
      final result = await remoteDataSource.getProductByHandle(handle);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final result = await remoteDataSource.getProductById(id);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CollectionEntity>>> getCollections({
    int first = 10,
  }) async {
    try {
      final result = await remoteDataSource.getCollections(first: first);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CollectionWithProducts>> getCollectionByHandle({
    required String handle,
    int first = 20,
    String? after,
  }) async {
    try {
      final result = await remoteDataSource.getCollectionByHandle(
        handle: handle,
        first: first,
        after: after,
      );

      // Heavy parsing offloaded to isolate
      final flattened = await compute(
        parseFlattenedCollectionWithProducts,
        result,
      );

      final collectionMap =
          flattened['collection'] as Map<String, dynamic>? ?? const {};
      if (collectionMap.isEmpty) {
        return const Left(NotFoundFailure(message: 'Collection not found'));
      }

      final collection = CollectionModel.fromFlattenedJson(collectionMap);

      final productsMaps =
          (flattened['products'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();
      final productsList =
          productsMaps.map((m) => ProductModel.fromFlattenedJson(m)).toList();

      final pageInfoMap =
          flattened['pageInfo'] as Map<String, dynamic>? ?? const {};
      final productsResult = ProductsResult(
        products: productsList,
        pageInfo: ProductsPageInfo(
          hasNextPage: pageInfoMap['hasNextPage'] as bool? ?? false,
          endCursor: pageInfoMap['endCursor'] as String?,
        ),
      );

      return Right(
        CollectionWithProducts(
          collection: collection,
          products: productsResult,
        ),
      );
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BrandEntity>>> getBrands({
    int first = 250,
  }) async {
    try {
      final result = await remoteDataSource.getBrands(first: first);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductRecommendations(
    String productId,
  ) async {
    try {
      final result = await remoteDataSource.getProductRecommendations(
        productId,
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BannerEntity>>> getHomeBanners({
    int first = 10,
  }) async {
    try {
      final result = await remoteDataSource.getHomeBanners(first: first);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OfferBlockEntity>>> getOfferBlocks() async {
    try {
      final result = await remoteDataSource.getOfferBlocks();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HomeScreenSectionEntity>>> getHomeScreenSections() async {
    try {
      final result = await remoteDataSource.getHomeScreenSections();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on GraphQLException catch (e) {
      return Left(
        GraphQLFailure(
          message: e.message,
          errorCode: e.errorCode,
          statusCode: e.statusCode,
        ),
      );
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
