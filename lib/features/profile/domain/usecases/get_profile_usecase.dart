import 'package:dartz/dartz.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/profile/domain/entities/profile_entity.dart';
import 'package:iconnect/features/profile/domain/repositories/profile_repository.dart';

/// Get Profile Use Case
class GetProfileUsecase implements Usecase<ProfileEntity, NoParams> {
  final ProfileRepository repository;

  GetProfileUsecase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(NoParams params) async {
    return await repository.getProfile();
  }
}
