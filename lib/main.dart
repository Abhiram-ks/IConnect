import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconnect/app_theme.dart';
import 'package:iconnect/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.black, 
            systemNavigationBarColor: Colors.black, 
            statusBarIconBrightness: Brightness.light, 
            systemNavigationBarIconBrightness: Brightness.light,
          ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'I Connect',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.navigation,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}