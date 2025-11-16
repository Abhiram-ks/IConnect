import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/cart/domain/entities/cart_entity.dart';
import 'package:iconnect/features/cart/domain/repositories/cart_repository.dart';

/// Get Checkout Use Case
class GetCheckoutUsecase implements Usecase<CartEntity, GetCheckoutParams> {
  final CartRepository repository;

  GetCheckoutUsecase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(GetCheckoutParams params) async {
    return await repository.getCheckout(params.checkoutId);
  }
}

/// Parameters for GetCheckoutUsecase
class GetCheckoutParams extends Equatable {
  final String checkoutId;

  const GetCheckoutParams({required this.checkoutId});

  @override
  List<Object?> get props => [checkoutId];
}

