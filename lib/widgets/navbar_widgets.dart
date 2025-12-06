import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/cubit/home_view_cubit/home_view_cubit.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:iconnect/routes.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key});

  /// Maps NavItem to bottom navigation bar index
  /// Note: search is not in the bottom nav bar (it opens drawer)
  int _getBottomNavIndex(NavItem item) {
    switch (item) {
      case NavItem.home:
        return 0;
      case NavItem.categories:
        return 1;
      case NavItem.iphone17:
        return 2;
      case NavItem.product:
        return 3;
      case NavItem.cart:
        return 4;
      case NavItem.search:
        // Search opens drawer, not in bottom nav
        return 0; // Default to home
    }
  }

  /// Maps bottom navigation bar index to NavItem
  NavItem _getNavItemFromIndex(int index) {
    switch (index) {
      case 0:
        return NavItem.home;
      case 1:
        return NavItem.categories;
      case 2:
        return NavItem.iphone17;
      case 3:
        return NavItem.product;
      case 4:
        return NavItem.cart;
      default:
        return NavItem.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ButtomNavCubit, NavItem>(
      builder: (context, state) {
        return Builder(
          builder: (BuildContext scaffoldContext) {
            return SizedBox(
              height: 70.h,
              child: Container(
                decoration: BoxDecoration(
                  color: AppPalette.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.blackColor.withValues(alpha: 0.1),
                      blurRadius: 6.r,
                      offset: Offset(0, -3.h),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  enableFeedback: true,
                  useLegacyColorScheme: true,
                  elevation: 0,
                  iconSize: 26.sp,
                  selectedItemColor: AppPalette.blueColor,
                  backgroundColor: Colors.transparent,
                  landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
                  unselectedLabelStyle: TextStyle(color: AppPalette.hintColor),
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _getBottomNavIndex(state),
                  onTap: (index) {
                    // Check if we're on the main navigation screen
                    final currentRoute = ModalRoute.of(context)?.settings.name;
                    final isOnMainScreen = currentRoute == AppRoutes.navigation;

                    // Get the NavItem from the bottom nav index
                    final selectedNavItem = _getNavItemFromIndex(index);

                    // If tapping home icon, reset home view to show home content
                    if (selectedNavItem == NavItem.home) {
                      context.read<HomeViewCubit>().showHome();
                    }

                    // If not on main screen, navigate to main screen first
                    if (!isOnMainScreen) {
                      // Set navigation state first, so main screen opens on correct tab
                      context.read<ButtomNavCubit>().selectItem(
                        selectedNavItem,
                      );
                      // If navigating away from home, reset home view to default
                      if (selectedNavItem != NavItem.home) {
                        context.read<HomeViewCubit>().showHome();
                      }
                      // Navigate to main screen
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.navigation,
                        (route) => false,
                      );
                    } else {
                      // Navigate to screens normally (including cart and iPhone 17)
                      context.read<ButtomNavCubit>().selectItem(
                        selectedNavItem,
                      );

                      // If navigating away from home, reset home view to default
                      if (selectedNavItem != NavItem.home) {
                        context.read<HomeViewCubit>().showHome();
                      }
                    }
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined, size: 16.sp),
                      label: 'Home',
                      activeIcon: Icon(
                        Icons.home_rounded,
                        color: AppPalette.blueColor,
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.category_rounded, size: 16.sp),
                      label: 'Category',
                      activeIcon: Icon(
                        Icons.category_rounded,
                        color: AppPalette.blueColor,
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.phone_android, size: 16.sp),
                      label: 'iPhone 17',
                      activeIcon: Icon(
                        Icons.phone_android,
                        color: AppPalette.blueColor,
                      ),
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view, size: 16),
                      label: 'Product',
                      activeIcon: Icon(
                        Icons.grid_view_rounded,
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
                              Icon(Icons.shopping_bag_outlined, size: 16.sp),
                              if (itemCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4.r),
                                    decoration: const BoxDecoration(
                                      color: AppPalette.redColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$itemCount',
                                      style: TextStyle(
                                        color: AppPalette.whiteColor,
                                        fontSize: 8.sp,
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
                                    padding: EdgeInsets.all(4.r),
                                    decoration: const BoxDecoration(
                                      color: AppPalette.redColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$itemCount',
                                      style: TextStyle(
                                        color: AppPalette.whiteColor,
                                        fontSize: 8.sp,
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
