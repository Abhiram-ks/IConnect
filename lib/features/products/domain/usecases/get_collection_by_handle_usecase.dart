import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';

/// Get Collection By Handle Use Case
class GetCollectionByHandleUsecase implements Usecase<CollectionWithProducts, GetCollectionByHandleParams> {
  final ProductRepository repository;

  GetCollectionByHandleUsecase(this.repository);

  @override
  Future<Either<Failure, CollectionWithProducts>> call(GetCollectionByHandleParams params) async {
    return await repository.getCollectionByHandle(
      handle: params.handle,
      first: params.first,
    );
  }
}

/// Parameters for GetCollectionByHandleUsecase
class GetCollectionByHandleParams extends Equatable {
  final String handle;
  final int first;

  const GetCollectionByHandleParams({
    required this.handle,
    this.first = 20,
  });

  @override
  List<Object?> get props => [handle, first];
}

