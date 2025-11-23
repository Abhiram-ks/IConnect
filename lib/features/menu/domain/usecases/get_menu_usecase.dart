import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

/// Use case for getting menu by handle
class GetMenuUseCase implements Usecase<MenuEntity, GetMenuParams> {
  final MenuRepository repository;

  GetMenuUseCase({required this.repository});

  @override
  Future<Either<Failure, MenuEntity>> call(GetMenuParams params) async {
    return await repository.getMenuByHandle(params.handle);
  }
}

/// Parameters for GetMenuUseCase
class GetMenuParams extends Equatable {
  final String handle;

  const GetMenuParams({required this.handle});

  @override
  List<Object?> get props => [handle];
}

