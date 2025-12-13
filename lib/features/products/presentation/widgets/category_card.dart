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

    // Consistent text style for all titles
    final titleStyle = TextStyle(
      color: Colors.black,
      fontSize: 8.sp,
      fontWeight: FontWeight.w600,
    );

    // Helper widget for showing avatar with title
    Widget _buildAvatarCard({bool showTitleBelow = true}) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppPalette.blueColor.withOpacity(0.1),
            backgroundImage: hasValidImage ? NetworkImage(imageUrl) : null,
            child:
                !hasValidImage
                    ? Text(
                      title.isNotEmpty ? title[0].toUpperCase() : 'N/A',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.blueColor,
                      ),
                    )
                    : null,
          ),
          if (showTitleBelow) ...[
            SizedBox(height: 8.h),
            SizedBox(
              width: 60.w,
              child: Text(
                title,
                style: titleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      );
    }

    // If no valid image, show circular avatar with title
    if (!hasValidImage) {
      return GestureDetector(
        onTap: onTap,
        child: _buildAvatarCard(showTitleBelow: true),
      );
    }

    // All categories now have the same layout: image in CircleAvatar with title below
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppPalette.blueColor.withOpacity(0.1),
            backgroundImage: NetworkImage(imageUrl),
            child: null,
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 60.w,
            child: Text(
              title,
              style: titleStyle,
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
