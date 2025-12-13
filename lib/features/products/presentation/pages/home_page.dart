import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/cubit/home_view_cubit/home_view_cubit.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/widgets/home_widgets/banner_section.dart';
import 'package:iconnect/features/products/presentation/widgets/home_widgets/brand_section.dart';
import 'package:iconnect/features/products/presentation/widgets/categories_carousel.dart';
import 'package:iconnect/features/products/presentation/widgets/home_widgets/tabbed_products_section.dart';
import 'package:iconnect/features/products/presentation/widgets/home_widgets/category_products_section.dart';
import 'package:iconnect/features/products/presentation/widgets/home_widgets/dynamic_banner_section.dart';
import 'package:iconnect/features/products/domain/entities/home_screen_entity.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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

  /// Handle banner tap based on action type
  void _handleBannerTap(BuildContext context, BannerItemEntity banner) {
    switch (banner.actionType) {
      case BannerActionType.product:
        // Navigate to product details page
        if (banner.productHandle != null && banner.productHandle!.isNotEmpty) {
          Navigator.pushNamed(
            context,
            '/product_details',
            arguments: {'productHandle': banner.productHandle},
          );
        }
        break;

      case BannerActionType.collection:
        // Navigate to collection products page
        if (banner.collectionHandle != null &&
            banner.collectionHandle!.isNotEmpty) {
          Navigator.pushNamed(
            context,
            '/collection_products',
            arguments: {
              'collectionHandle': banner.collectionHandle,
              'collectionTitle': banner.collectionTitle ?? '',
            },
          );
        }
        break;

      case BannerActionType.page:
        // Navigate to specific page based on page name
        final pageName = banner.pageName?.toLowerCase().trim() ?? '';

        if (pageName == 'offers') {
          // Navigate to Offers tab
          context.read<ButtomNavCubit>().selectItem(NavItem.offers);
          context.read<HomeViewCubit>().showHome();
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.navigation,
            (route) => false,
          );
        } else if (pageName == 'iphone17' || pageName == 'iphone 17') {
          // Navigate to iPhone17 tab
          context.read<ButtomNavCubit>().selectItem(NavItem.iphone17);
          context.read<HomeViewCubit>().showHome();
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.navigation,
            (route) => false,
          );
        }
        break;

      case BannerActionType.none:
        // Do nothing
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    // Load collections for banners
    context.read<ProductBloc>().add(
      LoadCollectionsRequested(first: 10, forBanners: true),
    );
    // Load home categories (first 20)
    context.read<ProductBloc>().add(LoadHomeCategoriesRequested(first: 20));
    // Load collections for category products sections
    context.read<ProductBloc>().add(
      LoadCollectionsRequested(first: 50, forBanners: false),
    );
    // Load home screen sections
    context.read<ProductBloc>().add(LoadHomeScreenSectionsRequested());
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
                      const TabbedProductsSection(),
                      ConstantWidgets.hight30(context),
                      // Dynamic Home Screen Sections
                      BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          if (state.homeScreenSections.status ==
                              Status.completed) {
                            final sections =
                                state.homeScreenSections.data ?? [];

                            return Column(
                              children: [
                                for (var section in sections) ...[
                                  // Featured Collection Products
                                  if (section.featuredCollection != null) ...[
                                    ConstantWidgets.hight20(context),
                                    CategoryProductsSection(
                                      categoryName:
                                          section.collectionTitle ??
                                          section.featuredCollection!.title,
                                      collectionHandle:
                                          section.featuredCollection!.handle,
                                      initialProductCount: 10,
                                    ),
                                  ],
                                  // Horizontal Banners
                                  if (section.horizontalBanners.isNotEmpty) ...[
                                    ConstantWidgets.hight20(context),
                                    HorizontalBannersSection(
                                      banners: section.horizontalBanners,
                                      onBannerTap:
                                          (banner) =>
                                              _handleBannerTap(context, banner),
                                    ),
                                  ],

                                  // Vertical Banners
                                  if (section.verticalBanners.isNotEmpty) ...[
                                    ConstantWidgets.hight20(context),
                                    VerticalBannersSection(
                                      banners: section.verticalBanners,
                                      onBannerTap:
                                          (banner) =>
                                              _handleBannerTap(context, banner),
                                    ),
                                  ],
                                ],
                              ],
                            );
                          }

                          // Show loading or empty state
                          return SizedBox.shrink();
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
