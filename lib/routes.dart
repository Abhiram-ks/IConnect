
import 'package:flutter/material.dart';
import 'package:iconnect/screens/nav_screen.dart';
import 'package:iconnect/screens/product_details_screen.dart';

import 'constant/constant.dart';

class AppRoutes {
  static const String navigation = '/';
  static const String login  = '/login_screen';
  static const String dashbord   = '/dashbord_screen';
  static const String pdiform = '/PdiformScreen';
  static const String createuser = '/createuser_screen';
  static const String tabbarExample = '/tabbar_example';
  static const String productDetails = '/product_details';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case navigation:
       return MaterialPageRoute(builder: (context) =>  BottomNavigationControllers());
      case productDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final productId = args?['productId'] as int? ?? 1;
        return MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(productId: productId),
        );
      case login:
     //   return MaterialPageRoute(builder: (context) => const LoginScreen());
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
