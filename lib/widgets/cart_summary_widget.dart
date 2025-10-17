import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';

class CartSummaryWidget extends StatelessWidget {
  final VoidCallback? onCheckout;
  final VoidCallback? onEdit;
  final VoidCallback? onShipping;

  const CartSummaryWidget({
    super.key,
    this.onCheckout,
    this.onEdit,
    this.onShipping,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
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
              // Action Icons
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppPalette.hintColor,
                    ),
                  ),
                  IconButton(
                    onPressed: onShipping,
                    icon: const Icon(
                      Icons.local_shipping_outlined,
                      color: AppPalette.hintColor,
                    ),
                  ),
                ],
              ),

              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.blackColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Taxes and shipping calculated at checkout',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppPalette.hintColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'QAR ${state.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.blackColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCheckout,
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
            ],
          ),
        );
      },
    );
  }
}

class CartItemCountBadge extends StatelessWidget {
  final Widget child;

  const CartItemCountBadge({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Stack(
          children: [
            child,
            if (state.itemCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppPalette.redColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${state.itemCount}',
                    style: const TextStyle(
                      color: AppPalette.whiteColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
