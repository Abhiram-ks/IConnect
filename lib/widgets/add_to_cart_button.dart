import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/models/cart_item.dart';

class AddToCartButton extends StatelessWidget {
  final int productId;
  final String imageUrl;
  final String productName;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final String? offerText;

  const AddToCartButton({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.productName,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    this.offerText,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cartItem = state.items.firstWhere(
          (item) => item.id == productId,
          orElse: () => CartItem(
            id: productId,
            imageUrl: imageUrl,
            productName: productName,
            description: description,
            originalPrice: originalPrice,
            discountedPrice: discountedPrice,
            offerText: offerText,
          ),
        );

        final isInCart = state.items.any((item) => item.id == productId);

        return Container(
          decoration: BoxDecoration(
            color: AppPalette.blackColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              if (isInCart) {
                context.read<CartCubit>().incrementQuantity(productId);
              } else {
                context.read<CartCubit>().addToCart(cartItem);
              }
              
              // Show snackbar feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isInCart 
                        ? 'Item quantity increased!' 
                        : 'Added to cart!',
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppPalette.greenColor,
                ),
              );
            },
            icon: Icon(
              isInCart ? Icons.add : Icons.shopping_bag_outlined,
              color: AppPalette.whiteColor,
              size: 16.sp,
            ),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(32.w, 32.h),
            ),
          ),
        );
      },
    );
  }
}

class CartQuantityButton extends StatelessWidget {
  final int productId;
  final VoidCallback? onPressed;

  const CartQuantityButton({
    super.key,
    required this.productId,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cartItem = state.items.firstWhere(
          (item) => item.id == productId,
          orElse: () => CartItem(
            id: productId,
            imageUrl: '',
            productName: '',
            description: '',
            originalPrice: 0,
            discountedPrice: 0,
          ),
        );

        final isInCart = state.items.any((item) => item.id == productId);

        if (!isInCart) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: AppPalette.blackColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Text(
              '${cartItem.quantity}',
              style: TextStyle(
                color: AppPalette.whiteColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(32.w, 32.h),
            ),
          ),
        );
      },
    );
  }
}
