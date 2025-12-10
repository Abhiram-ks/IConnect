import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/app_images.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/screens/collection_products_screen.dart';
import 'package:iconnect/core/utils/api_response.dart' show Status;
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/cubit/home_view_cubit/home_view_cubit.dart';
import 'package:iconnect/routes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BannerSection extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;

  const BannerSection({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  PageController? _pageController;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  /// Navigate based on banner title and category
  void _navigateBanner(
    BuildContext context,
    String handle,
    String? title,
    String? categoryHandle,
  ) {
    // Check if title is "Offers" or "Iphone17" (case-insensitive)
    final normalizedTitle = title?.toLowerCase().trim() ?? '';

    if (normalizedTitle == 'offers') {
      // Navigate to bottom navbar - Offers tab
      context.read<ButtomNavCubit>().selectItem(NavItem.offers);
      context.read<HomeViewCubit>().showHome();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.navigation,
        (route) => false,
      );
      return;
    }

    if (normalizedTitle == 'iphone17' || normalizedTitle == 'iphone 17') {
      // Navigate to bottom navbar - iPhone17 tab
      context.read<ButtomNavCubit>().selectItem(NavItem.iphone17);
      context.read<HomeViewCubit>().showHome();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.navigation,
        (route) => false,
      );
      return;
    }

    // Use categoryHandle if available, otherwise use handle
    final collectionHandle =
        categoryHandle?.isNotEmpty == true ? categoryHandle! : handle;

    if (collectionHandle.isEmpty) {
      return;
    }

    // Navigate to collection screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CollectionProductsScreen(
              collectionHandle: collectionHandle,
              collectionTitle: title ?? '',
            ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  void _startAutoScroll(int bannerCount) {
    _autoScrollTimer?.cancel();
    if (bannerCount <= 1) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController?.hasClients == true) {
        int nextPage = _currentIndex + 1;
        if (nextPage >= bannerCount) {
          nextPage = 0;
        }
        _pageController?.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildNetworkImage({
    required String imageUrl,
    required double height,
  }) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
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
                Expanded(
                  child: Image.asset(
                    AppImages.demmyImage,
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Load banners if not already loaded
        if (state.homeBanners.status == Status.initial) {
          context.read<ProductBloc>().add(LoadHomeBannersRequested(first: 10));
        }

        // Show loading state
        if (state.homeBanners.status == Status.loading) {
          return SizedBox(
            height: widget.screenHeight * 0.3,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Show error state
        if (state.homeBanners.status == Status.error) {
          return const SizedBox.shrink();
        }

        // Get all banners from state (no filtering)
        final banners = state.homeBanners.data ?? [];

        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }

        // Calculate height based on banner aspect ratio
        final bannerAspectRatio = 1920 / 367; // ~5.23
        final calculatedHeight = (widget.screenWidth / bannerAspectRatio) * 3;

        // Start auto-scroll when banners are available
        if (banners.isNotEmpty && _autoScrollTimer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startAutoScroll(banners.length);
          });
        }

        return GestureDetector(
          onTap: () {
            // Get the current banner based on the current index
            if (_currentIndex >= 0 && _currentIndex < banners.length) {
              final currentBanner = banners[_currentIndex];
              _navigateBanner(
                context,
                currentBanner.handle,
                currentBanner.title,
                currentBanner.categoryHandle,
              );
            }
          },
          child: SizedBox(
            height: calculatedHeight,
            width: widget.screenWidth,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: banners.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    final imageUrl = banner.imageUrl;

                    // Show image if available, otherwise show placeholder
                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      return imageUrl.startsWith('http')
                          ? _buildNetworkImage(
                            imageUrl: imageUrl,
                            height: calculatedHeight,
                          )
                          : Image.asset(
                            AppImages.demmyImage,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            height: calculatedHeight,
                            width: widget.screenWidth,
                          );
                    } else {
                      // Placeholder for banners without images
                      return Image.asset(
                        AppImages.demmyImage,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        height: calculatedHeight,
                        width: widget.screenWidth,
                      );
                    }
                  },
                ),
                if (banners.length > 1)
                  Positioned(
                    bottom: 8,
                    child: SmoothPageIndicator(
                      controller: _pageController!,
                      count: banners.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 8.h,
                        dotWidth: 8.w,
                        activeDotColor: AppPalette.whiteColor,
                        dotColor: AppPalette.greyColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
