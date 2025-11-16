import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/cart/domain/entities/cart_entity.dart';
import 'package:iconnect/features/cart/domain/repositories/cart_repository.dart';

/// Update Line Items Use Case
class UpdateLineItemsUsecase
    implements Usecase<CartEntity, UpdateLineItemsParams> {
  final CartRepository repository;

  UpdateLineItemsUsecase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(UpdateLineItemsParams params) async {
    return await repository.updateLineItems(
      checkoutId: params.checkoutId,
      lineItems: params.lineItems,
    );
  }
}

/// Parameters for UpdateLineItemsUsecase
class UpdateLineItemsParams extends Equatable {
  final String checkoutId;
  final List<CheckoutLineItemUpdate> lineItems;

  const UpdateLineItemsParams({
    required this.checkoutId,
    required this.lineItems,
  });

  @override
  List<Object?> get props => [checkoutId, lineItems];
}

