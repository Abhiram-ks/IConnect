import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/models/cart_item.dart';
import 'package:iconnect/widgets/new_arrivals_section.dart';

class DetailedCartScreen extends StatelessWidget {
  const DetailedCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
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
                    style: TextStyle(fontSize: 18, color: AppPalette.hintColor),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Title and Breadcrumb
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      ConstantWidgets.hight10(context),
                      const Text(
                        'Home > Your Shopping Cart',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppPalette.blackColor,
                        ),
                      ),
                      ConstantWidgets.hight30(context),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Product',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppPalette.blackColor,
                            ),
                          ),
                          const Text(
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
                  ),
                ),

                // Cart Items
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return DetailedCartItem(cartItem: item);
                  },
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppPalette.whiteColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtotal - positioned to the left with proper alignment
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
                            'QAR ${state.subtotal.toStringAsFixed(2)}',
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.blackColor,
                            foregroundColor: AppPalette.whiteColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'CHECK OUT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Recently Viewed Products
                      NewArrivalsSection(
                        title: 'Recently Viewed Products',
                        products: NewArrivalsData.getNewArrivalsProducts(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DetailedCartItem extends StatelessWidget {
  final CartItem cartItem;

  const DetailedCartItem({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(cartItem.imageUrl),
              ),
            ),
            ConstantWidgets.width20(context),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppPalette.blackColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    cartItem.description,
                    style: const TextStyle(color: AppPalette.blackColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ConstantWidgets.hight10(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '-White',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppPalette.blackColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'QAR ${cartItem.discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppPalette.blackColor,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<CartCubit>().removeFromCart(cartItem.id);
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
                  ConstantWidgets.hight10(context),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppPalette.hintColor.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.read<CartCubit>().decrementQuantity(
                              cartItem.id,
                            );
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: AppPalette.blackColor,
                            size: 16,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppPalette.hintColor.withValues(
                              alpha: 0.3,
                            ),
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
                          onPressed: () {
                            context.read<CartCubit>().incrementQuantity(
                              cartItem.id,
                            );
                          },
                          icon: const Icon(
                            Icons.add,
                            color: AppPalette.blackColor,
                            size: 16,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppPalette.hintColor.withValues(
                              alpha: 0.3,
                            ),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(24, 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(color: AppPalette.hintColor),
      ],
    );
  }
}
