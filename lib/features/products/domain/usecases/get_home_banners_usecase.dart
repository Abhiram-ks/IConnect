import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/products/domain/entities/banner_entity.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';

/// Get Home Banners Use Case
class GetHomeBannersUsecase
    implements Usecase<List<BannerEntity>, GetHomeBannersParams> {
  final ProductRepository repository;

  GetHomeBannersUsecase(this.repository);

  @override
  Future<Either<Failure, List<BannerEntity>>> call(
    GetHomeBannersParams params,
  ) async {
    return await repository.getHomeBanners(first: params.first);
  }
}

/// Parameters for GetHomeBannersUsecase
class GetHomeBannersParams extends Equatable {
  final int first;

  const GetHomeBannersParams({this.first = 10});

  @override
  List<Object?> get props => [first];
}

