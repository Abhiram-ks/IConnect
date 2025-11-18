  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/features/products/presentation/pages/brand_details_page.dart';

import '../../../../../app_palette.dart';
import '../../../../../core/utils/api_response.dart';
import '../../../../../widgets/shopify_product_grid_section.dart';
import '../../bloc/product_bloc.dart' as products;
import '../../bloc/product_event.dart';

Widget buildBrandProductsSection(BuildContext context, BrandDetailsPage widget) {
    return BlocBuilder<products.ProductBloc, products.ProductState>(
      builder: (context, state) {
        // Loading state
        if (state.brandProducts.status == Status.loading) {
          return Container(
            padding: EdgeInsets.all(24.w),
            child: Center(
              child: CircularProgressIndicator(color: AppPalette.blueColor),
            ),
          );
        }
        if (state.brandProducts.status == Status.error) {
          return Container(
            padding: EdgeInsets.all(24.w),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: AppPalette.redColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading products',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.brandProducts.message ?? 'Unknown error',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<products.ProductBloc>().add(
                        LoadBrandProductsRequested(
                          vendor: widget.brandVendor,
                          first: 20,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.blueColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Success state
        if (state.brandProducts.status == Status.completed) {
          final products = state.brandProducts.data ?? [];

          if (products.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No products available',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Check back later for ${widget.brandName} products',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.brandName} Products',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.blueColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        '${products.length} items',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppPalette.blueColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ShopifyGridProductCard(product: product);
                  },
                ),
              ],
            ),
          );
        }

        // Initial state
        return const SizedBox.shrink();
      },
    );
  }