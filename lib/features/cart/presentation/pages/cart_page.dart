import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/features/cart/domain/entities/cart_item_entity.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.whiteColor,
      appBar: AppBar(
        backgroundColor: AppPalette.whiteColor,
        elevation: 0,
        title: const Text(
          'Cart',
          style: TextStyle(
            color: AppPalette.blackColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            bloc: sl<CartCubit>(),
            builder: (context, state) {
              if (state is CartLoaded && state.cart.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Cart'),
                        content: const Text(
                            'Are you sure you want to clear all items from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              sl<CartCubit>().clearCart();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: AppPalette.redColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: AppPalette.redColor),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        bloc: sl<CartCubit>(),
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    if (state is CartLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppPalette.blueColor,
        ),
      );
    }

    if (state is CartEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: AppPalette.hintColor,
            ),
            SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppPalette.hintColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add some products to get started!',
              style: TextStyle(
                fontSize: 14,
                color: AppPalette.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    if (state is CartError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: AppPalette.redColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading cart',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.blackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppPalette.hintColor,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  sl<CartCubit>().loadCart();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.blueColor,
                  foregroundColor: AppPalette.whiteColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is CartLoaded || state is CartOperationInProgress) {
      final cart = state is CartLoaded
          ? state.cart
          : (state as CartOperationInProgress).currentCart;
      final isLoading = state is CartOperationInProgress;

      return Column(
        children: [
          // Cart items list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return CartItemCard(
                  cartItem: item,
                  isLoading: isLoading,
                );
              },
            ),
          ),

          // Cart summary and checkout
          _buildCartSummary(context, cart, isLoading),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCartSummary(BuildContext context, cart, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Item count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Items',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppPalette.hintColor,
                  ),
                ),
                Text(
                  '${cart.itemCount}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.blackColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.blackColor,
                  ),
                ),
                Text(
                  'QAR ${cart.subtotalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.blackColor,
                  ),
                ),
              ],
            ),

            // Savings if any
            if (cart.totalSavings > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'You Save',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'QAR ${cart.totalSavings.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final checkoutUrl = cart.webUrl;
                        if (checkoutUrl != null) {
                          final uri = Uri.parse(checkoutUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open checkout'),
                                  backgroundColor: AppPalette.redColor,
                                ),
                              );
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.blueColor,
                  foregroundColor: AppPalette.whiteColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor:
                      AppPalette.hintColor.withValues(alpha: 0.3),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItemEntity cartItem;
  final bool isLoading;

  const CartItemCard({
    super.key,
    required this.cartItem,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.6 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: AppPalette.hintColor.withValues(alpha: 0.1),
              child: cartItem.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: cartItem.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppPalette.blueColor,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image_outlined,
                        color: AppPalette.hintColor,
                        size: 40,
                      ),
                    )
                  : const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppPalette.hintColor,
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.productTitle ?? cartItem.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.blackColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (cartItem.productTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    cartItem.title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppPalette.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),

                // Price
                Row(
                  children: [
                    Text(
                      'QAR ${cartItem.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.blueColor,
                      ),
                    ),
                    if (cartItem.compareAtPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'QAR ${cartItem.compareAtPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                          color: AppPalette.hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Quantity controls and remove button
                Row(
                  children: [
                    // Quantity controls
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppPalette.hintColor.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    sl<CartCubit>()
                                        .decrementQuantity(cartItem.id);
                                  },
                            icon: const Icon(Icons.remove, size: 18),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    sl<CartCubit>()
                                        .incrementQuantity(cartItem.id);
                                  },
                            icon: const Icon(Icons.add, size: 18),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Remove button
                    TextButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              sl<CartCubit>().removeFromCart(cartItem.id);
                            },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppPalette.redColor,
                      ),
                      label: const Text(
                        'Remove',
                        style: TextStyle(
                          color: AppPalette.redColor,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

