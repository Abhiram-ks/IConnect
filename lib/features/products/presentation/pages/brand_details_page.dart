import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconnect/features/products/presentation/widgets/brands_widgets/brands_widget_catogory.dart';
import 'package:iconnect/features/products/presentation/widgets/brands_widgets/brands_widget_hero.dart';
import 'package:iconnect/features/products/presentation/widgets/brands_widgets/brands_widget_product.dart';
import 'package:shimmer/shimmer.dart';
import 'package:iconnect/app_drawer.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:iconnect/features/cart/presentation/widgets/cart_drawer_widget.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart' as products;
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/screens/nav_screen.dart';
import 'package:iconnect/screens/search_screen.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';

import '../../../../constant/constant.dart';
import '../../../../widgets/shopify_product_grid_section.dart';

/// Brand Details Page - Shows brand categories and products
class BrandDetailsPage extends StatefulWidget {
  final int brandId;
  final String brandName;
  final String brandVendor;
  final String brandImageUrl;

  const BrandDetailsPage({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.brandVendor,
    required this.brandImageUrl,
  });

  @override
  State<BrandDetailsPage> createState() => _BrandDetailsPageState();
}

class _BrandDetailsPageState extends State<BrandDetailsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load products filtered by vendor (brand) using separate state
    context.read<products.ProductBloc>().add(
      LoadBrandProductsRequested(vendor: widget.brandVendor, first: 20),
    );
    // Load collections (categories)
    context.read<products.ProductBloc>().add(
      LoadCollectionsRequested(first: 20, forBanners: false),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<products.ProductBloc>().state;
      if (state.brandProducts.status == Status.completed &&
          state.brandProductsHasNextPage) {
        context.read<products.ProductBloc>().add(
          LoadBrandProductsRequested(
            vendor: widget.brandVendor,
            after: state.brandProductsEndCursor,
            loadMore: true,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      endDrawer: const CartDrawerWidget(),
      appBar: CustomAppBarDashbord(),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildBrandHero( context, widget),
                buildBrandCategoriesSection(),
                buildBrandProductsSection(context, widget),
                ConstantWidgets.hight10(context),
              ],
            ),
          ),
          const WhatsAppFloatingButton(),
        ],
      ),
      bottomNavigationBar: BlocBuilder<ButtomNavCubit, NavItem>(
        builder: (context, state) {
          return Builder(
            builder: (BuildContext scaffoldContext) {
              return SizedBox(
                height: 70.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppPalette.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.blackColor.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    enableFeedback: true,
                    useLegacyColorScheme: true,
                    elevation: 0,
                    iconSize: 26,
                    selectedItemColor: AppPalette.blueColor,
                    backgroundColor: Colors.transparent,
                    landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
                    unselectedLabelStyle: TextStyle(
                      color: AppPalette.hintColor,
                    ),
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: NavItem.values.indexOf(NavItem.home),
                    onTap: (index) {
                      if (NavItem.values[index] == NavItem.cart) {
                        Scaffold.of(scaffoldContext).openEndDrawer();
                      } else if (NavItem.values[index] == NavItem.search) {
                        Navigator.pushReplacementNamed(context, '/');
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          }
                        });
                      } else {
                        Navigator.pushReplacementNamed(context, '/');
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            context.read<ButtomNavCubit>().selectItem(
                              NavItem.values[index],
                            );
                          }
                        });
                      }
                    },
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined, size: 16),
                        label: 'Home',
                        activeIcon: Icon(
                          Icons.home,
                          color: AppPalette.blueColor,
                        ),
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.grid_view, size: 16),
                        label: 'Product',
                        activeIcon: Icon(
                          Icons.grid_view_sharp,
                          color: AppPalette.blueColor,
                        ),
                      ),
                      BottomNavigationBarItem(
                        icon: BlocBuilder<CartCubit, CartState>(
                          bloc: sl<CartCubit>(),
                          builder: (context, state) {
                            int itemCount = 0;
                            if (state is CartLoaded) {
                              itemCount = state.cart.itemCount;
                            } else if (state is CartOperationInProgress) {
                              itemCount = state.currentCart.itemCount;
                            }

                            return Stack(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 16,
                                ),
                                if (itemCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppPalette.redColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$itemCount',
                                        style: const TextStyle(
                                          color: AppPalette.whiteColor,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        label: 'Cart',
                        activeIcon: BlocBuilder<CartCubit, CartState>(
                          bloc: sl<CartCubit>(),
                          builder: (context, state) {
                            int itemCount = 0;
                            if (state is CartLoaded) {
                              itemCount = state.cart.itemCount;
                            } else if (state is CartOperationInProgress) {
                              itemCount = state.currentCart.itemCount;
                            }

                            return Stack(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_rounded,
                                  color: AppPalette.blueColor,
                                ),
                                if (itemCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppPalette.redColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$itemCount',
                                        style: const TextStyle(
                                          color: AppPalette.whiteColor,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.search, size: 16),
                        label: 'Search',
                        activeIcon: Icon(
                          Icons.search,
                          color: AppPalette.blueColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  
  }

}
