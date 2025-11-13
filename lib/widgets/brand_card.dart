import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';

class BrandCard extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const BrandCard({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        height: 20.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        child: ClipRRect(
                borderRadius: BorderRadius.circular(25.r),
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
                    return Icon(
                      CupertinoIcons.photo,
                      color: AppPalette.greyColor,
                      size: 20.sp,
                    );
                  },
                ),
              ),
      ),
    );
  }
}
