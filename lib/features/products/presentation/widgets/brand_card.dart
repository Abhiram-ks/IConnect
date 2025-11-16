import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';

class BrandCard extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const BrandCard({super.key, required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Image.network(
          imageUrl,
          width: 100.w,
          height: 21.h,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 100.w,
              height: 20.h,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppPalette.blueColor,
                  strokeWidth: 2,
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              width: 100.w,
              height: 20.h,
              child: Icon(
                CupertinoIcons.photo,
                color: AppPalette.greyColor,
                size: 20.sp,
              ),
            );
          },
        ),
      ),
    );
  }
}
