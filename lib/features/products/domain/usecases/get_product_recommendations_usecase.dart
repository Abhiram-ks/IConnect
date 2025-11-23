import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';

/// Get Product Recommendations Use Case
class GetProductRecommendationsUsecase
    implements Usecase<List<ProductEntity>, GetProductRecommendationsParams> {
  final ProductRepository repository;

  GetProductRecommendationsUsecase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
      GetProductRecommendationsParams params) async {
    return await repository.getProductRecommendations(params.productId);
  }
}

/// Parameters for GetProductRecommendationsUsecase
class GetProductRecommendationsParams extends Equatable {
  final String productId;

  const GetProductRecommendationsParams({required this.productId});

  @override
  List<Object?> get props => [productId];
}

