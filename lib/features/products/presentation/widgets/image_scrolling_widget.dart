import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/app_images.dart';
import 'package:iconnect/cubit/image_slider_cubit/image_slider_cubit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Image Scrolling Widget - Banner carousel
class ImageScrollingWidget extends StatelessWidget {
  final List<String> imageList;
  final double screenHeight;
  final double screenWidth;
  final bool show;

  const ImageScrollingWidget({
    super.key,
    required this.imageList,
    required this.screenHeight,
    required this.screenWidth,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImageSliderCubit(imageList: imageList),
      child: Builder(
        builder: (context) {
          final cubit = context.read<ImageSliderCubit>();
          return SizedBox(
            height: screenHeight * 0.3,
            width: screenWidth,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: cubit.pageController,
                  itemCount: imageList.length,
                  onPageChanged: cubit.updatePage,
                  itemBuilder: (context, index) {
                    return (imageList[index].startsWith('http'))
                        ? _buildNetworkImage(
                          imageUrl: imageList[index],
                          imageAsset: AppImages.demmyImage,
                          height: 200.h,
                        )
                        : Image.asset(
                          AppImages.demmyImage,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        );
                  },
                ),
                Positioned(
                  bottom: 8,
                  child: BlocBuilder<ImageSliderCubit, int>(
                    builder: (context, state) {
                      return SmoothPageIndicator(
                        controller: cubit.pageController,
                        count: imageList.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 8.h,
                          dotWidth: 8.w,
                          activeDotColor: AppPalette.whiteColor,
                          dotColor: AppPalette.greyColor,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNetworkImage({
    required String imageUrl,
    required String imageAsset,
    double? height,
  }) {
    return SizedBox(
      height: height ?? 200.h,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppPalette.blueColor,
                    backgroundColor: AppPalette.hintColor,
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppPalette.greyColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Check if it's a network error
          bool isNetworkError =
              error.toString().contains('Failed host lookup') ||
              error.toString().contains('SocketException') ||
              error.toString().contains('Connection');

          return Container(
            color: Colors.grey[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isNetworkError ? Icons.wifi_off : Icons.error_outline,
                  size: 48.sp,
                  color: AppPalette.greyColor,
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    isNetworkError
                        ? 'No internet connection\nPlease check your connection'
                        : 'Failed to load image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppPalette.greyColor,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                if (imageAsset.isNotEmpty)
                  Expanded(
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          size: 48.sp,
                          color: AppPalette.greyColor,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

