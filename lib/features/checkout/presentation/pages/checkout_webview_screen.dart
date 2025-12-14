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
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../cubit/checkout_cubit.dart';

class CheckoutWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final bool showExitConfirmation;
  final String? customerAccessToken;

  const CheckoutWebViewScreen({
    super.key,
    required this.checkoutUrl,
    this.showExitConfirmation = true,
    this.customerAccessToken,
  });

  @override
  State<CheckoutWebViewScreen> createState() => _CheckoutWebViewScreenState();
}

class _CheckoutWebViewScreenState extends State<CheckoutWebViewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _orderCompleted = false;
  bool _isInitialized = false;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    log(
      'CheckoutWebViewScreen initialized with showExitConfirmation: ${widget.showExitConfirmation}',
    );
    log(
      'Customer Access Token: ${widget.customerAccessToken != null ? "Present" : "Not present"}',
    );
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      // Create platform-specific parameters for better performance
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
        params = AndroidWebViewControllerCreationParams();
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      final controller = WebViewController.fromPlatformCreationParams(params);

      // Configure controller
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(AppPalette.whiteColor);

      // Set navigation delegate
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
            log('Page started loading: $url');
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
            log('Page finished loading: $url');
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

            // Add authentication to all navigation requests
            if (widget.customerAccessToken != null &&
                widget.customerAccessToken!.isNotEmpty &&
                !request.url.contains('customer_access_token')) {
              log('Adding authentication to navigation: ${request.url}');

              // Parse URL and add token
              final uri = Uri.parse(request.url);
              final queryParams = Map<String, String>.from(uri.queryParameters);
              queryParams['customer_access_token'] =
                  widget.customerAccessToken!;
              final authenticatedUrl =
                  uri.replace(queryParameters: queryParams).toString();

              // Load the authenticated URL instead
              _controller?.loadRequest(
                Uri.parse(authenticatedUrl),
                headers: {
                  'X-Shopify-Customer-Access-Token':
                      widget.customerAccessToken!,
                },
              );

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

      // Enable platform-specific features
      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(false);
        (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      // Build the final checkout URL with authentication
      String finalCheckoutUrl = widget.checkoutUrl;

      if (widget.customerAccessToken != null &&
          widget.customerAccessToken!.isNotEmpty) {
        log('Loading checkout with authentication');

        // Add customer_access_token as URL parameter
        // This is the most reliable method for Shopify checkout authentication
        final uri = Uri.parse(widget.checkoutUrl);
        final queryParams = Map<String, String>.from(uri.queryParameters);
        queryParams['customer_access_token'] = widget.customerAccessToken!;

        finalCheckoutUrl = uri.replace(queryParameters: queryParams).toString();
        log('Final checkout URL prepared with authentication');

        // Load with header for additional authentication
        await controller.loadRequest(
          Uri.parse(finalCheckoutUrl),
          headers: {
            'X-Shopify-Customer-Access-Token': widget.customerAccessToken!,
          },
        );
      } else {
        log('Loading checkout without authentication (guest checkout)');
        await controller.loadRequest(Uri.parse(finalCheckoutUrl));
      }

      // Set controller and mark as initialized
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
      }
    } catch (e) {
      log('Error initializing webview: $e');
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Failed to load checkout',
          textAlign: TextAlign.center,
          backgroundColor: AppPalette.redColor,
        );
      }
    }
  }

  @override
  void dispose() {
    // Clean up to prevent memory leaks
    log('CheckoutWebViewScreen disposing');
    super.dispose();
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
    return PopScope(
      canPop:
          _isExiting ||
          _orderCompleted ||
          !widget
              .showExitConfirmation, // Allow pop if exiting, order completed, or no confirmation needed
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // If order is completed, navigate to home
        if (_orderCompleted) {
          _navigateToHome();
          return;
        }

        // Check if we should show confirmation
        if (widget.showExitConfirmation) {
          _showExitConfirmation();
        } else {
          // Just close
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
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
            onPressed: () async {
              log(
                'Close button pressed. showExitConfirmation: ${widget.showExitConfirmation}, orderCompleted: $_orderCompleted',
              );

              // If order is completed, navigate to home directly without confirmation
              if (_orderCompleted) {
                log('Navigating to home (order completed)');
                _navigateToHome();
                return;
              }

              // If exit confirmation is enabled, show dialog
              if (widget.showExitConfirmation) {
                log('Showing exit confirmation dialog');
                _showExitConfirmation();
                return;
              }

              // Otherwise just close directly
              log('Closing webview directly (no confirmation)');
              if (context.mounted) {
                Navigator.of(context).pop();
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
          child:
              _isInitialized && _controller != null
                  ? Stack(
                    children: [
                      WebViewWidget(controller: _controller!),
                      if (_isLoading)
                        Container(
                          color: AppPalette.whiteColor,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: AppPalette.blueColor,
                                ),
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
                  )
                  : Container(
                    color: AppPalette.whiteColor,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppPalette.blueColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Initializing checkout...',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppPalette.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                _isExiting =
                    true; // Set flag before exiting (no setState needed)
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
