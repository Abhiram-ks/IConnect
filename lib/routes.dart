import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/screens/nav_screen.dart';
import 'package:iconnect/screens/product_details_screen.dart';
import 'package:iconnect/screens/banner_details_screen.dart';
import 'package:iconnect/screens/test_shopify_products.dart';
import 'package:iconnect/screens/collection_products_screen.dart';
import 'package:iconnect/features/products/presentation/pages/brand_details_page.dart';
import 'package:iconnect/features/auth/presentation/pages/register_screen.dart';
import 'package:iconnect/features/auth/presentation/pages/signup_screen.dart';
import 'package:iconnect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:iconnect/features/profile/presentation/pages/profile_page.dart';
import 'package:iconnect/features/orders/presentation/pages/orders_page.dart';
import 'package:iconnect/core/di/service_locator.dart';

import 'constant/constant.dart';

class AppRoutes {
  static const String navigation = '/';
  static const String login = '/login_screen';
  static const String signup = '/signup_screen';
  static const String profile = '/profile';
  static const String orders = '/orders';
  static const String dashbord = '/dashbord_screen';
  static const String pdiform = '/PdiformScreen';
  static const String createuser = '/createuser_screen';
  static const String tabbarExample = '/tabbar_example';
  static const String productDetails = '/product_details';
  static const String bannerDetails = '/banner_details';
  static const String collectionProducts = '/collection_products';
  static const String brandDetails = '/brand_details';
  static const String testShopify = '/test-shopify-products';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case navigation:
        return MaterialPageRoute(
          builder: (context) => BottomNavigationControllers(),
        );
      case productDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        // Support both productHandle (new) and productId (old for backward compatibility)
        final productHandle = args?['productHandle'] as String?;
        final productId = args?['productId'] as int?;

        // If productHandle is provided, use it; otherwise convert productId to handle
        final handle = productHandle ?? 'product-$productId';

        return MaterialPageRoute(
          settings: RouteSettings(name: '$productDetails/$handle'),
          builder:
              (context) => ProductDetailsScreen(
                key: ValueKey(handle),
                productHandle: handle,
              ),
        );
      case bannerDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final bannerTitle =
            args?['bannerTitle'] as String? ?? 'Featured Products';
        final bannerProducts =
            args?['bannerProducts'] as List<Map<String, dynamic>>? ?? [];
        return MaterialPageRoute(
          builder:
              (context) => BannerDetailsScreen(
                bannerTitle: bannerTitle,
                bannerProducts: bannerProducts,
              ),
        );
      case collectionProducts:
        final args = settings.arguments as Map<String, dynamic>?;
        final collectionHandle = args?['collectionHandle'] as String? ?? '';
        final collectionTitle =
            args?['collectionTitle'] as String? ?? 'Products';
        return MaterialPageRoute(
          builder:
              (context) => CollectionProductsScreen(
                collectionHandle: collectionHandle,
                collectionTitle: collectionTitle,
              ),
        );
      case brandDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final brandId = args?['brandId'] as int? ?? 0;
        final brandName = args?['brandName'] as String? ?? 'Brand';
        final brandVendor = args?['brandVendor'] as String? ?? '';
        final brandImageUrl = args?['brandImageUrl'] as String? ?? '';
        return MaterialPageRoute(
          builder:
              (context) => BrandDetailsPage(
                brandId: brandId,
                brandName: brandName,
                brandVendor: brandVendor,
                brandImageUrl: brandImageUrl,
              ),
        );
      case testShopify:
        return MaterialPageRoute(
          builder: (context) => const TestShopifyProductsScreen(),
        );
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case signup:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider.value(
                value: sl<AuthCubit>(),
                child: const SignupScreen(),
              ),
        );
      case profile:
        return MaterialPageRoute(builder: (context) => const ProfilePage());
      case orders:
        return MaterialPageRoute(builder: (context) => const OrdersPage());
      case dashbord:
      //    return MaterialPageRoute(builder: (context) => const DashboardScreen());
      case pdiform:
      //  return MaterialPageRoute(builder: (context) => const PdiformScreen());

      default:
        return MaterialPageRoute(
          builder:
              (_) => LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;

                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * .04,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Page Not Found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ConstantWidgets.hight20(context),
                            Text(
                              'The page you were looking for could not be found. '
                              'It might have been removed, renamed, or does not exist.',
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: TextStyle(fontSize: 16, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        );
    }
  }
}
