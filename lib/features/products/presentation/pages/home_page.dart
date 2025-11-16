import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/cubit/home_view_cubit/home_view_cubit.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/widgets/banner_section.dart';
import 'package:iconnect/features/products/presentation/widgets/brand_section.dart';
import 'package:iconnect/features/products/presentation/widgets/categories_carousel.dart';
import 'package:iconnect/widgets/new_arrivals_section.dart' show ServiceBanner;
import 'package:iconnect/widgets/shopify_new_arrivals_section.dart';
import 'package:iconnect/widgets/shopify_product_grid_section.dart';

/// Home Page - Main home screen with banners, categories, and products
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
  @override
  void initState() {
    super.initState();
    // Load banners from Shopify
    context.read<ProductBloc>().add(
      LoadCollectionsRequested(first: 5, forBanners: true),
    );
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
                // Dynamic Shopify Banners
                BannerSection(screenHeight: height, screenWidth: width),

                ConstantWidgets.hight10(context),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dynamic Categories from Shopify Collections
                      const CategoriesCarousel(),

                      ConstantWidgets.hight10(context),
                      // Brand Section Widget
                      const BrandSection(),

                      // ✅ Real Shopify Products Grid
                      ConstantWidgets.hight30(context),
                      ShopifyProductGridSection(
                        title: 'Featured Products',
                        crossAxisCount: 2,
                        productCount: 6,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),

                      // ✅ Real Shopify New Arrivals Section (Horizontal Scroll)
                      ConstantWidgets.hight20(context),
                      ShopifyNewArrivalsSection(
                        title: 'New Arrivals',
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
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
          Image.network(
            'https://www.creativefabrica.com/wp-content/uploads/2022/09/29/Luxury-Watch-Store-Banner-Template-Graphics-39519650-1-1-580x386.jpg',
            height: 80.h,
            width: double.infinity,
            fit: BoxFit.cover,
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
