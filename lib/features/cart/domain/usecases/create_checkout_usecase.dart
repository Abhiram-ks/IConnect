import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/cart/domain/entities/cart_entity.dart';
import 'package:iconnect/features/cart/domain/repositories/cart_repository.dart';

/// Create Checkout Use Case
class CreateCheckoutUsecase
    implements Usecase<CartEntity, CreateCheckoutParams> {
  final CartRepository repository;

  CreateCheckoutUsecase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(CreateCheckoutParams params) async {
    return await repository.createCheckout(lineItems: params.lineItems);
  }
}

/// Parameters for CreateCheckoutUsecase
class CreateCheckoutParams extends Equatable {
  final List<CheckoutLineItem> lineItems;

  const CreateCheckoutParams({required this.lineItems});

  @override
  List<Object?> get props => [lineItems];
}

