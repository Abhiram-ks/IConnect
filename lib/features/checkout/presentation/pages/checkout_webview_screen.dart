import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_snackbar.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/core/storage/local_storage_service.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/routes.dart';
import 'package:iconnect/services/coupen_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../cubit/checkout_cubit.dart';

class CheckoutWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final bool showExitConfirmation;

  /// Non-null when a welcome coupon was pre-filled in [checkoutUrl].
  /// After a confirmed purchase we mark it used so it cannot be redeemed again.
  final String? couponCode;

  const CheckoutWebViewScreen({
    super.key,
    required this.checkoutUrl,
    this.showExitConfirmation = true,
    this.couponCode,
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
    log('CheckoutWebViewScreen initialized');
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      // Clear any lingering session cookies for guest / logged-out users so a
      // previous user's data is never pre-filled.
      if (!LocalStorageService.isLoggedIn) {
        await WebViewCookieManager().clearCookies();
        log('CheckoutWebViewScreen: guest session — cleared WebView cookies.');
      }

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

      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(AppPalette.whiteColor);

      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
            log('Page started loading: $url');
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
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

            if (_orderCompleted && _isNavigatingToStore(request.url)) {
              log('Continue shopping detected, navigating to home...');
              _navigateToHome();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(false);
        (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      // Build the final checkout URL.
      // Email is already prefilled in Shopify via the Cart API buyer identity
      // set in CheckoutCubit — no token appending needed here.
      String finalCheckoutUrl = widget.checkoutUrl;

      // Inject email as a query param so Shopify's checkout form pre-fills it.
      final storedEmail = LocalStorageService.email;
      if (storedEmail != null && storedEmail.isNotEmpty) {
        final uri = Uri.parse(finalCheckoutUrl);
        final params = Map<String, String>.from(uri.queryParameters);
        if (!params.containsKey('email')) {
          params['email'] = storedEmail;
          finalCheckoutUrl = uri.replace(queryParameters: params).toString();
          log('Email prefilled in checkout URL for: $storedEmail');
        }
      }

      await controller.loadRequest(Uri.parse(finalCheckoutUrl));

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
    log('CheckoutWebViewScreen disposing');
    super.dispose();
  }

  void _checkForOrderCompletion(String url) {
    if (url.contains('/thank-you') ||
        url.contains('/thank_you') ||
        url.contains('/orders/') ||
        url.contains('checkout_complete')) {
      if (_orderCompleted) return;

      log('Order completed! Thank you page detected: $url');
      _orderCompleted = true;

      sl<CheckoutCubit>().markCheckoutCompleted();
      sl<CartCubit>().clearCart();

      if (widget.couponCode != null) {
        CouponService().markCouponUsed().then((_) {
          log('Coupon ${widget.couponCode} marked as used after purchase');
        }).catchError((e) {
          log('Failed to mark coupon used (non-critical): $e');
        });
      }

      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Order placed successfully! 🎉',
          textAlign: TextAlign.center,
          backgroundColor: AppPalette.greenColor,
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) _navigateToHome();
        });
      }
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    log('Navigating to home page...');
    context.read<ButtomNavCubit>().selectItem(NavItem.home);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.navigation, (route) => false);
  }

  bool _isNavigatingToStore(String url) {
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
      canPop: _isExiting || _orderCompleted || !widget.showExitConfirmation,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_orderCompleted) {
          _navigateToHome();
          return;
        }
        if (widget.showExitConfirmation) {
          _showExitConfirmation();
        } else {
          if (context.mounted) Navigator.of(context).pop();
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
              if (_orderCompleted) {
                _navigateToHome();
                return;
              }
              if (widget.showExitConfirmation) {
                _showExitConfirmation();
                return;
              }
              if (context.mounted) Navigator.of(context).pop();
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
          child: _isInitialized && _controller != null
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
                )
              : Container(
                  color: AppPalette.whiteColor,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppPalette.blueColor),
                        SizedBox(height: 16),
                        Text(
                          'Initializing checkout...',
                          style: TextStyle(fontSize: 16, color: AppPalette.hintColor),
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppPalette.hintColor),
              ),
            ),
            TextButton(
              onPressed: () {
                _isExiting = true;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
