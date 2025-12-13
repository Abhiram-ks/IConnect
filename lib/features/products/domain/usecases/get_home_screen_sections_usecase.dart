import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/products/domain/entities/home_screen_entity.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';

/// Get Home Screen Sections Use Case
class GetHomeScreenSectionsUsecase
    implements
        Usecase<List<HomeScreenSectionEntity>, GetHomeScreenSectionsParams> {
  final ProductRepository repository;

  GetHomeScreenSectionsUsecase(this.repository);

  @override
  Future<Either<Failure, List<HomeScreenSectionEntity>>> call(
    GetHomeScreenSectionsParams params,
  ) async {
    return await repository.getHomeScreenSections();
  }
}

/// Parameters for GetHomeScreenSectionsUsecase
class GetHomeScreenSectionsParams extends Equatable {
  const GetHomeScreenSectionsParams();

  @override
  List<Object?> get props => [];
}
