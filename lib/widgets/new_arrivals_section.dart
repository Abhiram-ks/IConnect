import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/widgets/product_card.dart';
import 'package:iconnect/widgets/product_preview_modal.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/models/cart_item.dart';

/// A horizontal product section with a header
/// Shows products like "New Arrivals" with a title and horizontal scrolling
class NewArrivalsSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> products;
  final VoidCallback? onViewAll;

  const NewArrivalsSection({
    super.key,
    required this.title,
    required this.products,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and "View All" button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
        ),
        
        // Horizontal product list
        SizedBox(
          height: 230.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) {
                    final isInCart = cartState.items.any((item) => item.id == product['id']);
                    return ProductCard(
                      imageUrl: product['imageUrl'] as String,
                      productName: product['productName'] as String,
                      description: product['description'] as String,
                      originalPrice: product['originalPrice'] as double,
                      discountedPrice: product['discountedPrice'] as double,
                      productId: product['id'] as int,
                      offerText: product['offerText'] as String?,
                      isInCart: isInCart,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product_details',
                          arguments: {'productId': product['id']},
                        );
                      },
                      onAddToCart: () {
                        final cartItem = CartItem(
                          id: product['id'] as int,
                          imageUrl: product['imageUrl'] as String,
                          productName: product['productName'] as String,
                          description: product['description'] as String,
                          originalPrice: product['originalPrice'] as double,
                          discountedPrice: product['discountedPrice'] as double,
                          offerText: product['offerText'] as String?,
                        );
                        context.read<CartCubit>().addToCart(cartItem);
                        
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product['productName']} added to cart'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppPalette.blueColor,
                          ),
                        );
                      },
                      onView: () {
                        showDialog(
                          context: context,
                          builder: (context) => ProductPreviewModal(
                            product: product,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

