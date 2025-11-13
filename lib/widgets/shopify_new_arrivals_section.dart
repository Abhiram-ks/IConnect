import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/bloc/product_state.dart';

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
    // Load real products from Shopify
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
              if (state is ProductLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppPalette.blueColor,
                  ),
                );
              }

              if (state is ProductError) {
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

              if (state is ProductsLoaded) {
                final products = state.products;

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
                      child: _ShopifyProductCard(product: product),
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

/// Product Card for displaying Shopify products in horizontal list
class _ShopifyProductCard extends StatelessWidget {
  final ProductEntity product;

  const _ShopifyProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product_details',
          arguments: {'productHandle': product.handle},
        );
      },
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: CachedNetworkImage(
                    imageUrl: product.featuredImage ?? product.images.first,
                    height: 140.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppPalette.blueColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40.sp,
                      ),
                    ),
                  ),
                ),
                // Discount Badge
                if (product.hasDiscount)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '-${product.discountPercentage?.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Out of Stock Badge
                if (!product.availableForSale)
                  Positioned(
                    bottom: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'SOLD OUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Spacer(),
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discounted Price
                        Text(
                          '${product.currencyCode} ${product.minPrice.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.blueColor,
                          ),
                        ),
                        // Original Price (if discount exists)
                        if (product.hasDiscount && product.compareAtPrice != null)
                          Text(
                            '${product.currencyCode} ${product.compareAtPrice!.toStringAsFixed(2)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

