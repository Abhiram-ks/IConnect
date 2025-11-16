import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/cart/domain/entities/cart_entity.dart';
import 'package:iconnect/features/cart/domain/repositories/cart_repository.dart';

/// Add Line Items Use Case
class AddLineItemsUsecase implements Usecase<CartEntity, AddLineItemsParams> {
  final CartRepository repository;

  AddLineItemsUsecase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(AddLineItemsParams params) async {
    return await repository.addLineItems(
      checkoutId: params.checkoutId,
      lineItems: params.lineItems,
    );
  }
}

/// Parameters for AddLineItemsUsecase
class AddLineItemsParams extends Equatable {
  final String checkoutId;
  final List<CheckoutLineItem> lineItems;

  const AddLineItemsParams({
    required this.checkoutId,
    required this.lineItems,
  });

  @override
  List<Object?> get props => [checkoutId, lineItems];
}

