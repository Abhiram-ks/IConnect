import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/cubit/home_view_cubit/home_view_cubit.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/widgets/home_widgets/banner_section.dart';
import 'package:iconnect/features/products/presentation/widgets/home_widgets/brand_section.dart';
import 'package:iconnect/features/products/presentation/widgets/categories_carousel.dart';
import 'package:iconnect/widgets/new_arrivals_section.dart' show ServiceBanner;
import 'package:iconnect/features/products/presentation/widgets/home_widgets/shopify_new_arrivals_section.dart';
import 'package:iconnect/widgets/shopify_product_grid_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewCubit, HomeViewData>(
      builder: (context, state) {
        return PopScope(
          canPop: state.viewState == HomeViewState.home,
          // ignore: deprecated_member_use
          onPopInvoked: (bool didPop) {
            if (!didPop && state.viewState == HomeViewState.bannerDetails) {
              context.read<HomeViewCubit>().showHome();
            }
          },
          child: const _HomeContentView(),
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

class _HomeContentViewState extends State<_HomeContentView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(
      LoadCollectionsRequested(first: 10, forBanners: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        return Scaffold(
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                BannerSection(screenHeight: height, screenWidth: width),
                ConstantWidgets.hight10(context),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CategoriesCarousel(),
                      ConstantWidgets.hight10(context),
                      const BrandSection(),
                      ConstantWidgets.hight30(context),
                      ShopifyProductGridSection(
                        title: 'Featured Products',
                        crossAxisCount: 2,
                        productCount: 6,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),
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
