import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/models/cart_item.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
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
                  decoration: BoxDecoration(color: AppPalette.whiteColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shopping Cart',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<CartCubit>().closeCartDrawer();
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
                  child:
                      state.items.isEmpty
                          ? const Center(
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
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return CartDrawerItem(cartItem: item);
                            },
                          ),
                ),

                if (state.items.isNotEmpty) ...[
                  Container(
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
                              'QAR ${state.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight:FontWeight.bold,
                                color: AppPalette.blackColor,
                              ),
                            ),
                          ],
                        ),
                        ConstantWidgets.hight20(context),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.blackColor,
                              foregroundColor: AppPalette.whiteColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Check out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class CartDrawerItem extends StatelessWidget {
  final CartItem cartItem;

  const CartDrawerItem({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Padding(
              padding: const EdgeInsets.all(8),
               child: Image.network(cartItem.imageUrl, fit: BoxFit.contain,)),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  cartItem.description,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),ConstantWidgets.hight10(context),
                Text(
                  'QAR ${cartItem.discountedPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.blackColor,
                  ),
                ),ConstantWidgets.hight10(context),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppPalette.hintColor.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              context.read<CartCubit>().decrementQuantity(cartItem.id);
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
                            onPressed: () {
                              context.read<CartCubit>().incrementQuantity(cartItem.id);
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 14,
                              color: AppPalette.blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),ConstantWidgets.width20(context),
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
    );
  }
}
