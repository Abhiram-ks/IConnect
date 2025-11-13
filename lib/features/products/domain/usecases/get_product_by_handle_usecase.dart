import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';

/// Get Product By Handle Use Case
class GetProductByHandleUsecase implements Usecase<ProductEntity, GetProductByHandleParams> {
  final ProductRepository repository;

  GetProductByHandleUsecase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(GetProductByHandleParams params) async {
    return await repository.getProductByHandle(params.handle);
  }
}

/// Parameters for GetProductByHandleUsecase
class GetProductByHandleParams extends Equatable {
  final String handle;

  const GetProductByHandleParams({required this.handle});

  @override
  List<Object?> get props => [handle];
}

