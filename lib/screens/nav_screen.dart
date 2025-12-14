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
import 'package:iconnect/screens/categories_screen.dart';
import 'package:iconnect/screens/detailed_cart_screen.dart';
import 'package:iconnect/screens/home_screen.dart';
import 'package:iconnect/screens/iphone17_screen.dart';
import 'package:iconnect/screens/offer_view_screen.dart';
import 'package:iconnect/screens/product_screen.dart';
import 'package:iconnect/screens/search_screen.dart';
import 'package:iconnect/widgets/navbar_widgets.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';

class BottomNavigationControllers extends StatefulWidget {
  const BottomNavigationControllers({super.key});

  @override
  State<BottomNavigationControllers> createState() =>
      _BottomNavigationControllersState();
}

class _BottomNavigationControllersState
    extends State<BottomNavigationControllers>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<Widget> _screens = [
    HomeScreen(),
    CategoriesScreen(),
    IPhone17Screen(),
    ProductScreen(),
    OfferViewScreen(),
    DetailedCartScreen(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                    final int currentIndex = _navIndex(state);
                    return IndexedStack(
                      index: currentIndex,
                      children: _screens,
                    );
                  },
                ),
                const WhatsAppFloatingButton(),
              ],
            ),
            bottomNavigationBar: BottomNavWidget(),
          ),
        ),
      ),
    );
  }
}

int _navIndex(NavItem item) {
  switch (item) {
    case NavItem.home:
      return 0;
    case NavItem.categories:
      return 1;
    case NavItem.iphone17:
      return 2;
    case NavItem.product:
      return 3;
    case NavItem.offers:
      return 4;
    case NavItem.cart:
      return 0; // Cart navigates to separate page, default to home
    case NavItem.search:
      return 6;
    case NavItem.profile:
      return 0; // Profile navigates to separate page, default to home
  }
}

class CustomAppBarDashbord extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;
  final bool hideCartIcon;

  @override
  final Size preferredSize;

  CustomAppBarDashbord({
    super.key,
    this.title = 'IConnect',
    this.onBack,
    this.onNotificationTap,
    this.hideCartIcon = false,
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
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                ),
              )
              : Builder(
                builder: (BuildContext scaffoldContext) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: AppPalette.blackColor),
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
        if (!hideCartIcon)
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
                      // Navigate to detailed cart screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DetailedCartScreen(),
                        ),
                      );
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
