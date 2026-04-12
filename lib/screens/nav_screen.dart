import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_drawer.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/core/storage/local_storage_service.dart';
import 'package:iconnect/cubit/home_view_cubit/home_view_cubit.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/features/auth/presentation/pages/register_screen.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:iconnect/features/cart/presentation/widgets/cart_drawer_widget.dart';
import 'package:iconnect/features/profile/presentation/pages/profile_page.dart';
import 'package:iconnect/routes.dart';
import 'package:iconnect/screens/categories_screen.dart';
import 'package:iconnect/screens/detailed_cart_screen.dart';
import 'package:iconnect/screens/home_screen.dart';
import 'package:iconnect/screens/iphone17_screen.dart';
import 'package:iconnect/screens/offer_view_screen.dart';
import 'package:iconnect/screens/search_screen.dart';
import 'package:iconnect/widgets/navbar_widgets.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';

// ── Tab index constants ───────────────────────────────────────────────────────
const int _kHome = 0;
const int _kCategories = 1;
const int _kIphone17 = 2;
const int _kOffers = 3;
const int _kProfile = 4; // Push-navigates, not in IndexedStack

// ── Helpers ───────────────────────────────────────────────────────────────────

int _tabIndexFromNavItem(NavItem item) {
  switch (item) {
    case NavItem.home:
      return _kHome;
    case NavItem.categories:
      return _kCategories;
    case NavItem.iphone17:
      return _kIphone17;
    case NavItem.offers:
      return _kOffers;
    default:
      return _kHome;
  }
}

NavItem _navItemFromTabIndex(int index) {
  switch (index) {
    case _kHome:
      return NavItem.home;
    case _kCategories:
      return NavItem.categories;
    case _kIphone17:
      return NavItem.iphone17;
    case _kOffers:
      return NavItem.offers;
    default:
      return NavItem.home;
  }
}

// ── Navigator observer ────────────────────────────────────────────────────────

/// Tracks route depth inside one tab's [Navigator].
/// Notifies [onDepthChanged] whenever a push/pop/replace changes the depth.
class _TabObserver extends NavigatorObserver {
  _TabObserver({required this.onDepthChanged});

  final VoidCallback onDepthChanged;

  // Starts at 1 (the root route is always present).
  int _depth = 1;

  /// The [RouteSettings.name] of the topmost route, or null for the root.
  String? _topRouteName;

  /// True when the tab has at least one route pushed on top of root.
  bool get hasStack => _depth > 1;

  /// The name of the route currently on top of this tab's stack.
  String? get topRouteName => _topRouteName;

  /// Defers the parent [setState] to the post-frame callback so it never
  /// fires during an active build pass (which would throw an assertion).
  /// [_depth] is updated synchronously so [hasStack] is already correct
  /// by the time the callback runs.
  void _scheduleNotify() {
    WidgetsBinding.instance.addPostFrameCallback((_) => onDepthChanged());
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    // previousRoute == null  →  this is the Navigator's very first route
    // (the tab's root screen). Don't count it: _depth must stay at 1 so that
    // hasStack stays false and no back button appears on the root screen.
    // Counting it would make hasStack = true, show a back button, and a tap
    // would pop the only route — crashing Flutter with _history.isNotEmpty.
    if (previousRoute == null) return;
    _depth++;
    _topRouteName = route.settings.name;
    _scheduleNotify();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (_depth > 1) _depth--;
    _topRouteName = previousRoute?.settings.name;
    _scheduleNotify();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (_depth > 1) _depth--;
    _topRouteName = previousRoute?.settings.name;
    _scheduleNotify();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _topRouteName = newRoute?.settings.name;
    _scheduleNotify();
  }
}

// ── Main shell ────────────────────────────────────────────────────────────────

class BottomNavigationControllers extends StatefulWidget {
  const BottomNavigationControllers({super.key});

  @override
  State<BottomNavigationControllers> createState() =>
      _BottomNavigationControllersState();
}

class _BottomNavigationControllersState
    extends State<BottomNavigationControllers> {
  // One navigator key + observer per content tab.
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Home
    GlobalKey<NavigatorState>(), // Categories
    GlobalKey<NavigatorState>(), // iPhone 17
    GlobalKey<NavigatorState>(), // Offers
  ];

  late final List<_TabObserver> _observers;

  late final List<Widget> _tabRoots = const [
    HomeScreen(),
    CategoriesScreen(),
    IPhone17Screen(),
    OfferViewScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Each observer calls setState so the AppBar leading icon re-evaluates.
    _observers = List.generate(
      _navigatorKeys.length,
      (_) => _TabObserver(onDepthChanged: () => setState(() {})),
    );
  }

  // ── Derived state ──────────────────────────────────────────────────────────

  int _currentTabIndex(NavItem navItem) => _tabIndexFromNavItem(navItem);

  /// Whether the active tab has any pages pushed on top of root.
  bool _activeTabHasStack(NavItem navItem) {
    final i = _currentTabIndex(navItem);
    return i < _observers.length && _observers[i].hasStack;
  }

  /// Whether the cart page is currently the topmost route in the active tab.
  bool _activeTabIsOnCart(NavItem navItem) {
    final i = _currentTabIndex(navItem);
    return i < _observers.length && _observers[i].topRouteName == '/cart';
  }

  // ── Interaction ────────────────────────────────────────────────────────────

  void _onTabTapped(int index) {
    if (index == _kProfile) {
      _openProfile();
      return;
    }

    final navItem = _navItemFromTabIndex(index);
    final currentItem = context.read<ButtomNavCubit>().state;

    if (currentItem == navItem) {
      // Re-tap active tab → pop to root of that tab.
      _navigatorKeys[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }

    context.read<ButtomNavCubit>().selectItem(navItem);
    if (navItem == NavItem.home) {
      context.read<HomeViewCubit>().showHome();
    }
  }

  void _openProfile() {
    final isLoggedIn = LocalStorageService.uid != null;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const ProfilePage() : const LoginScreen(),
      ),
    );
  }

  // ── Back button ────────────────────────────────────────────────────────────

  void _onPopInvoked(bool didPop, dynamic result) {
    if (didPop) return;

    final currentItem = context.read<ButtomNavCubit>().state;
    final tabIndex = _tabIndexFromNavItem(currentItem);

    // 1. Pop within the tab stack if possible.
    if (tabIndex < _navigatorKeys.length) {
      final nav = _navigatorKeys[tabIndex].currentState;
      if (nav != null && nav.canPop()) {
        nav.pop();
        return;
      }
    }

    // 2. Return to Home if not there already.
    if (currentItem != NavItem.home) {
      context.read<ButtomNavCubit>().selectItem(NavItem.home);
      context.read<HomeViewCubit>().showHome();
      return;
    }

    // 3. Exit the app.
    SystemNavigator.pop();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // BlocBuilder covers the whole shell so that switching tabs also refreshes
    // the AppBar leading icon (menu vs back depends on current tab's depth).
    return BlocBuilder<ButtomNavCubit, NavItem>(
      builder: (context, navItem) {
        final tabIndex = _currentTabIndex(navItem);
        final hasStack = _activeTabHasStack(navItem);
        final onCartPage = _activeTabIsOnCart(navItem);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: _onPopInvoked,
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: AppPalette.whiteColor.withValues(alpha: 0.3),
              highlightColor: AppPalette.blueColor.withValues(alpha: 0.1),
            ),
            child: ColoredBox(
              color: AppPalette.blueColor,
              child: SafeArea(
                child: Scaffold(
                  drawer: AppDrawer(),
                  endDrawer: const CartDrawerWidget(),
                  appBar: CustomAppBarDashbord(
                    // Root of any tab  → menu icon
                    // Pushed page      → back icon that pops the tab's navigator
                    isRootPage: !hasStack,
                    onBack: () => _navigatorKeys[tabIndex].currentState?.pop(),
                    // Hide the cart icon when the cart page is already on top.
                    hideCartIcon: onCartPage,
                    // Push cart inside the active tab so bottom nav stays visible.
                    // The route name '/cart' lets the observer detect when the
                    // cart page is on top, so we can hide the cart icon.
                    onCartTap:
                        () => _navigatorKeys[tabIndex].currentState?.push(
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/cart'),
                            builder: (_) => const DetailedCartScreen(),
                          ),
                        ),
                  ),
                  body: Stack(
                    children: [
                      IndexedStack(
                        index: tabIndex,
                        children: List.generate(
                          _tabRoots.length,
                          (i) => _TabNavigator(
                            navigatorKey: _navigatorKeys[i],
                            rootScreen: _tabRoots[i],
                            observer: _observers[i],
                          ),
                        ),
                      ),
                      const WhatsAppFloatingButton(),
                    ],
                  ),
                  bottomNavigationBar: BottomNavWidget(
                    currentIndex: tabIndex,
                    onTap: _onTabTapped,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Per-tab Navigator ─────────────────────────────────────────────────────────

/// Wraps one tab's root screen in its own [Navigator] so in-tab pushes
/// (product details, collections, brands…) keep the bottom nav visible.
///
/// Named routes are delegated to [AppRoutes.generateRoute] so that
/// `Navigator.pushNamed(context, AppRoutes.productDetails, …)` called from
/// anywhere inside the tab works without needing the root navigator.
///
/// Routes that must always live on the root navigator (login, signup, the shell
/// itself) are excluded by returning `null`, which bubbles to the root.
class _TabNavigator extends StatelessWidget {
  const _TabNavigator({
    required this.navigatorKey,
    required this.rootScreen,
    required this.observer,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget rootScreen;
  final _TabObserver observer;

  static const _rootOnlyRoutes = {
    AppRoutes.navigation,
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.otp,
  };

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: [observer],
      onGenerateRoute: (settings) {
        // Root route → show this tab's starting screen.
        if (settings.name == Navigator.defaultRouteName) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => rootScreen,
          );
        }

        // Routes reserved for the root navigator — return null to bubble up.
        if (_rootOnlyRoutes.contains(settings.name)) return null;

        // Everything else stays inside the tab (bottom nav remains visible).
        return AppRoutes.generateRoute(settings);
      },
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

/// Shared app bar used everywhere in the app.
///
/// **Leading icon rule** — explicit and readable:
///   `isRootPage: true`  (default) → hamburger menu, opens drawer
///   `isRootPage: false`           → back arrow, calls [onBack] if supplied
///                                   or `Navigator.pop` as fallback
///
/// The shell passes `isRootPage: !hasStack` so it automatically flips
/// between menu and back as the user navigates inside a tab.
/// Stand-alone screens (checkout, cart, profile) always pass
/// `isRootPage: false` and supply their own [onBack].
class CustomAppBarDashbord extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  /// `true`  → show hamburger / drawer opener (first / root page).
  /// `false` → show back arrow ([onBack] or Navigator.pop fallback).
  final bool isRootPage;

  /// Custom back action. Only used when [isRootPage] is `false`.
  /// Defaults to `Navigator.pop(context)` when null.
  final VoidCallback? onBack;

  /// Custom action for the cart icon tap.
  /// When provided (e.g. from the shell) the cart page is pushed inside the
  /// current tab's navigator so the bottom nav stays visible.
  /// When null, falls back to a root-navigator push.
  final VoidCallback? onCartTap;

  final VoidCallback? onNotificationTap;
  final bool hideCartIcon;

  @override
  final Size preferredSize;

  CustomAppBarDashbord({
    super.key,
    this.title = 'IConnect',
    this.isRootPage = true,
    this.onBack,
    this.onCartTap,
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
      title: BlocBuilder<ButtomNavCubit, NavItem>(
        builder: (context, currentNavItem) {
          return GestureDetector(
            onTap: () {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              final isOnMainScreen = currentRoute == AppRoutes.navigation;

              if (isOnMainScreen && currentNavItem == NavItem.home) return;

              context.read<ButtomNavCubit>().selectItem(NavItem.home);
              context.read<HomeViewCubit>().showHome();

              if (!isOnMainScreen) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.navigation,
                  (route) => false,
                );
              }
            },
            child: Image.asset(
              'assets/iconnect_logo.png',
              height: 25.h,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
      leading:
          isRootPage
              // ── Hamburger menu (root / first page) ─────────────────────────
              ? Builder(
                builder: (BuildContext scaffoldCtx) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: AppPalette.blackColor),
                    onPressed: () => Scaffold.of(scaffoldCtx).openDrawer(),
                    tooltip: 'Menu',
                  );
                },
              )
              // ── Back arrow (second page and beyond) ────────────────────────
              : IconButton(
                tooltip: 'Back',
                onPressed: onBack ?? () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppPalette.blackColor,
                  size: 20,
                ),
              ),
      actions: [
        // Search
        IconButton(
          icon: const Icon(Icons.search, color: AppPalette.blackColor),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchScreen(),
                  fullscreenDialog: true,
                ),
              ),
          tooltip: 'Search',
        ),
        // Cart with badge
        if (!hideCartIcon)
          Builder(
            builder: (BuildContext scaffoldCtx) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppPalette.blackColor,
                    ),
                    onPressed:
                        onCartTap ??
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DetailedCartScreen(),
                          ),
                        ),
                    tooltip: 'Cart',
                  ),
                  BlocBuilder<CartCubit, CartState>(
                    bloc: sl<CartCubit>(),
                    builder: (context, state) {
                      int count = 0;
                      if (state is CartLoaded) {
                        count = state.cart.itemCount;
                      } else if (state is CartOperationInProgress) {
                        count = state.currentCart.itemCount;
                      }
                      if (count == 0) return const SizedBox.shrink();
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
                            '$count',
                            style: TextStyle(
                              color: AppPalette.whiteColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
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
