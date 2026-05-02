import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/services/graphql_base_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders a Shopify Online Store page (About Us, Privacy Policy, etc.) using
/// the Storefront API. Only the page body is fetched — none of the storefront
/// theme chrome (header, nav, footer) — so the screen looks native instead of
/// like a website embedded in a webview.
class ShopifyPageScreen extends StatefulWidget {
  /// Title shown in the AppBar before the page loads. Once the API responds
  /// the AppBar updates to the page's own title.
  final String title;

  /// Shopify page handle, e.g. `about-us`, `contact`, `privacy-policy`.
  final String handle;

  const ShopifyPageScreen({
    super.key,
    required this.title,
    required this.handle,
  });

  @override
  State<ShopifyPageScreen> createState() => _ShopifyPageScreenState();
}

class _ShopifyPageScreenState extends State<ShopifyPageScreen> {
  bool _isLoading = true;
  String? _error;
  String? _pageTitle;
  String? _bodyHtml;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final service = sl<ShopifyGraphQLService>();

      // Fast path: try the handle the caller provided.
      Map<String, dynamic>? page = _extractPage(
        await service.getPageByHandle(widget.handle),
      );

      // Self-healing fallback: if the merchant named the page differently in
      // Shopify Admin (e.g. `contact-us` vs `contact`, `service` vs `services`)
      // the direct lookup returns null. Fetch the full page list and pick the
      // best match by title — this is what makes Contact / Service work even
      // though their handles don't match the URL slugs.
      if (_isUnusable(page)) {
        page = _findByTitle(await service.getAllPages());
      }

      if (!mounted) return;

      if (_isUnusable(page)) {
        setState(() {
          _isLoading = false;
          _error =
              'This page is not available right now. Please try again later.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _pageTitle = page!['title'] as String?;
        _bodyHtml = (page['body'] as String?)?.trim();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Unable to load this page. Please check your connection.';
      });
    }
  }

  Map<String, dynamic>? _extractPage(Map<String, dynamic> response) {
    return response['page'] as Map<String, dynamic>?;
  }

  bool _isUnusable(Map<String, dynamic>? page) {
    if (page == null) return true;
    final body = (page['body'] as String?)?.trim() ?? '';
    return body.isEmpty;
  }

  /// Picks the best matching page from `pages` by comparing handles and titles
  /// to [widget.handle] / [widget.title]. Tolerates spaces, dashes, ampersands,
  /// "&" vs "and", etc. so common naming variations all resolve correctly.
  Map<String, dynamic>? _findByTitle(Map<String, dynamic> response) {
    final pages = (response['pages'] as Map<String, dynamic>?)?['edges']
        as List?;
    if (pages == null || pages.isEmpty) return null;

    final targetHandle = _normalize(widget.handle);
    final targetTitle = _normalize(widget.title);

    final candidates = pages
        .map((e) => (e as Map<String, dynamic>)['node'] as Map<String, dynamic>)
        .where((p) {
          final body = (p['body'] as String?)?.trim() ?? '';
          return body.isNotEmpty;
        })
        .toList();

    int score(Map<String, dynamic> page) {
      final handle = _normalize(page['handle'] as String? ?? '');
      final title = _normalize(page['title'] as String? ?? '');
      if (handle == targetHandle || title == targetTitle) return 100;
      if (handle.contains(targetHandle) || targetHandle.contains(handle)) {
        return 75;
      }
      if (title.contains(targetTitle) || targetTitle.contains(title)) {
        return 50;
      }
      return 0;
    }

    candidates.sort((a, b) => score(b).compareTo(score(a)));
    final best = candidates.isEmpty ? null : candidates.first;
    if (best == null || score(best) == 0) return null;
    return best;
  }

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.whiteColor,
      appBar: AppBar(
        title: Text(
          _pageTitle ?? widget.title,
          style: const TextStyle(
            color: AppPalette.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppPalette.whiteColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppPalette.blackColor),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppPalette.blueColor),
      );
    }

    if (_error != null) {
      return _buildError(_error!);
    }

    final body = _bodyHtml;
    if (body == null || body.isEmpty) {
      return _buildEmpty();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      child: _buildHtml(body),
    );
  }

  Widget _buildHtml(String html) {
    return Html(
      data: html,
      extensions: const [TableHtmlExtension()],
      onLinkTap: (url, _, __) {
        if (url == null || url.isEmpty) return;
        final uri = Uri.tryParse(url);
        if (uri == null) return;
        launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      style: {
        '*': Style(
          fontFamily: GoogleFonts.poppins().fontFamily,
          color: AppPalette.blackColor,
          fontSize: FontSize(13.sp),
        ),
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        'p': Style(
          fontSize: FontSize(13.sp),
          lineHeight: LineHeight(1.65),
          margin: Margins.only(bottom: 12),
        ),
        'h1': Style(
          fontSize: FontSize(20.sp),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 16, bottom: 8),
          color: const Color(0xFF212121),
        ),
        'h2': Style(
          fontSize: FontSize(18.sp),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 14, bottom: 8),
          color: const Color(0xFF212121),
        ),
        'h3': Style(
          fontSize: FontSize(16.sp),
          fontWeight: FontWeight.w600,
          margin: Margins.only(top: 12, bottom: 6),
          color: const Color(0xFF212121),
        ),
        'h4': Style(
          fontSize: FontSize(15.sp),
          fontWeight: FontWeight.w600,
          margin: Margins.only(top: 10, bottom: 6),
        ),
        'h5': Style(
          fontSize: FontSize(14.sp),
          fontWeight: FontWeight.w600,
          margin: Margins.only(top: 8, bottom: 4),
        ),
        'h6': Style(
          fontSize: FontSize(13.sp),
          fontWeight: FontWeight.w600,
          margin: Margins.only(top: 8, bottom: 4),
        ),
        'ul': Style(
          margin: Margins.only(bottom: 12, left: 4),
          padding: HtmlPaddings.only(left: 18),
        ),
        'ol': Style(
          margin: Margins.only(bottom: 12, left: 4),
          padding: HtmlPaddings.only(left: 18),
        ),
        'li': Style(
          fontSize: FontSize(13.sp),
          lineHeight: LineHeight(1.55),
          margin: Margins.only(bottom: 6),
          display: Display.listItem,
        ),
        'a': Style(
          color: AppPalette.blueColor,
          textDecoration: TextDecoration.underline,
        ),
        'strong': Style(fontWeight: FontWeight.bold),
        'b': Style(fontWeight: FontWeight.bold),
        'em': Style(fontStyle: FontStyle.italic),
        'i': Style(fontStyle: FontStyle.italic),
        'div': Style(margin: Margins.only(bottom: 8)),
        'span': Style(fontSize: FontSize(13.sp)),
        'br': Style(height: Height(8)),
        'blockquote': Style(
          margin: Margins.symmetric(vertical: 8, horizontal: 0),
          padding: HtmlPaddings.only(left: 12),
          border: const Border(
            left: BorderSide(color: Color(0xFFBDBDBD), width: 3),
          ),
          fontStyle: FontStyle.italic,
        ),
        'code': Style(
          backgroundColor: const Color(0xFFF5F5F5),
          padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
          fontFamily: 'monospace',
        ),
        'pre': Style(
          backgroundColor: const Color(0xFFF5F5F5),
          padding: HtmlPaddings.all(10),
          margin: Margins.only(bottom: 12),
        ),
        'img': Style(
          width: Width(100, Unit.percent),
          height: Height.auto(),
          display: Display.block,
          margin: Margins.symmetric(vertical: 8),
        ),
        'table': Style(
          width: Width(100, Unit.percent),
          margin: Margins.only(bottom: 16),
        ),
        'th': Style(
          backgroundColor: const Color(0xFFE0E0E0),
          fontWeight: FontWeight.bold,
          padding: HtmlPaddings.symmetric(horizontal: 10, vertical: 10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        'td': Style(
          padding: HtmlPaddings.symmetric(horizontal: 10, vertical: 10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          'There is nothing to show on this page yet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppPalette.greyColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
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
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppPalette.blackColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _load,
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
