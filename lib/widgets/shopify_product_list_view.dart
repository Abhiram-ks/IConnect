import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/widgets/shopify_product_card.dart';

/// Shopify Product List View - Grid or List view with real Shopify products
///
/// Usage in Product Screen:
/// ```dart
/// ShopifyProductListView(
///   isGridView: true,  // or false for list view
/// )
/// ```
class ShopifyProductListView extends StatefulWidget {
  final bool isGridView;
  final int productCount;

  const ShopifyProductListView({
    super.key,
    required this.isGridView,
    this.productCount = 20,
  });

  @override
  State<ShopifyProductListView> createState() => _ShopifyProductListViewState();
}

class _ShopifyProductListViewState extends State<ShopifyProductListView> {
  @override
  void initState() {
    super.initState();
    // Load products from Shopify
    context.read<ProductBloc>().add(
      LoadProductsRequested(first: widget.productCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Loading State
        if (state.products.status == Status.loading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppPalette.blueColor),
                SizedBox(height: 16.h),
                Text(
                  'Loading products from Shopify...',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Error State
        if (state.products.status == Status.error) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load products',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.products.message ?? 'Unknown error',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ProductBloc>().add(
                        LoadProductsRequested(first: widget.productCount),
                      );
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.blueColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Products Loaded State
        if (state.products.status == Status.completed) {
          final products = state.products.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No products available',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Grid View
          if (widget.isGridView) {
            return GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ShopifyProductCard(
                  product: products[index],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/product_details',
                      arguments: {'productHandle': products[index].handle},
                    );
                  },
                );
              },
            );
          }

          // List View
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/product_details',
                      arguments: {'productHandle': product.handle},
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: CachedNetworkImage(
                            imageUrl:
                                product.featuredImage ?? product.images.first,
                            width: 80.w,
                            height: 80.h,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppPalette.blueColor,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  width: 80.w,
                                  height: 80.h,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.image, color: Colors.grey),
                                ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                product.description,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Text(
                                    '${product.currencyCode} ${product.minPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppPalette.blueColor,
                                    ),
                                  ),
                                  if (product.hasDiscount &&
                                      product.compareAtPrice != null) ...[
                                    SizedBox(width: 8.w),
                                    Text(
                                      '${product.currencyCode} ${product.compareAtPrice!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (!product.availableForSale)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Text(
                                    'SOLD OUT',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Discount Badge
                        if (product.hasDiscount)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '-${product.discountPercentage?.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        return Center(
          child: Text(
            'No products loaded',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        );
      },
    );
  }
}
