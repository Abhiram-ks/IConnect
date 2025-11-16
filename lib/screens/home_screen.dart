// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:iconnect/features/products/presentation/pages/home_page.dart';

/// Home Screen - Wrapper for HomePage
/// This file maintains backward compatibility
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
