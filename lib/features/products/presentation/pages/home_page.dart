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
                      CategoryProductsSection(
                        categoryName: "New Arrivals",
                        collectionHandle:
                            "new-arrivals-in-qatar-iconnect-qatar",
                        initialProductCount: 30,
                      ),

                      // Dynamic Category Sections from Collections
                      BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          if (state.collections.status == Status.completed) {
                            final collections = state.collections.data ?? [];

                            return Column(
                              children: [
                                for (
                                  int i = 0;
                                  i < collections.length;
                                  i++
                                ) ...[
                                  ConstantWidgets.hight20(context),
                                  CategoryProductsSection(
                                    categoryName: collections[i].title,
                                    collectionHandle: collections[i].handle,
                                    initialProductCount: 20,
                                  ),

                                  // Add service banners after every 4 categories
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
