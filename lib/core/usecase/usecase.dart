import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';

/// Abstract Usecase class
/// Type: Return type
/// Params: Parameters needed for the use case
abstract class Usecase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// No Params class for use cases that don't need parameters
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

