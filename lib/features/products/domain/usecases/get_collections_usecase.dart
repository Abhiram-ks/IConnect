import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/products/domain/entities/collection_entity.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';

/// Get Collections Use Case
class GetCollectionsUsecase implements Usecase<List<CollectionEntity>, GetCollectionsParams> {
  final ProductRepository repository;

  GetCollectionsUsecase(this.repository);

  @override
  Future<Either<Failure, List<CollectionEntity>>> call(GetCollectionsParams params) async {
    return await repository.getCollections(first: params.first);
  }
}

/// Parameters for GetCollectionsUsecase
class GetCollectionsParams extends Equatable {
  final int first;

  const GetCollectionsParams({this.first = 10});

  @override
  List<Object?> get props => [first];
}

