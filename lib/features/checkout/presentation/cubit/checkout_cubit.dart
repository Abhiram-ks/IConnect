import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../../services/graphql_base_service.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final ShopifyGraphQLService _graphQLService;

  CheckoutCubit({required ShopifyGraphQLService graphQLService})
    : _graphQLService = graphQLService,
      super(CheckoutInitial());

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

  /// Create Shopify cart and get checkoutUrl (modern Cart API)
  Future<void> createShopifyCheckout({String? email}) async {
    try {
      if (state is! CheckoutLoaded) {
        emit(const CheckoutError(message: 'No checkout data available'));
        return;
      }

      final checkoutState = state as CheckoutLoaded;
      final items = checkoutState.items;

      if (items.isEmpty) {
        emit(const CheckoutError(message: 'No items in checkout'));
        return;
      }

      emit(const CheckoutCreating());

      // Prepare cart lines for Shopify Cart API
      final lines =
          items.map((item) {
            return {'merchandiseId': item.variantId, 'quantity': item.quantity};
          }).toList();

      log('Creating cart with ${lines.length} items');
      log('Email: ${email ?? "not provided"}');

      // Call GraphQL service to create cart
      final response = await _graphQLService.createCart(
        lines: lines,
        buyerIdentity: email,
      );

      log('Cart response: $response');

      // Extract cart data
      final cartData = response['cartCreate']?['cart'];
      if (cartData == null) {
        emit(const CheckoutError(message: 'Failed to create cart'));
        return;
      }

      final cartId = cartData['id'] as String?;
      final checkoutUrl = cartData['checkoutUrl'] as String?;

      if (cartId == null || checkoutUrl == null) {
        emit(const CheckoutError(message: 'Invalid cart response'));
        return;
      }

      log('Cart created successfully!');
      log('Cart ID: $cartId');
      log('Checkout URL: $checkoutUrl');

      emit(CheckoutCreated(checkoutId: cartId, webUrl: checkoutUrl));
    } catch (e) {
      log('Error creating cart: $e');
      emit(CheckoutError(message: 'Failed to create cart: ${e.toString()}'));
    }
  }

  /// Mark checkout as completed
  void markCheckoutCompleted() {
    emit(const CheckoutCompleted());
  }
}
