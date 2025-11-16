import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_drawer.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:iconnect/features/cart/presentation/widgets/cart_drawer_widget.dart';
import 'package:iconnect/cubit/home_view_cubit/home_view_cubit.dart';
import 'package:iconnect/screens/detailed_cart_screen.dart';
import 'package:iconnect/screens/home_screen.dart';
import 'package:iconnect/screens/product_screen.dart';
import 'package:iconnect/screens/search_screen.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';

class BottomNavigationControllers extends StatelessWidget {
  final List<Widget> _screens = [
    HomeScreen(),
    ProductScreen(),
    DetailedCartScreen(),
    SearchScreen(),
  ];

  BottomNavigationControllers({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          splashColor: AppPalette.whiteColor.withAlpha((0.3 * 225).round()),
          highlightColor: AppPalette.blueColor.withAlpha((0.2 * 255).round()),
        ),
        child: ColoredBox(
          color: AppPalette.blueColor,
          child: SafeArea(
            child: Scaffold(
              drawer: AppDrawer(),
              endDrawer: const CartDrawerWidget(),
              appBar: CustomAppBarDashbord(),
              body: Stack(
                children: [
                  BlocBuilder<ButtomNavCubit, NavItem>(
                    builder: (context, state) {
                      switch (state) {
                        case NavItem.home:
                          return _screens[0];
                        case NavItem.product:
                          return _screens[1];
                        case NavItem.cart:
                          return _screens[2];
                        case NavItem.search:
                          return _screens[3];
                      }
                    },
                  ),
                  const WhatsAppFloatingButton(),
                ],
              ),
              bottomNavigationBar: BlocBuilder<ButtomNavCubit, NavItem>(
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
                            landscapeLayout:
                                BottomNavigationBarLandscapeLayout.spread,
                            unselectedLabelStyle: TextStyle(
                              color: AppPalette.hintColor,
                            ),
                            showSelectedLabels: true,
                            showUnselectedLabels: true,
                            type: BottomNavigationBarType.fixed,
                            currentIndex: NavItem.values.indexOf(state),
                            onTap: (index) {
                              if (NavItem.values[index] == NavItem.cart) {
                                // Open cart drawer when cart icon is tapped
                                Scaffold.of(scaffoldContext).openEndDrawer();
                          } else if (NavItem.values[index] == NavItem.search) {
                            // Open categories drawer when categories icon is tapped
                            Scaffold.of(scaffoldContext).openDrawer();
                          } else {
                            // If tapping home icon, reset home view to show home content
                            if (NavItem.values[index] == NavItem.home) {
                              context.read<HomeViewCubit>().showHome();
                            }
                            
                            // Navigate to other screens normally
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
                              Icons.home,
                              color: AppPalette.blueColor,
                            ),
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.percent, size: 16.sp),
                            label: 'Offers',
                            activeIcon: Icon(
                              Icons.percent_outlined,
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
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 16.sp,
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
              ),
            ),
          ),
        ),
    );
  }
}

class CustomAppBarDashbord extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;

  @override
  final Size preferredSize;

  CustomAppBarDashbord({
    super.key,
    this.title = 'IConnect',
    this.onBack,
    this.onNotificationTap,
  }) : preferredSize = Size.fromHeight(60.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      surfaceTintColor: Colors.white,
      centerTitle: true,
      title: Center(
        child: Image.asset(
          'assets/iconnect_logo.png',
          height: 25.h,
          fit: BoxFit.contain,
        ),
      ),
      leading:
          onBack != null
              ? IconButton.filled(
                tooltip: 'Back',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const CircleBorder(),
                ),
              )
              : Builder(
                builder: (BuildContext scaffoldContext) {
                  return IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: AppPalette.blackColor,
                    ),
                    onPressed: () {
                      // Open drawer when menu icon is tapped
                      Scaffold.of(scaffoldContext).openDrawer();
                    },
                    tooltip: 'Menu',
                  );
                },
              ),
      actions: [
        IconButton.filled(
          icon: const Icon(Icons.search, color: AppPalette.blackColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
                fullscreenDialog: true,
              ),
            );
          },
          tooltip: 'Search',
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.black26,
            shape: const CircleBorder(),
          ),
        ),
        Builder(
          builder: (BuildContext scaffoldContext) {
            return Stack(
              children: [
                IconButton.filled(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppPalette.blackColor,
                  ),
                  onPressed: () {
                    // Open cart drawer when header cart icon is tapped
                    Scaffold.of(scaffoldContext).openEndDrawer();
                  },
                  tooltip: 'Shopping Cart',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.black26,
                    shape: const CircleBorder(),
                  ),
                ),
                BlocBuilder<CartCubit, CartState>(
                  bloc: sl<CartCubit>(),
                  builder: (context, state) {
                    int itemCount = 0;
                    if (state is CartLoaded) {
                      itemCount = state.cart.itemCount;
                    } else if (state is CartOperationInProgress) {
                      itemCount = state.currentCart.itemCount;
                    }
                    
                    if (itemCount > 0) {
                      return Positioned(
                        right: 8.w,
                        top: 8.h,
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
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),
        ConstantWidgets.width20(context),
      ],
    );
  }
}
