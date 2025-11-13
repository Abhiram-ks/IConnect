import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconnect/app_palette.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final String? offerText;
  final int productId;
  final bool isInCart;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onView;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.productId,
    this.offerText,
    this.isInCart = false,
    required this.onTap,
    required this.onAddToCart,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 160.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 165.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppPalette.blueColor,
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 50.sp,
                        ),
                      );
                    },
                  ),
                ),
                

                if (offerText != null)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppPalette.blueColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        offerText!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Icons positioned at bottom center of the image
                Positioned(
                  bottom: 8.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Cart Button
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 32.w,
                            height: 32.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 4.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              FontAwesomeIcons.bagShopping,
                              size: 14.sp,
                              color: isInCart ? AppPalette.blueColor : Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // View Button
                        GestureDetector(
                          onTap: onView,
                          child: Container(
                            width: 32.w,
                            height: 32.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 4.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              FontAwesomeIcons.eye,
                              size: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Product Details Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 3.h),
                  // Pricing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'QAR ${discountedPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines:  1,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      // Original Price (Struck through)
                      Expanded(
                        child: Text(
                          'QAR ${originalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines:  1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
