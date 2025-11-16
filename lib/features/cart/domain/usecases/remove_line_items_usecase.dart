import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:iconnect/core/error/failures.dart';
import 'package:iconnect/core/usecase/usecase.dart';
import 'package:iconnect/features/cart/domain/entities/cart_entity.dart';
import 'package:iconnect/features/cart/domain/repositories/cart_repository.dart';

/// Remove Line Items Use Case
class RemoveLineItemsUsecase
    implements Usecase<CartEntity, RemoveLineItemsParams> {
  final CartRepository repository;

  RemoveLineItemsUsecase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(RemoveLineItemsParams params) async {
    return await repository.removeLineItems(
      checkoutId: params.checkoutId,
      lineItemIds: params.lineItemIds,
    );
  }
}

/// Parameters for RemoveLineItemsUsecase
class RemoveLineItemsParams extends Equatable {
  final String checkoutId;
  final List<String> lineItemIds;

  const RemoveLineItemsParams({
    required this.checkoutId,
    required this.lineItemIds,
  });

  @override
  List<Object?> get props => [checkoutId, lineItemIds];
}

