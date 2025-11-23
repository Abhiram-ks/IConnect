import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/menu_entity.dart';

/// Menu Repository Interface
/// Defines contract for menu data operations
abstract class MenuRepository {
  /// Get menu by handle
  /// Returns Either<Failure, MenuEntity>
  Future<Either<Failure, MenuEntity>> getMenuByHandle(String handle);
}

