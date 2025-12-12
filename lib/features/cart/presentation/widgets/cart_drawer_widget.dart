import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_button.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/features/cart/domain/entities/cart_item_entity.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class CartDrawerWidget extends StatelessWidget {
  const CartDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      bloc: sl<CartCubit>(),
      builder: (context, state) {
        return Drawer(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
          backgroundColor: AppPalette.whiteColor,
          width: MediaQuery.of(context).size.width * 0.85,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppPalette.whiteColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shopping Cart',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          sl<CartCubit>().closeCartDrawer();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppPalette.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart Items
                Expanded(
                  child: _buildCartContent(context, state),
                ),

                // Footer with checkout button
                if (state is CartLoaded && state.cart.isNotEmpty)
                  _buildCartFooter(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartContent(BuildContext context, CartState state) {
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
              size: 64,
              color: AppPalette.hintColor,
            ),
            SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 16,
                color: AppPalette.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    if (state is CartError) {
      return Center(
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
      );
    }

    if (state is CartLoaded || state is CartOperationInProgress) {
      final cart = state is CartLoaded 
          ? state.cart 
          : (state as CartOperationInProgress).currentCart;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];
          return CartDrawerItemWidget(
            cartItem: item,
            isLoading: state is CartOperationInProgress,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCartFooter(BuildContext context, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppPalette.whiteColor,
        border: Border(
          top: BorderSide(
            color: AppPalette.hintColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppPalette.blackColor,
                ),
              ),
              Text(
                'QAR ${state.cart.subtotalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppPalette.blackColor,
                ),
              ),
            ],
          ),
          ConstantWidgets.hight20(context),
          CustomButton(text: 'CHECK OUT', onPressed: () async {
                final checkoutUrl = state.cart.webUrl;
                if (checkoutUrl != null) {
                  final uri = Uri.parse(checkoutUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ButtomNavCubit>().selectItem(
                    NavItem.cart,
                  );
            },
            child: const Text(
              'View Cart',
              style: TextStyle(
                color: AppPalette.blackColor,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationThickness: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartDrawerItemWidget extends StatelessWidget {
  final CartItemEntity cartItem;
  final bool isLoading;

  const CartDrawerItemWidget({
    super.key,
    required this.cartItem,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppPalette.hintColor.withValues(alpha: 0.3),
              ),
              child: cartItem.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: cartItem.imageUrl!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cartItem.productTitle != null)
                    Text(
                      cartItem.title,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ConstantWidgets.hight10(context),
                  Row(
                    children: [
                      Text(
                        'QAR ${cartItem.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.blackColor,
                        ),
                      ),
                      if (cartItem.compareAtPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'QAR ${cartItem.compareAtPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: AppPalette.hintColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                  ConstantWidgets.hight10(context),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppPalette.hintColor.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(50),
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
                              icon: const Icon(
                                Icons.remove,
                                size: 14,
                                color: AppPalette.blackColor,
                              ),
                            ),
                            Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppPalette.blackColor,
                              ),
                            ),
                            IconButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      sl<CartCubit>()
                                          .incrementQuantity(cartItem.id);
                                    },
                              icon: const Icon(
                                Icons.add,
                                size: 14,
                                color: AppPalette.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ConstantWidgets.width20(context),
                      TextButton(
                        onPressed: isLoading
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
                            fontSize: 12,
                            color: AppPalette.greyColor,
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
      ),
    );
  }
}

