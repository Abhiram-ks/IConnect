import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/cubit/home_view_cubit/home_view_cubit.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key});

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
                  currentIndex: NavItem.values.indexOf(state),
                  onTap: (index) {
                    if (NavItem.values[index] == NavItem.search) {
                      // Open categories drawer when categories icon is tapped
                      Scaffold.of(scaffoldContext).openDrawer();
                    } else {
                      // If tapping home icon, reset home view to show home content
                      if (NavItem.values[index] == NavItem.home) {
                        context.read<HomeViewCubit>().showHome();
                      }

                      // Navigate to screens normally (including cart)
                      context.read<ButtomNavCubit>().selectItem(
                        NavItem.values[index],
                      );

                      // If navigating away from home, reset home view to default
                      if (NavItem.values[index] != NavItem.home) {
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
                    BottomNavigationBarItem(
                      icon: Icon(Icons.category_rounded, size: 16.sp),
                      label: 'Categories',
                      activeIcon: Icon(
                        Icons.category_rounded,
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
    );
  }
}
