import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_snackbar.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/routes.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../cubit/checkout_cubit.dart';

class CheckoutWebViewScreen extends StatefulWidget {
  final String checkoutUrl;

  const CheckoutWebViewScreen({super.key, required this.checkoutUrl});

  @override
  State<CheckoutWebViewScreen> createState() => _CheckoutWebViewScreenState();
}

class _CheckoutWebViewScreenState extends State<CheckoutWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _orderCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(AppPalette.whiteColor)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  _isLoading = true;
                });
                log('Page started loading: $url');
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
                log('Page finished loading: $url');

                // Check if user reached the thank you page
                _checkForOrderCompletion(url);
              },
              onWebResourceError: (WebResourceError error) {
                log('WebView error: ${error.description}');
                if (mounted) {
                  CustomSnackBar.show(
                    context,
                    message: 'Error loading checkout page',
                    textAlign: TextAlign.center,
                    backgroundColor: AppPalette.redColor,
                  );
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                log('Navigation request: ${request.url}');

                // Detect if user is navigating back to store (Continue Shopping)
                if (_orderCompleted && _isNavigatingToStore(request.url)) {
                  log('Continue shopping detected, navigating to home...');
                  _navigateToHome();
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _checkForOrderCompletion(String url) {
    // Check if the URL contains "thank-you" or "thank_you" or "orders" which indicates order completion
    if (url.contains('/thank-you') ||
        url.contains('/thank_you') ||
        url.contains('/orders/') ||
        url.contains('checkout_complete')) {
      // Only process once to avoid multiple triggers
      if (_orderCompleted) return;

      log('Order completed! Thank you page detected: $url');
      _orderCompleted = true;

      // Mark checkout as completed
      sl<CheckoutCubit>().markCheckoutCompleted();

      // Clear the cart since order is placed
      sl<CartCubit>().clearCart();

      // Show success message and navigate to home immediately
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Order placed successfully! 🎉',
          textAlign: TextAlign.center,
          backgroundColor: AppPalette.greenColor,
        );

        // Navigate to home immediately after order completion
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _navigateToHome();
          }
        });
      }
    }
  }

  void _navigateToHome() {
    if (!mounted) return;

    log('Navigating to home page...');

    // Navigate to home and reset navigation stack
    context.read<ButtomNavCubit>().selectItem(NavItem.home);

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.navigation, (route) => false);
  }

  bool _isNavigatingToStore(String url) {
    // Check if URL is navigating back to the main store
    // Common patterns for "Continue Shopping" button

    // Extract base domain
    final checkoutUri = Uri.parse(widget.checkoutUrl);
    final baseUrl = '${checkoutUri.scheme}://${checkoutUri.host}';

    return url == baseUrl ||
        url == '$baseUrl/' ||
        url.contains('/collections') ||
        url.contains('/products') ||
        url.contains('/pages/') ||
        (url.startsWith(baseUrl) &&
            !url.contains('/checkouts/') &&
            !url.contains('/thank-you') &&
            !url.contains('/thank_you') &&
            !url.contains('/orders/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: AppPalette.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppPalette.whiteColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppPalette.blackColor),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // If order is completed, navigate to home directly without confirmation
            if (_orderCompleted) {
              _navigateToHome();
            } else {
              _showExitConfirmation();
            }
          },
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppPalette.blueColor,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: BlocListener<CheckoutCubit, CheckoutState>(
        bloc: sl<CheckoutCubit>(),
        listener: (context, state) {
          if (state is CheckoutCompleted) {
            log('Checkout completed state received');
          }
        },
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: AppPalette.whiteColor,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppPalette.blueColor),
                      SizedBox(height: 16),
                      Text(
                        'Loading checkout...',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppPalette.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Checkout?'),
          content: const Text(
            'Are you sure you want to exit? Your items will remain in the cart.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppPalette.hintColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Exit webview
              },
              child: const Text(
                'Exit',
                style: TextStyle(color: AppPalette.redColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
