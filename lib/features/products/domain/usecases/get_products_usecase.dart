import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';

/// Get Products Use Case
class GetProductsUsecase implements Usecase<ProductsResult, GetProductsParams> {
  final ProductRepository repository;

  GetProductsUsecase(this.repository);

  @override
  Future<Either<Failure, ProductsResult>> call(GetProductsParams params) async {
    return await repository.getProducts(
      first: params.first,
      after: params.after,
      query: params.query,
      sortKey: params.sortKey,
      reverse: params.reverse,
    );
  }
}

/// Parameters for GetProductsUsecase
class GetProductsParams extends Equatable {
  final int first;
  final String? after;
  final String? query;
  final String? sortKey;
  final bool? reverse;

  const GetProductsParams({
    this.first = 20,
    this.after,
    this.query,
    this.sortKey,
    this.reverse,
  });

  @override
  List<Object?> get props => [first, after, query, sortKey, reverse];
}

