import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/features/products/domain/entities/home_screen_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget for displaying horizontal banners
class HorizontalBannersSection extends StatelessWidget {
  final List<BannerItemEntity> banners;
  final Function(BannerItemEntity) onBannerTap;

  const HorizontalBannersSection({
    super.key,
    required this.banners,
    required this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return GestureDetector(
            onTap: () => onBannerTap(banner),
            child: Container(
              width: 320.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: banner.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: banner.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image, size: 50),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget for displaying vertical banners
class VerticalBannersSection extends StatelessWidget {
  final List<BannerItemEntity> banners;
  final Function(BannerItemEntity) onBannerTap;

  const VerticalBannersSection({
    super.key,
    required this.banners,
    required this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        children: banners.map((banner) {
          return GestureDetector(
            onTap: () => onBannerTap(banner),
            child: Container(
              width: screenWidth - 16.w, // Full width minus padding
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: banner.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: banner.imageUrl!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => SizedBox(
                          height: 200.h,
                          child: Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => SizedBox(
                          height: 200.h,
                          child: Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 200.h,
                        child: Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image, size: 50),
                          ),
                        ),
                      ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

