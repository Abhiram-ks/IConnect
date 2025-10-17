import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_theme.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/cubit/home_view_cubit/home_view_cubit.dart';
import 'package:iconnect/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CartCubit()),
        BlocProvider(create: (context) => ButtomNavCubit()),
        BlocProvider(create: (context) => HomeViewCubit()),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
      ),
    );
  }
}
