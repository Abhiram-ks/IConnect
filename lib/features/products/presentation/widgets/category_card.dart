import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';

/// Category Card Widget - Displays category image
class CategoryCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Parse URL to check path extension, ignoring query parameters
    bool showTitle = false;
    try {
      final uri = Uri.parse(imageUrl);
      final path = uri.path.toLowerCase();
      showTitle = path.endsWith('.webp');
    } catch (e) {
      // If URL parsing fails, fallback to simple string check
      showTitle = imageUrl.toLowerCase().endsWith('.webp');
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60.w,
        height: 60.h,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child:
              showTitle
                  ? Stack(
                    children: [
                      SizedBox(
                        width: 60.w,
                        height: 60.h,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: 60.w,
                          height: 60.h,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 40.w,
                              height: 40.h,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppPalette.blueColor,
                                  strokeWidth: 2,
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              (loadingProgress
                                                      .expectedTotalBytes ??
                                                  1)
                                          : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60.w,
                              height: 60.h,
                              color: Colors.grey[200],
                              child: Icon(
                                CupertinoIcons.photo,
                                color: AppPalette.greyColor,
                                size: 20.sp,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 7.h,
                        left: 0,
                        right: 8.w,
                        child: Container(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )
                  : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    // width: 60.w,
                    // height: 60.h,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 60.w,
                        height: 60.h,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppPalette.blueColor,
                            strokeWidth: 2,
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60.w,
                        height: 60.h,
                        color: Colors.grey[200],
                        child: Icon(
                          CupertinoIcons.photo,
                          color: AppPalette.greyColor,
                          size: 20.sp,
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
