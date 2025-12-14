import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/storage/secure_storage_service.dart';
import 'package:iconnect/cubit/home_view_cubit/home_view_cubit.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/routes.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key});

  /// Maps NavItem to bottom navigation bar index
  /// Note: search and cart are not in the bottom nav bar
  int _getBottomNavIndex(NavItem item) {
    switch (item) {
      case NavItem.home:
        return 0;
      case NavItem.categories:
        return 1;
      case NavItem.iphone17:
        return 2;
      case NavItem.product:
        return 0; // Product item is hidden, default to home
      case NavItem.offers:
        return 3; // Changed from 4 to 3 (Product removed)
      case NavItem.profile:
        return 4; // Profile button
      case NavItem.cart:
        return 0; // Cart navigates to separate page, default to home
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
        return NavItem
            .offers; // Changed from product to offers (Product removed)
      case 4:
        return NavItem.profile; // Profile button
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
                  onTap: (index) async {
                    // Check if we're on the main navigation screen
                    final currentRoute = ModalRoute.of(context)?.settings.name;
                    final isOnMainScreen = currentRoute == AppRoutes.navigation;

                    // Get the NavItem from the bottom nav index
                    final selectedNavItem = _getNavItemFromIndex(index);

                    // Handle profile navigation based on login status
                    if (selectedNavItem == NavItem.profile) {
                      final isLoggedIn =
                          await SecureStorageService.isLoggedIn();
                      if (isLoggedIn) {
                        // Navigate to profile page
                        Navigator.pushNamed(context, AppRoutes.profile);
                      } else {
                        // Navigate to login page
                        Navigator.pushNamed(context, AppRoutes.login);
                      }
                      return;
                    }

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
                    // const BottomNavigationBarItem(
                    //   icon: Icon(Icons.grid_view, size: 16),
                    //   label: 'Product',
                    //   activeIcon: Icon(
                    //     Icons.grid_view_rounded,
                    //     color: AppPalette.blueColor,
                    //   ),
                    // ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.local_offer_outlined, size: 16.sp),
                      label: 'Offers',
                      activeIcon: Icon(
                        Icons.local_offer,
                        color: AppPalette.blueColor,
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline, size: 16.sp),
                      label: 'Profile',
                      activeIcon: Icon(
                        Icons.person,
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
