import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/product_entity.dart';

String sanitizeHtml(String html) {
  return html
      // remove all inline style attributes
      .replaceAll(RegExp(r'style="[^"]*"'), '')
      // normalize multiple spaces
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

Widget buildProductDescription(ProductEntity product) {
  // Check if description HTML is empty or null
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(
                minWidth: 1.sw - 32.w, // Full width minus padding
                maxWidth: 2.sw, // Allow wider tables to scroll
              ),
              child: Html(
                data: sanitizeHtml(product.descriptionHtml),
                extensions: const [TableHtmlExtension()],
                style: {
                  "table": Style(
                    width: Width.auto(),
                    border: Border.all(color: Colors.grey.shade300),
                    backgroundColor: Colors.grey.shade50,
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),

                  "tbody": Style(padding: HtmlPaddings.zero),

                  "tr": Style(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),

                  "td": Style(
                    padding: HtmlPaddings.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    alignment: Alignment.centerLeft,
                    fontSize: FontSize(13.sp),
                    lineHeight: LineHeight(1.4),
                    whiteSpace: WhiteSpace.normal,
                  ),

                  "th": Style(
                    padding: HtmlPaddings.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    backgroundColor: Colors.grey.shade200,
                    fontWeight: FontWeight.w600,
                    alignment: Alignment.centerLeft,
                  ),

                  "p": Style(margin: Margins.only(bottom: 8)),

                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(13.sp),
                  ),
                },
              ),
            ),
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
