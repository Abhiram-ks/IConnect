


  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/api_response.dart';
import '../../../../../widgets/shopify_product_grid_section.dart';
import '../../bloc/product_bloc.dart';

Widget buildYouMayAlsoLikeSection() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.products.status != Status.completed) {
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
                itemCount: state.products.data?.length ?? 0,
                itemBuilder: (context, index) {
                  final product = state.products.data?[index];
                  if (product == null) {
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: SizedBox(
                        width: 160.w,
                        child: ShopifyGridProductCard(product: product),
                      )
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
