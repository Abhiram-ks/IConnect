import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_drawer.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/screens/cart_screen.dart';
import 'package:iconnect/screens/home_screen.dart';
import 'package:iconnect/screens/product_screen.dart';
import 'package:iconnect/screens/search_screen.dart';

const double bottomNavBarHeight = 70.0;

class BottomNavigationControllers extends StatelessWidget {
  final List<Widget> _screens = [
    HomeScreen(),
    ProductScreen(),
    CartScreen(),
    SearchScreen(),
  ];

  BottomNavigationControllers({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ButtomNavCubit(),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: AppPalette.whiteColor.withAlpha((0.3 * 225).round()),
          highlightColor: AppPalette.blueColor.withAlpha((0.2 * 255).round()),
        ),
        child: ColoredBox(
          color: AppPalette.blueColor,
          child: SafeArea(
            child: Scaffold(
              drawer: AppDrawer(),
              appBar: CustomAppBarDashbord(),
              body: BlocBuilder<ButtomNavCubit, NavItem>(
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
              bottomNavigationBar: BlocBuilder<ButtomNavCubit, NavItem>(
                builder: (context, state) {
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
                          context.read<ButtomNavCubit>().selectItem(
                            NavItem.values[index],
                          );
                        },
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home_outlined, size: 16),
                            label: 'Home',
                            activeIcon: Icon(
                              Icons.home,
                              color: AppPalette.blueColor,
                            ),
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.grid_view, size: 16),
                            label: 'Product',
                            activeIcon: Icon(
                              Icons.grid_view_sharp,
                              color: AppPalette.blueColor,
                            ),
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.shopping_bag_outlined, size: 16),
                            label: 'Cart',
                            activeIcon: Icon(
                              Icons.shopping_bag_rounded,
                              color: AppPalette.blueColor,
                            ),
                          ),
                          BottomNavigationBarItem(
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
              ),
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
      backgroundColor: Color(0xFFEAF4F4),
      elevation: 4,
      centerTitle: false,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppPalette.blackColor,
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
          icon: const Icon(
            CupertinoIcons.search,
            color: AppPalette.blackColor,
          ),
          onPressed: onNotificationTap,
          tooltip: 'Add user',
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.black26,
            shape: const CircleBorder(),
          ),
        ),
        ConstantWidgets.width20(context),
        IconButton.filled(
          icon: const Icon(
            Icons.shopping_bag_outlined,
            color: AppPalette.blackColor,
          ),
          onPressed: onNotificationTap,
          tooltip: 'Add user',
          style: IconButton.styleFrom(
               backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.black26,
            shape: const CircleBorder(),
          ),
        ),
        ConstantWidgets.width40(context),
      ],
    );
  }
}
