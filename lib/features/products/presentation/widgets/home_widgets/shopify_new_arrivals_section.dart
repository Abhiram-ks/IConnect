
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/widgets/shopify_product_grid_section.dart';

/// New Arrivals Section - Displays real Shopify products
class ShopifyNewArrivalsSection extends StatefulWidget {
  final String title;
  final VoidCallback? onViewAll;
  final int productCount;

  const ShopifyNewArrivalsSection({
    super.key,
    this.title = 'New Arrivals',
    this.onViewAll,
    this.productCount = 10,
  });

  @override
  State<ShopifyNewArrivalsSection> createState() => _ShopifyNewArrivalsSectionState();
}

class _ShopifyNewArrivalsSectionState extends State<ShopifyNewArrivalsSection> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(
          LoadProductsRequested(first: widget.productCount),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (widget.onViewAll != null)
                TextButton(
                  onPressed: widget.onViewAll,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppPalette.blueColor,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Horizontal product list with real Shopify data
        SizedBox(
          height: 240.h,
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state.products.status == Status.loading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppPalette.blueColor,
                  ),
                );
              }

              if (state.products.status == Status.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
                      SizedBox(height: 8.h),
                      Text(
                        'Failed to load products',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProductBloc>().add(
                                LoadProductsRequested(first: widget.productCount),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.blueColor,
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state.products.status == Status.completed) {
                final products = state.products.data ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No products available',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: SizedBox(
                        width: 160.w,
                        child: ShopifyGridProductCard(product: product),
                      ),
                    );
                  },
                );
              }

              return SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}