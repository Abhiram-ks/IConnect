import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/product_entity.dart';
import 'product_description_webview.dart';

/// Product description: WebView with real HTML/CSS layout on native targets
/// (auto height for [SingleChildScrollView]); [Html] fallback on web where
/// embedded WebViews are weaker.
Widget buildProductDescription(ProductEntity product, BuildContext context) {
  final hasDescription = product.descriptionHtml.trim().isNotEmpty;

  return Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Description',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        if (hasDescription)
          kIsWeb
              ? _productDescriptionHtmlFallback(product.descriptionHtml)
              : ProductDescriptionWebView(
                  key: ValueKey(product.id),
                  bodyHtml: product.descriptionHtml,
                )
        else
          Text(
            'No description available',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    ),
  );
}

Widget _productDescriptionHtmlFallback(String descriptionHtml) {
  return Html(
    data: descriptionHtml,
    extensions: const [TableHtmlExtension()],
    style: {
      '*': Style(
        fontFamily: GoogleFonts.poppins().fontFamily,
        color: Colors.black87,
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
        color: Colors.blue.shade700,
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
    onLinkTap: (url, attributes, element) {
      if (url != null) {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    },
  );
}
