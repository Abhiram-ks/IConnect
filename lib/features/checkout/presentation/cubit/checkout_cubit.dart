import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());

  void setSingleItemCheckout({required CartItemEntity item}) {
    log(
      'CheckoutCubit.setSingleItemCheckout called with: ${item.productTitle} - ${item.imageUrl}',
    );
    // Preserve user details
    final String email =
        state is CheckoutLoaded ? (state as CheckoutLoaded).email : '';
    final String firstName =
        state is CheckoutLoaded ? (state as CheckoutLoaded).firstName : '';
    final String lastName =
        state is CheckoutLoaded ? (state as CheckoutLoaded).lastName : '';
    final String address =
        state is CheckoutLoaded ? (state as CheckoutLoaded).address : '';
    final String city =
        state is CheckoutLoaded ? (state as CheckoutLoaded).city : '';
    final String whatsappNumber =
        state is CheckoutLoaded ? (state as CheckoutLoaded).whatsappNumber : '';

    // Force a state transition to ensure UI rebuilds completely
    // By emitting a new state independent of previous product data
    emit(
      CheckoutLoaded(
        checkoutType: CheckoutType.buyNow,
        buyNowItem: item,
        // Crucial: explicitely set cartItems to empty for buyNow mode to avoid any bleed over
        cartItems: [],
        key: DateTime.now().toIso8601String(),
        email: email,
        firstName: firstName,
        lastName: lastName,
        address: address,
        city: city,
        whatsappNumber: whatsappNumber,
      ),
    );
  }

  void initCartCheckout({required List<CartItemEntity> items}) {
    // Preserve user details
    final String email =
        state is CheckoutLoaded ? (state as CheckoutLoaded).email : '';
    final String firstName =
        state is CheckoutLoaded ? (state as CheckoutLoaded).firstName : '';
    final String lastName =
        state is CheckoutLoaded ? (state as CheckoutLoaded).lastName : '';
    final String address =
        state is CheckoutLoaded ? (state as CheckoutLoaded).address : '';
    final String city =
        state is CheckoutLoaded ? (state as CheckoutLoaded).city : '';
    final String whatsappNumber =
        state is CheckoutLoaded ? (state as CheckoutLoaded).whatsappNumber : '';

    emit(
      CheckoutLoaded(
        checkoutType: CheckoutType.cart,
        cartItems: items,
        // Preserve buyNowItem? Maybe.
        buyNowItem:
            state is CheckoutLoaded
                ? (state as CheckoutLoaded).buyNowItem
                : null,
        email: email,
        firstName: firstName,
        lastName: lastName,
        address: address,
        city: city,
        whatsappNumber: whatsappNumber,
      ),
    );
  }

  void updateUserDetails({
    String? email,
    String? firstName,
    String? lastName,
    String? address,
    String? city,
    String? whatsappNumber,
  }) {
    if (state is CheckoutLoaded) {
      final currentState = state as CheckoutLoaded;
      emit(
        currentState.copyWith(
          email: email,
          firstName: firstName,
          lastName: lastName,
          address: address,
          city: city,
          whatsappNumber: whatsappNumber,
        ),
      );
    }
  }

  void clearCheckoutData() {
    emit(CheckoutInitial());
  }
}
