import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/products/domain/entities/offer_entity.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';

/// Get Offer Blocks Use Case
class GetOfferBlocksUsecase
    implements Usecase<List<OfferBlockEntity>, GetOfferBlocksParams> {
  final ProductRepository repository;

  GetOfferBlocksUsecase(this.repository);

  @override
  Future<Either<Failure, List<OfferBlockEntity>>> call(
    GetOfferBlocksParams params,
  ) async {
    return await repository.getOfferBlocks();
  }
}

/// Parameters for GetOfferBlocksUsecase
class GetOfferBlocksParams extends Equatable {
  const GetOfferBlocksParams();

  @override
  List<Object?> get props => [];
}

