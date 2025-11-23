import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/api_response.dart';
import '../../../../../widgets/shopify_product_grid_section.dart';
import '../../bloc/product_bloc.dart';
import '../../bloc/product_event.dart';

class YouMayAlsoLikeSection extends StatefulWidget {
  final String productId;

  const YouMayAlsoLikeSection({Key? key, required this.productId})
    : super(key: key);

  @override
  State<YouMayAlsoLikeSection> createState() => _YouMayAlsoLikeSectionState();
}

class _YouMayAlsoLikeSectionState extends State<YouMayAlsoLikeSection> {
  @override
  void initState() {
    super.initState();
    // Trigger loading recommended products only once when widget is initialized
    context.read<ProductBloc>().add(
      LoadProductRecommendationsRequested(productId: widget.productId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Show loading indicator
        if (state.recommendedProducts.status == Status.loading) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Hide section if error or no products
        if (state.recommendedProducts.status != Status.completed ||
            state.recommendedProducts.data == null ||
            state.recommendedProducts.data!.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'You Might Also Like',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(
              height: 260.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: state.recommendedProducts.data?.length ?? 0,
                itemBuilder: (context, index) {
                  final product = state.recommendedProducts.data?[index];
                  if (product == null) {
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: SizedBox(
                      width: 160.w,
                      child: ShopifyGridProductCard(product: product),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Keep the old function for backward compatibility but make it use the new widget
Widget buildYouMayAlsoLikeSection(BuildContext context, String productId) {
  return YouMayAlsoLikeSection(productId: productId);
}
