import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Generic in-app browser. Renders [url] inside a WebView so the user stays in
/// the app on both Android and iOS instead of being kicked out to Safari/Chrome.
class InAppWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const InAppWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final uri = Uri.tryParse(widget.url);
    if (uri == null) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
      return;
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppPalette.whiteColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            // Ignore subresource errors (images, scripts) so a single broken
            // asset doesn't replace the whole page with the error view.
            if (!mounted || error.isForMainFrame == false) return;
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
    }

    await controller.loadRequest(uri);

    if (mounted) {
      setState(() => _controller = controller);
    }
  }

  Future<void> _reload() async {
    final c = _controller;
    if (c == null) {
      await _initWebView();
      return;
    }
    if (mounted) {
      setState(() {
        _hasError = false;
        _isLoading = true;
      });
    }
    await c.reload();
  }

  Future<bool> _handleBack() async {
    final c = _controller;
    if (c != null && await c.canGoBack()) {
      await c.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _handleBack();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppPalette.whiteColor,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(
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
              final shouldPop = await _handleBack();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: _hasError ? _buildError() : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final c = _controller;
    return Stack(
      children: [
        if (c != null) WebViewWidget(controller: c),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppPalette.blueColor),
          ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppPalette.redColor,
              size: 48.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              'Unable to load page',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.blackColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'Please check your connection and try again.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppPalette.greyColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.blueColor,
                foregroundColor: AppPalette.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
