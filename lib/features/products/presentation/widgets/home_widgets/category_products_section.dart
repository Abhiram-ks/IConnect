import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/widgets/shopify_product_grid_section.dart';

/// Category Products Section - Displays products filtered by category
/// with horizontal scrolling support
class CategoryProductsSection extends StatefulWidget {
  final String categoryName;
  final String collectionHandle;
  final int initialProductCount;

  const CategoryProductsSection({
    super.key,
    required this.categoryName,
    required this.collectionHandle,
    this.initialProductCount = 10,
  });

  @override
  State<CategoryProductsSection> createState() =>
      _CategoryProductsSectionState();
}

class _CategoryProductsSectionState extends State<CategoryProductsSection> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Load initial products for this category
    context.read<ProductBloc>().add(
      LoadCategoryProductsRequested(
        categoryName: widget.categoryName,
        collectionHandle: widget.collectionHandle,
        first: widget.initialProductCount,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            widget.categoryName,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Horizontal product list with pagination
        SizedBox(
          height: 240.h,
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              final categoryData = state.categoryProducts[widget.categoryName];

              if (categoryData == null ||
                  categoryData.products.status == Status.initial) {
                return Center(
                  child: CircularProgressIndicator(color: AppPalette.blueColor),
                );
              }

              if (categoryData.products.status == Status.loading) {
                return Center(
                  child: CircularProgressIndicator(color: AppPalette.blueColor),
                );
              }

              if (categoryData.products.status == Status.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
                      SizedBox(height: 8.h),
                      Text(
                        'Failed to load products',
                        style: TextStyle(fontSize: 14.sp, color: Colors.red),
                      ),
                      SizedBox(height: 8.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProductBloc>().add(
                            LoadCategoryProductsRequested(
                              categoryName: widget.categoryName,
                              collectionHandle: widget.collectionHandle,
                              first: widget.initialProductCount,
                            ),
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

              if (categoryData.products.status == Status.completed) {
                final products = categoryData.products.data ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No products available',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
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
