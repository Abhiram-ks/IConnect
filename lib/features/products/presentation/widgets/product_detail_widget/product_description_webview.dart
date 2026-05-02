import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconnect/services/api_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

const String _heightChannelName = 'ProductDescHeight';

/// Full HTML document: viewport, [base href], and inline RTE-like CSS. Shopify
/// theme stylesheets use versioned URLs, so we approximate storefront typography
/// here; relative `/cdn/...` URLs still resolve via [ApiConfig.storePublicOrigin].
String buildProductDescriptionHtmlDocument(String bodyHtml) {
  final origin = ApiConfig.storePublicOrigin;
  return '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<base href="$origin/">
<style>
html, body {
  margin: 0;
  padding: 0;
  overflow-x: hidden;
  overflow-y: hidden;
  -webkit-text-size-adjust: 100%;
  background: #fff;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-rendering: optimizeLegibility;
}
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  font-size: 14px;
  line-height: 1.6;
  color: #212121;
  word-wrap: break-word;
  -webkit-font-smoothing: antialiased;
}
.rte img { image-rendering: auto; }
.rte, .rte * { box-sizing: border-box; }
.rte { max-width: 100%; }
.rte p { margin: 0 0 12px; }
.rte h1 { font-size: 1.75rem; margin: 16px 0 8px; font-weight: 700; }
.rte h2 { font-size: 1.5rem; margin: 14px 0 8px; font-weight: 700; }
.rte h3 { font-size: 1.25rem; margin: 12px 0 6px; font-weight: 600; }
.rte h4, .rte h5, .rte h6 { margin: 10px 0 6px; font-weight: 600; }
.rte ul, .rte ol { margin: 0 0 12px; padding-left: 22px; }
.rte li { margin-bottom: 6px; }
.rte img, .rte video, .rte iframe { max-width: 100% !important; height: auto !important; }
.rte table { width: 100%; border-collapse: collapse; margin: 0 0 16px; font-size: 13px; }
.rte th, .rte td { border: 1px solid #e0e0e0; padding: 10px 12px; vertical-align: top; }
.rte th { background: #e8e8e8; font-weight: 700; }
.rte tr:nth-child(even) td { background: #fafafa; }
.rte a { color: #1565c0; word-break: break-all; }
.rte blockquote { margin: 12px 0; padding-left: 12px; border-left: 3px solid #bdbdbd; font-style: italic; }
.rte code { background: #f5f5f5; padding: 2px 4px; font-family: ui-monospace, monospace; font-size: 0.9em; }
.rte pre { background: #f5f5f5; padding: 10px; overflow-x: auto; margin: 0 0 12px; }
</style>
</head>
<body>
<div class="rte">$bodyHtml</div>
</body>
</html>
''';
}

/// WebView sized to content height for embedding in [SingleChildScrollView].
class ProductDescriptionWebView extends StatefulWidget {
  const ProductDescriptionWebView({
    super.key,
    required this.bodyHtml,
    this.baseUrl = ApiConfig.storePublicOrigin,
  });

  final String bodyHtml;
  final String baseUrl;

  @override
  State<ProductDescriptionWebView> createState() =>
      _ProductDescriptionWebViewState();
}

double _snapHeightToDevicePixels(double logicalHeight, double devicePixelRatio) {
  if (devicePixelRatio <= 0) return logicalHeight;
  return (logicalHeight * devicePixelRatio).round() / devicePixelRatio;
}

class _ProductDescriptionWebViewState extends State<ProductDescriptionWebView> {
  WebViewController? _controller;
  double _height = 180;
  bool _initialDocumentLoaded = false;
  static const double _minHeight = 120;
  static const double _paddingBuffer = 8;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(ProductDescriptionWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bodyHtml != widget.bodyHtml ||
        oldWidget.baseUrl != widget.baseUrl) {
      setState(() => _height = 180);
      _loadContent();
    }
  }

  String get _normalizedBaseUrl =>
      widget.baseUrl.endsWith('/') ? widget.baseUrl : '${widget.baseUrl}/';

  bool _isBaseUrlNavigation(String url) {
    final normalized = _normalizedBaseUrl;
    final stripped = normalized.substring(0, normalized.length - 1);
    return url == normalized || url == stripped;
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    if (!request.isMainFrame) {
      return NavigationDecision.navigate;
    }
    final url = request.url;
    if (url == 'about:blank') {
      return NavigationDecision.navigate;
    }

    // iOS (WKWebView) fires the navigation delegate for `loadHtmlString`'s
    // baseUrl as part of the initial document load. Android's WebView skips
    // `shouldOverrideUrlLoading` for that initial `loadDataWithBaseURL`, so the
    // bug only manifests on iOS: the base URL gets treated like an outbound
    // link and opened in Safari, leaving the description blank. Allow the
    // initial base-URL navigation to proceed in-place; user-initiated taps
    // after the page has finished loading still get routed externally.
    if (!_initialDocumentLoaded && _isBaseUrlNavigation(url)) {
      return NavigationDecision.navigate;
    }

    final uri = Uri.tryParse(url);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _initController() async {
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

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        _heightChannelName,
        onMessageReceived: (JavaScriptMessage message) {
          final parsed = double.tryParse(message.message);
          if (!mounted || parsed == null) return;
          final mq = MediaQuery.of(context);
          final maxH = mq.size.height * 6;
          final raw = parsed.clamp(_minHeight, maxH) + _paddingBuffer;
          final h = _snapHeightToDevicePixels(raw, mq.devicePixelRatio);
          if ((h - _height).abs() > 0.5) {
            setState(() => _height = h);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigation,
          onPageFinished: (_) => _onPageFinished(),
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      await (controller.platform as AndroidWebViewController).setTextZoom(100);
    }

    _controller = controller;
    await _loadContent();
    if (mounted) setState(() {});
  }

  Future<void> _loadContent() async {
    final c = _controller;
    if (c == null) return;
    _initialDocumentLoaded = false;
    final doc = buildProductDescriptionHtmlDocument(widget.bodyHtml);
    await c.loadHtmlString(doc, baseUrl: _normalizedBaseUrl);
  }

  String get _reportHeightScript => '''
(function() {
  function report() {
    var b = document.body, e = document.documentElement;
    var h = Math.max(
      b.scrollHeight, e.scrollHeight,
      b.offsetHeight, e.offsetHeight,
      b.clientHeight, e.clientHeight
    );
    $_heightChannelName.postMessage(String(Math.ceil(h)));
  }
  report();
  if (window.ResizeObserver) {
    new ResizeObserver(report).observe(document.body);
  }
  window.addEventListener('load', report);
  var imgs = document.images;
  for (var i = 0; i < imgs.length; i++) {
    imgs[i].addEventListener('load', report);
    imgs[i].addEventListener('error', report);
  }
})();
''';

  Future<void> _onPageFinished() async {
    _initialDocumentLoaded = true;
    final c = _controller;
    if (c == null || !mounted) return;
    try {
      await c.runJavaScript(_reportHeightScript);
    } catch (_) {}
  }

  Widget _platformWebViewWidget(WebViewController c, BuildContext context) {
    final base = PlatformWebViewWidgetCreationParams(
      controller: c.platform,
      layoutDirection: Directionality.of(context),
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );

    final PlatformWebViewWidgetCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      // Texture-based Android WebViews often look soft/blurry on high-DPI screens;
      // hybrid composition rasterizes at full resolution (tradeoff: some cost).
      params = AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
        base,
        displayWithHybridComposition: true,
      );
    } else if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
        base,
      );
    } else {
      params = base;
    }

    return WebViewWidget.fromPlatformCreationParams(params: params);
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    if (c == null) {
      final h = _snapHeightToDevicePixels(_minHeight, dpr);
      return SizedBox(
        height: h,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final snapped = _snapHeightToDevicePixels(_height, dpr);
    return SizedBox(
      height: snapped,
      child: _platformWebViewWidget(c, context),
    );
  }
}
