import 'package:dartz/dartz.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/features/profile/domain/entities/profile_entity.dart';

/// Abstract Profile Repository Interface
abstract class ProfileRepository {
  /// Get customer profile
  Future<Either<Failure, ProfileEntity>> getProfile();
}

