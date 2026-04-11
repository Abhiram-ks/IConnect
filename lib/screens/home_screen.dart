import 'package:flutter/material.dart';
import 'package:iconnect/features/products/presentation/pages/home_page.dart';
import 'package:iconnect/mixins/version_check_mixin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, VersionCheckMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    checkAppVersion(); // ← call this
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const HomePage();
  }
}
