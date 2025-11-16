import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/widgets/image_scrolling_widget.dart';

/// Banner Section Widget - Displays dynamic banners from Shopify collections
class BannerSection extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  const BannerSection({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Show loading indicator while fetching
        if (state.banners.status == Status.loading) {
          return Container(
            height: 200.h,
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(color: AppPalette.blueColor),
            ),
          );
        }

        // Only show banners if we have valid images from Shopify
        if (state.banners.status == Status.completed) {
          final banners = state.banners.data ?? [];

          // Filter banners with valid image URLs and extract them
          final bannerImages =
              banners
                  .where((b) => b.imageUrl != null && b.imageUrl!.isNotEmpty)
                  .map((b) => b.imageUrl!)
                  .toList();

          // Only show if we have valid images
          if (bannerImages.isNotEmpty) {
            return GestureDetector(
              onTap: () {
                // Navigate to first collection with image when banner is tapped
                final bannersWithImages =
                    banners
                        .where(
                          (b) => b.imageUrl != null && b.imageUrl!.isNotEmpty,
                        )
                        .toList();

                if (bannersWithImages.isNotEmpty) {
                  final firstBanner = bannersWithImages[0];
                  Navigator.pushNamed(
                    context,
                    '/banner_details',
                    arguments: {
                      'bannerTitle': firstBanner.title,
                      'collectionHandle': firstBanner.handle,
                    },
                  );
                }
              },
              child: ImageScrollingWidget(
                imageList: bannerImages,
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                show: true,
              ),
            );
          }
        }

        // Don't show anything if no banners or error
        return SizedBox.shrink();
      },
    );
  }
}
