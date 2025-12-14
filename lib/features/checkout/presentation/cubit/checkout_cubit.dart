import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../../services/graphql_base_service.dart';
import '../../../../core/storage/secure_storage_service.dart';

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
  ///
  /// This method automatically retrieves user details from secure storage if logged in
  /// and passes them to Shopify for a seamless checkout experience:
  /// - Email and phone for prefilling
  /// - Customer access token to maintain logged-in state in checkout webview
  /// - Default address for delivery prefilling
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

      // Initialize buyer identity map
      Map<String, dynamic>? buyerIdentity;
      Map<String, dynamic>? deliveryPreferences;
      String? accessToken;

      // Get user details from secure storage if logged in
      String? userEmail = email;
      final isLoggedIn = await SecureStorageService.isLoggedIn();

      if (isLoggedIn) {
        try {
          accessToken = await SecureStorageService.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            // Fetch customer profile
            final customerData = await _graphQLService.getCustomer(
              customerAccessToken: accessToken,
            );

            final customer = customerData['customer'];
            if (customer != null) {
              // Extract customer details
              userEmail = customer['email'] as String?;
              final phone = customer['phone'] as String?;
              final defaultAddress = customer['defaultAddress'];

              log('Retrieved user details from profile:');
              log('Email: $userEmail');
              log('Phone: $phone');
              log('Has default address: ${defaultAddress != null}');

              // Build buyer identity with all available information
              buyerIdentity = {
                if (userEmail != null && userEmail.isNotEmpty)
                  'email': userEmail,
                if (phone != null && phone.isNotEmpty) 'phone': phone,
                // CRITICAL: Include customerAccessToken to maintain login state in checkout
                'customerAccessToken': accessToken,
              };

              // Build delivery preferences if default address exists
              if (defaultAddress != null) {
                deliveryPreferences = {
                  'deliveryAddress': {
                    if (defaultAddress['address1'] != null)
                      'address1': defaultAddress['address1'],
                    if (defaultAddress['address2'] != null)
                      'address2': defaultAddress['address2'],
                    if (defaultAddress['city'] != null)
                      'city': defaultAddress['city'],
                    if (defaultAddress['province'] != null)
                      'province': defaultAddress['province'],
                    if (defaultAddress['zip'] != null)
                      'zip': defaultAddress['zip'],
                    if (defaultAddress['country'] != null)
                      'country': defaultAddress['country'],
                  },
                };
              }
            }
          }
        } catch (e) {
          log('Failed to retrieve user details: $e');
          // Continue with just email if profile retrieval fails
          if (userEmail != null && userEmail.isNotEmpty) {
            buyerIdentity = {'email': userEmail};
          }
        }
      } else if (userEmail != null && userEmail.isNotEmpty) {
        // Guest checkout with provided email
        buyerIdentity = {'email': userEmail};
      }

      // Prepare cart lines for Shopify Cart API
      final lines =
          items.map((item) {
            return {'merchandiseId': item.variantId, 'quantity': item.quantity};
          }).toList();

      log('Creating cart with ${lines.length} items');
      log('Buyer identity: $buyerIdentity');
      log('Delivery preferences: $deliveryPreferences');

      // Call GraphQL service to create cart with full buyer information
      final response = await _graphQLService.createCart(
        lines: lines,
        buyerIdentity: buyerIdentity,
        deliveryAddressPreferences: deliveryPreferences,
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
      log(
        'Customer Access Token: ${accessToken != null ? "Present" : "Not present"}',
      );

      emit(
        CheckoutCreated(
          checkoutId: cartId,
          webUrl: checkoutUrl,
          customerAccessToken: accessToken,
        ),
      );
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
