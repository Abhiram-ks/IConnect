// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

import '../constant/app_images.dart';
import '../cubit/image_slider_cubit/image_slider_cubit.dart';
import '../cubit/brand_scroll_cubit/brand_scroll_cubit.dart';
import '../cubit/home_view_cubit/home_view_cubit.dart';
import '../widgets/brand_card.dart';
import '../widgets/new_arrivals_section.dart';
import '../data/brand_data.dart';
// ✅ Import real Shopify widgets
import '../widgets/shopify_new_arrivals_section.dart';
import '../widgets/shopify_product_grid_section.dart';

// Reusable Category Card Widget
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppPalette.blueColor.withValues(alpha: 0.1),
                  AppPalette.greenColor.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.r),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppPalette.blueColor,
                      strokeWidth: 2,
                      value:
                          loadingProgress.expectedTotalBytes != null
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
                    size: 30.sp,
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewCubit, HomeViewData>(
      builder: (context, state) {
        return PopScope(
          canPop: state.viewState == HomeViewState.home,
          onPopInvoked: (bool didPop) {
            if (!didPop && state.viewState == HomeViewState.bannerDetails) {
              context.read<HomeViewCubit>().showHome();
            }
          },
          child:
              state.viewState == HomeViewState.bannerDetails
                  ? _BannerDetailsView(
                    bannerTitle: state.bannerTitle ?? '',
                    bannerProducts: state.bannerProducts ?? [],
                  )
                  : const _HomeContentView(),
        );
      },
    );
  }
}

class _HomeContentView extends StatefulWidget {
  const _HomeContentView();

  @override
  State<_HomeContentView> createState() => _HomeContentViewState();
}

class _HomeContentViewState extends State<_HomeContentView> {
  late InfiniteScrollController infiniteScrollController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;

  static const List<Map<String, String>> categories = [
    {
      'title': 'iMac',
      'imageUrl':
          'https://images.unsplash.com/photo-1527864550417-7f91a4d4d85d?w=150&h=150&fit=crop&crop=center',
    },
    {
      'title': 'Games',
      'imageUrl':
          'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=150&h=150&fit=crop&crop=center',
    },
    {
      'title': 'Headphones',
      'imageUrl':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=150&h=150&fit=crop&crop=center',
    },
    {
      'title': 'Speaker',
      'imageUrl':
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=150&h=150&fit=crop&crop=center',
    },
    {
      'title': 'Airpods',
      'imageUrl':
          'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=150&h=150&fit=crop&crop=center',
    },
    {
      'title': 'Laptop',
      'imageUrl':
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=150&h=150&fit=crop&crop=center',
    },
  ];

  @override
  void initState() {
    super.initState();
    infiniteScrollController = InfiniteScrollController(initialItem: 0);
    // Delay auto-scroll to let UI settle
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(
      const Duration(milliseconds: 2500),
      (timer) {
        if (mounted && infiniteScrollController.hasClients) {
          _currentIndex = (_currentIndex + 1) % categories.length;
          infiniteScrollController.animateToItem(
            _currentIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      },
    );
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _resumeAutoScroll() {
    _stopAutoScroll();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    infiniteScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        return Scaffold(
          backgroundColor: AppPalette.whiteColor,
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: ImageScolingWidget(
                    imageList: [
                      'https://static.vecteezy.com/system/resources/previews/020/737/706/non_2x/web-banner-or-horizontal-template-design-with-special-offer-on-mobile-phones-for-advertising-concept-vector.jpg',
                      'https://tse4.mm.bing.net/th/id/OIP.yVGDg2ygsSNXfoA1pLwVNAHaEK?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3',
                      'https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/77f7c336776659.5728f30441a89.jpg',
                    ],
                    screenHeight: height,
                    screenWidth: width,
                    show: true,
                  ),
                ),

                ConstantWidgets.hight10(context),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 120.h,
                        child: GestureDetector(
                          onPanDown: (_) => _stopAutoScroll(),
                          onPanEnd: (_) => _resumeAutoScroll(),
                          onPanCancel: () => _resumeAutoScroll(),
                          child: InfiniteCarousel.builder(
                            itemCount: categories.length,
                            itemExtent: 90.w,
                            center: true,
                            anchor: 0.0,
                            scrollBehavior:
                                kIsWeb
                                    ? ScrollConfiguration.of(context).copyWith(
                                      dragDevices: {
                                        PointerDeviceKind.touch,
                                        PointerDeviceKind.mouse,
                                      },
                                    )
                                    : null,
                            loop: true,
                            velocityFactor: 0.15,
                            physics: const BouncingScrollPhysics(),
                            onIndexChanged: (index) {
                              if (mounted) {
                                _currentIndex = index;
                              }
                            },
                            controller: infiniteScrollController,
                            axisDirection: Axis.horizontal,
                            itemBuilder: (context, itemIndex, __) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: CategoryCard(
                                  imageUrl: categories[itemIndex]['imageUrl']!,
                                  title: categories[itemIndex]['title']!,
                                  onTap: () {
                                    _stopAutoScroll();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${categories[itemIndex]['title']} tapped!',
                                        ),
                                        backgroundColor: AppPalette.blackColor,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      ConstantWidgets.hight10(context),
                      BlocProvider(
                        create:
                            (context) =>
                                BrandScrollCubit(brandList: BrandData.brands),
                        child: SizedBox(
                          height: 28.h,
                          child: BlocBuilder<BrandScrollCubit, int>(
                            builder: (context, state) {
                              final cubit = context.read<BrandScrollCubit>();
                              return NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if (notification
                                      is ScrollUpdateNotification) {
                                    cubit.updateScrollPosition(
                                      notification.metrics.pixels,
                                    );
                                  }
                                  return false;
                                },
                                child: ListView.builder(
                                  controller: cubit.scrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: BrandData.brands.length,
                                  itemBuilder: (context, index) {
                                    final brand = BrandData.brands[index];
                                    return BrandCard(
                                      imageUrl: brand['imageUrl'],
                                      onTap: () {},
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // ✅ Real Shopify Products Grid
                      ConstantWidgets.hight30(context),
                      ShopifyProductGridSection(
                        title: 'Featured Products from Shopify',
                        crossAxisCount: 2,
                        productCount: 6,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),

                      // ✅ Real Shopify New Arrivals Section (Horizontal Scroll)
                      ConstantWidgets.hight20(context),
                      ShopifyNewArrivalsSection(
                        title: 'New Arrivals from Shopify Store',
                        productCount: 10,
                        onViewAll: () {
                          Navigator.pushNamed(
                            context,
                            '/test-shopify-products',
                          );
                        },
                      ),

                      ConstantWidgets.hight20(context),
                      ServiceBanner(
                        title: 'SMARTPHONES DISPLAY REPAIR',
                        imageUrl:
                            'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&h=120&fit=crop&crop=center',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening repair services!'),
                              backgroundColor: AppPalette.greenColor,
                            ),
                          );
                        },
                      ),

                      ServiceBanner(
                        title: 'Repair Services',
                        subtitle: 'Professional Electronic Repair',
                        imageUrl:
                            'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&h=120&fit=crop&crop=center',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening all services!'),
                              backgroundColor: AppPalette.blueColor,
                            ),
                          );
                        },
                      ),

                      // ✅ Another Real Shopify Products Section
                      ConstantWidgets.hight20(context),
                      ShopifyNewArrivalsSection(
                        title: 'Trending Products',
                        productCount: 8,
                        onViewAll: () {
                          Navigator.pushNamed(
                            context,
                            '/test-shopify-products',
                          );
                        },
                      ),

                      SizedBox(height: 64.h),
                    ],
                  ),
                ), // Brands Section with Cubit Management
              ],
            ),
          ),
        );
      },
    );
  }
}

class ImageScolingWidget extends StatelessWidget {
  const ImageScolingWidget({
    super.key,
    required this.imageList,
    required this.screenHeight,
    required this.screenWidth,
    required this.show,
  });

  final List<String> imageList;
  final double screenHeight;
  final double screenWidth;
  final bool show;

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
                        ? imageshow(
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
}

Widget imageshow({
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

// Banner Details View Widget
class _BannerDetailsView extends StatelessWidget {
  final String bannerTitle;
  final List<Map<String, dynamic>> bannerProducts;

  const _BannerDetailsView({
    required this.bannerTitle,
    required this.bannerProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerHero(context),

            // Bottom padding
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerHero(BuildContext context) {
    return Container(
      width: double.infinity,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageshow(
            imageUrl:
                'https://www.creativefabrica.com/wp-content/uploads/2022/09/29/Luxury-Watch-Store-Banner-Template-Graphics-39519650-1-1-580x386.jpg',
            imageAsset: AppImages.demmyImage,
            height: 80.h,
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 16.sp,
                            color: AppPalette.blackColor,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16.sp,
                            color: AppPalette.greyColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showSortBottomSheet(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sort,
                            size: 16.sp,
                            color: AppPalette.blackColor,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Sort A-Z',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16.sp,
                            color: AppPalette.greyColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppPalette.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(1.r)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 24.sp),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ...[
                  'Featured',
                  'Best selling',
                  'Alphabetically, A-Z',
                  'Alphabetically, Z-A',
                  'Price, low to high',
                  'Price, high to low',
                  'Date, old to new',
                  'Date, new to old',
                ].map((option) {
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 0,
                    ),
                    visualDensity: VisualDensity.compact,
                    dense: true,
                    title: Text(option, style: TextStyle(fontSize: 16.sp)),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sorted by: $option'),
                          duration: Duration(seconds: 1),
                          backgroundColor: AppPalette.blueColor,
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
    );
  }
}
