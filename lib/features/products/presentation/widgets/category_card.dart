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
    // Check if image URL is valid (not null, not empty, and not a placeholder)
    final bool hasValidImage =
        imageUrl.isNotEmpty &&
        !imageUrl.contains('placeholder') &&
        !imageUrl.contains('via.placeholder');

    // If no valid image, show circular avatar with title
    if (!hasValidImage) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: AppPalette.blueColor.withOpacity(0.1),
              child: Text(
                title.isNotEmpty ? title[0].toUpperCase() : 'N/A',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.blueColor,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: 60.w,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.blackColor,
                  height: 1.2, // Line height for better spacing
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

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

    // Helper widget for showing avatar with title
    Widget _buildAvatarCard({bool showTitleBelow = true}) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppPalette.blueColor.withOpacity(0.1),
            child: Text(
              title.isNotEmpty ? title[0].toUpperCase() : 'N/A',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.blueColor,
              ),
            ),
          ),
          if (showTitleBelow) ...[
            SizedBox(height: 8.h),
            SizedBox(
              width: 60.w,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.blackColor,
                  height: 1.2, // Line height for better spacing
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child:
          showTitle
              ? SizedBox(
                width: 60.w,
                height: 60.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Stack(
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
                            return _buildAvatarCard(showTitleBelow: false);
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 16.h,
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
                  ),
                ),
              )
              : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60.w,
                    height: 60.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
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
                          return _buildAvatarCard(showTitleBelow: true);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: 60.w,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
    );
  }
}
