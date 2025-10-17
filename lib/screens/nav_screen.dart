import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_drawer.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/cubit/home_view_cubit/home_view_cubit.dart';
import 'package:iconnect/screens/detailed_cart_screen.dart';
import 'package:iconnect/screens/home_screen.dart';
import 'package:iconnect/screens/product_screen.dart';
import 'package:iconnect/screens/search_screen.dart';
import 'package:iconnect/widgets/cart_drawer.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';

const double bottomNavBarHeight = 70.0;

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
              endDrawer: const CartDrawer(),
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
                        height: bottomNavBarHeight,
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
                            // Open search screen when search icon is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
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
                              builder: (context, state) {
                                return Stack(
                                  children: [
                                    const Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 16,
                                    ),
                                    if (state.itemCount > 0)
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
                                            '${state.itemCount}',
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
                              builder: (context, state) {
                                return Stack(
                                  children: [
                                    const Icon(
                                      Icons.shopping_bag_rounded,
                                      color: AppPalette.blueColor,
                                    ),
                                    if (state.itemCount > 0)
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
                                            '${state.itemCount}',
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
                              CupertinoIcons.search,
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

  const CustomAppBarDashbord({
    super.key,
    this.title = 'IConnect',
    this.onBack,
    this.onNotificationTap,
  }) : preferredSize = const Size.fromHeight(60);

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
          height: 25,
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
              : null,
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
        ConstantWidgets.width20(context),
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
                  builder: (context, state) {
                    if (state.itemCount > 0) {
                      return Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppPalette.redColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${state.itemCount}',
                            style: const TextStyle(
                              color: AppPalette.whiteColor,
                              fontSize: 10,
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
        ConstantWidgets.width40(context),
      ],
    );
  }
}
