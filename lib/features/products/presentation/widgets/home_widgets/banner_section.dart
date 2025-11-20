import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/widgets/image_scrolling_widget.dart';

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
        if (state.banners.status == Status.loading) {
          return Container(
            height: 200.h,
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(color: AppPalette.blueColor),
            ),
          );
        }

        if (state.banners.status == Status.completed) {
          final banners = state.banners.data ?? [];

          final bannerImages =
              banners
                  .where((b) => (b.imageUrl ?? '').trim().isNotEmpty)
                  .map((b) => b.imageUrl!)
                  .toList();

          if (bannerImages.isNotEmpty) {
            return GestureDetector(
              onTap: () {
                final bannersWithImages =
                    banners
                        .where((b) => (b.imageUrl ?? '').trim().isNotEmpty)
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

        return SizedBox.shrink();
      },
    );
  }
}
