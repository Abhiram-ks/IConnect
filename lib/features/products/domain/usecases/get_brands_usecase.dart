import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/products/domain/entities/brand_entity.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';

/// Get Brands Use Case
class GetBrandsUsecase implements Usecase<List<BrandEntity>, GetBrandsParams> {
  final ProductRepository repository;

  GetBrandsUsecase(this.repository);

  @override
  Future<Either<Failure, List<BrandEntity>>> call(GetBrandsParams params) async {
    return await repository.getBrands(first: params.first);
  }
}

/// Parameters for GetBrandsUsecase
class GetBrandsParams extends Equatable {
  final int first;

  const GetBrandsParams({this.first = 250});

  @override
  List<Object?> get props => [first];
}

