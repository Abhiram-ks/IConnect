

  import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app_palette.dart';
import '../../../domain/entities/product_entity.dart';

Widget buildProductDetailsSection(ProductEntity product) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }



  Widget buildPriceSection(ProductEntity product, {ProductVariantEntity? selectedVariant}) {
    final double price = selectedVariant?.price ?? product.minPrice;
    final double? comparePrice = selectedVariant?.compareAtPrice ?? product.compareAtPrice;
    final String currencyCode = selectedVariant?.currencyCode ?? product.currencyCode;

    final bool hasDiscount = (comparePrice != null && comparePrice > price);
    final double? discountPercentage =
        hasDiscount ? ((comparePrice - price) / comparePrice) * 100 : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Text(
            '$currencyCode ${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color:hasDiscount
                      ? AppPalette.redColor
                      : AppPalette.blueColor,
            ),
          ),
          if (comparePrice != null && comparePrice > price)
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Text(
                '$currencyCode ${comparePrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
          if (discountPercentage != null)
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '-${discountPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }