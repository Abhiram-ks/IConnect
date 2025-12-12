import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_button.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/features/cart/domain/entities/cart_item_entity.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:iconnect/features/checkout/presentation/pages/user_details_screen.dart';
import 'package:iconnect/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:iconnect/common/custom_snackbar.dart';

class DetailedCartScreen extends StatelessWidget {
  const DetailedCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CartCubit, CartState>(
        bloc: sl<CartCubit>(),
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Title and Breadcrumb
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Shopping Cart',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.blackColor,
                        ),
                      ),
                      ConstantWidgets.hight30(context),
                      if (state is CartLoaded ||
                          state is CartOperationInProgress) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Product',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppPalette.blackColor,
                              ),
                            ),
                            Text(
                              'Price',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppPalette.blackColor,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: AppPalette.hintColor),
                      ],
                    ],
                  ),
                ),

                // Cart Content
                _buildCartContent(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartState state) {
    if (state is CartLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: AppPalette.blueColor),
        ),
      );
    }

    if (state is CartEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppPalette.hintColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18, color: AppPalette.hintColor),
              ),
              const SizedBox(height: 24),
              // NewArrivalsSection(
              //   title: 'Recently Viewed Products',
              //   products: NewArrivalsData.getNewArrivalsProducts(),
              // ),
            ],
          ),
        ),
      );
    }

    if (state is CartError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppPalette.redColor,
              ),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppPalette.hintColor,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  sl<CartCubit>().loadCart();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is CartLoaded || state is CartOperationInProgress) {
      final cart =
          state is CartLoaded
              ? state.cart
              : (state as CartOperationInProgress).currentCart;
      final isLoading = state is CartOperationInProgress;

      return Column(
        children: [
          // Cart Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return DetailedCartItem(cartItem: item, isLoading: isLoading);
            },
          ),

          // Cart Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppPalette.whiteColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.blackColor,
                      ),
                    ),
                    Text(
                      'QAR ${cart.subtotalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.blackColor,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Taxes and shipping calculated at checkout',
                  style: TextStyle(fontSize: 12),
                ),
                ConstantWidgets.hight30(context),
                CustomButton(
                  text: 'Check out',
                  onPressed: () {
                    final currentCartState = sl<CartCubit>().state;
                    if (currentCartState is CartLoaded) {
                      sl<CheckoutCubit>().initCartCheckout(
                        items: currentCartState.cart.items,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserDetailsScreen(),
                        ),
                      );
                    } else {
                      CustomSnackBar.show(
                        context,
                        message: 'Please wait for cart to load',
                        textAlign: TextAlign.center,
                        backgroundColor: AppPalette.redColor,
                      );
                    }
                  },

                  borderRadius: 12,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class DetailedCartItem extends StatelessWidget {
  final CartItemEntity cartItem;
  final bool isLoading;

  const DetailedCartItem({
    super.key,
    required this.cartItem,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.6 : 1.0,
      child: Column(
        children: [
          // Product Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppPalette.hintColor.withValues(alpha: 0.3),
                ),
                child:
                    cartItem.imageUrl != null
                        ? CachedNetworkImage(
                          imageUrl: cartItem.imageUrl!,
                          fit: BoxFit.contain,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) =>
                                  const Icon(Icons.broken_image),
                        )
                        : const Icon(Icons.shopping_bag),
              ),
              ConstantWidgets.width20(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.productTitle ?? cartItem.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppPalette.blackColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (cartItem.productTitle != null)
                      Text(
                        cartItem.title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppPalette.blackColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ConstantWidgets.hight10(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price with discount if available
                        Column(
                          children: [
                            if (cartItem.compareAtPrice != null) ...[
                              Text(
                                'QAR ${cartItem.compareAtPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: AppPalette.hintColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              'QAR ${cartItem.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppPalette.blackColor,
                              ),
                            ),
                          ],
                        ),
                        // Total price for this item
                        const SizedBox(width: 8),
                        Text(
                          'QAR ${cartItem.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppPalette.blackColor,
                          ),
                        ),
                      ],
                    ),
                    ConstantWidgets.hight10(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Quantity controls
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppPalette.hintColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () {
                                          sl<CartCubit>().decrementQuantity(
                                            cartItem.id,
                                          );
                                        },
                                icon: const Icon(
                                  Icons.remove,
                                  color: AppPalette.blackColor,
                                  size: 16,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppPalette.hintColor
                                      .withValues(alpha: 0.3),
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(24, 24),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${cartItem.quantity}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () {
                                          sl<CartCubit>().incrementQuantity(
                                            cartItem.id,
                                          );
                                        },
                                icon: const Icon(
                                  Icons.add,
                                  color: AppPalette.blackColor,
                                  size: 16,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppPalette.hintColor
                                      .withValues(alpha: 0.3),
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(24, 24),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Remove button
                        TextButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () {
                                    sl<CartCubit>().removeFromCart(cartItem.id);
                                  },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Remove',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppPalette.blackColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: AppPalette.hintColor),
        ],
      ),
    );
  }
}
