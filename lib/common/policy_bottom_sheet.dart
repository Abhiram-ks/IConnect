import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/services/graphql_base_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PolicyBottomSheet {
  static void showPrivacyPolicy(BuildContext context) {
    _showPolicySheet(
      context,
      title: 'Privacy Policy',
      policyKey: 'privacyPolicy',
    );
  }

  static void showTermsAndConditions(BuildContext context) {
    _showPolicySheet(
      context,
      title: 'Terms and Conditions',
      policyKey: 'termsOfService',
    );
  }

  static void _showPolicySheet(
    BuildContext context, {
    required String title,
    required String policyKey,
  }) {
    final service = ShopifyGraphQLService();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: AppPalette.whiteColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: _fetchPolicyData(service),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      final errorMessage = snapshot.error.toString();
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Unable to load $title',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please check your internet connection and try again.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Error: $errorMessage',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.data == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'No data available.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }

                    final shopData = snapshot.data!;
                    final policy = shopData[policyKey];
                    
                    
                    if (policy == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                '$title is not available',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This policy has not been configured in your Shopify store yet.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Please configure it in Shopify Admin > Settings > Policies',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final policyBody = policy['body'];
                    
                    if (policyBody == null || policyBody.toString().isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                '$title is empty',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please add content to this policy in your Shopify admin.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    String htmlContent = policyBody.toString();
                    htmlContent = _replaceLiquidVariables(htmlContent, shopData);

                    return SingleChildScrollView(
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Html(
                          data: htmlContent,
                          style: {
                            "*": Style(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              color: Colors.black87,
                              textAlign: TextAlign.left,
                            ),
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                            "p": Style(
                              fontSize: FontSize(14),
                              lineHeight: LineHeight(1.7),
                              margin: Margins.only(bottom: 16),
                              textAlign: TextAlign.justify,
                            ),
                            "h1": Style(
                              fontSize: FontSize(22),
                              fontWeight: FontWeight.bold,
                              margin: Margins.only(top: 20, bottom: 12),
                              color: Colors.black,
                            ),
                            "h2": Style(
                              fontSize: FontSize(20),
                              fontWeight: FontWeight.bold,
                              margin: Margins.only(top: 18, bottom: 10),
                              color: Colors.black,
                            ),
                            "h3": Style(
                              fontSize: FontSize(18),
                              fontWeight: FontWeight.w600,
                              margin: Margins.only(top: 16, bottom: 8),
                              color: Colors.black,
                            ),
                            "h4": Style(
                              fontSize: FontSize(16),
                              fontWeight: FontWeight.w600,
                              margin: Margins.only(top: 14, bottom: 8),
                              color: Colors.black,
                            ),
                            "h5": Style(
                              fontSize: FontSize(15),
                              fontWeight: FontWeight.w600,
                              margin: Margins.only(top: 12, bottom: 6),
                              color: Colors.black,
                            ),
                            "h6": Style(
                              fontSize: FontSize(14),
                              fontWeight: FontWeight.w600,
                              margin: Margins.only(top: 10, bottom: 6),
                              color: Colors.black,
                            ),
                            "ul": Style(
                              margin: Margins.only(bottom: 16, left: 8),
                              padding: HtmlPaddings.only(left: 20),
                            ),
                            "ol": Style(
                              margin: Margins.only(bottom: 16, left: 8),
                              padding: HtmlPaddings.only(left: 20),
                            ),
                            "li": Style(
                              fontSize: FontSize(14),
                              lineHeight: LineHeight(1.6),
                              margin: Margins.only(bottom: 8),
                              display: Display.block,
                            ),
                            "a": Style(
                              color: Colors.blue[700],
                              textDecoration: TextDecoration.underline,
                            ),
                            "strong": Style(
                              fontWeight: FontWeight.bold,
                            ),
                            "b": Style(
                              fontWeight: FontWeight.bold,
                            ),
                            "em": Style(
                              fontStyle: FontStyle.italic,
                            ),
                            "i": Style(
                              fontStyle: FontStyle.italic,
                            ),
                            "div": Style(
                              margin: Margins.only(bottom: 12),
                            ),
                            "span": Style(
                              fontSize: FontSize(14),
                            ),
                            "br": Style(
                              margin: Margins.only(bottom: 8),
                            ),
                          },
                          onLinkTap: (url, attributes, element) {
                            if (url != null) {
                              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<Map<String, dynamic>?> _fetchPolicyData(ShopifyGraphQLService service) async {
    try {
      final result = await service.getShopPolicies();
      
      if (result.containsKey('shop') && result['shop'] != null) {
        final shopData = result['shop'] as Map<String, dynamic>;
        return shopData;
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }

  static String _replaceLiquidVariables(String html, Map<String, dynamic> shopData) {
    final shopName = shopData['name']?.toString() ?? 'Our Shop';
    
    String shopDomain = 'shop.example.com';
    if (shopData['primaryDomain'] != null) {
      final domainUrl = shopData['primaryDomain']['url']?.toString() ?? '';
      shopDomain = domainUrl
          .replaceAll('https://', '')
          .replaceAll('http://', '')
          .replaceAll('/', '');
    }
    
    final now = DateTime.now();
    final monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 
                        'July', 'August', 'September', 'October', 'November', 'December'];
    final lastUpdatedLong = '${monthNames[now.month - 1]} ${now.day}, ${now.year}';
    
    String result = html;
    
    // Step 1: Remove all Liquid control flow tags (if/endif/else/elsif/for/endfor/case/when/unless/etc)
    // Remove {% if condition %} blocks and their content based on common conditions
    result = _processLiquidConditionals(result);
    
    // Step 2: Remove remaining Liquid tags (comments, raw, etc)
    result = result.replaceAll(RegExp(r'\{%\s*comment\s*%\}.*?\{%\s*endcomment\s*%\}', dotAll: true), '');
    result = result.replaceAll(RegExp(r'\{%\s*raw\s*%\}.*?\{%\s*endraw\s*%\}', dotAll: true), '');
    result = result.replaceAll(RegExp(r'\{%-?\s*\w+.*?-?%\}'), '');
    
    // Step 3: Replace variable outputs {{ variable }}
    final replacements = {
      '{{ shop.name }}': shopName,
      '{{ shop_name }}': shopName,
      '{{shop.name}}': shopName,
      '{{shop_name}}': shopName,
      
      '{{ shop.domain }}': shopDomain,
      '{{ shop_domain }}': shopDomain,
      '{{shop.domain}}': shopDomain,
      '{{shop_domain}}': shopDomain,
      '{{ domain }}': shopDomain,
      '{{domain}}': shopDomain,
      
      '{{ shop.url }}': 'https://$shopDomain',
      '{{shop.url}}': 'https://$shopDomain',
      
      '{{ last_updated }}': lastUpdatedLong,
      '{{last_updated}}': lastUpdatedLong,
      '{{ updated_at }}': lastUpdatedLong,
      '{{updated_at}}': lastUpdatedLong,
      '{{ date }}': lastUpdatedLong,
      '{{date}}': lastUpdatedLong,
      
      '{{ current_year }}': now.year.toString(),
      '{{current_year}}': now.year.toString(),
      '{{ year }}': now.year.toString(),
      '{{year}}': now.year.toString(),
      
      '{{ shop.email }}': 'support@$shopDomain',
      '{{shop.email}}': 'support@$shopDomain',
      '{{ email }}': 'support@$shopDomain',
      '{{email}}': 'support@$shopDomain',
      '{{ contact_email }}': 'support@$shopDomain',
      '{{contact_email}}': 'support@$shopDomain',
    };
    
    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    
    // Step 4: Handle any remaining {{ variable }} patterns
    final liquidVarPattern = RegExp(r'\{\{\s*([^}]+?)\s*\}\}');
    result = result.replaceAllMapped(liquidVarPattern, (match) {
      final variable = match.group(1)?.trim() ?? '';
      
      if (variable.contains('shop.name') || variable.contains('shop_name')) {
        return shopName;
      } else if (variable.contains('domain')) {
        return shopDomain;
      } else if (variable.contains('email')) {
        return 'support@$shopDomain';
      } else if (variable.contains('year')) {
        return now.year.toString();
      } else if (variable.contains('date') || variable.contains('updated')) {
        return lastUpdatedLong;
      }
      
      return '';
    });
    
    // Step 5: Clean up any extra whitespace
    result = result.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
    
    return result;
  }

  static String _processLiquidConditionals(String html) {
    String result = html;
    
    // Remove {% if selling_to_europe %} blocks - assume false, remove content
    result = result.replaceAll(
      RegExp(r'\{%\s*if\s+selling_to_europe\s*%\}.*?\{%\s*endif\s*%\}', dotAll: true),
      '',
    );
    
    // Remove {% unless condition %} blocks - assume condition is true, remove content
    result = result.replaceAll(
      RegExp(r'\{%\s*unless\s+[^%]+%\}.*?\{%\s*endunless\s*%\}', dotAll: true),
      '',
    );
    
    // Process {% if address != blank %} - assume address exists, keep content
    result = result.replaceAllMapped(
      RegExp(r'\{%\s*if\s+\w+\s*!=\s*blank\s*%\}(.*?)\{%\s*endif\s*%\}', dotAll: true),
      (match) => match.group(1) ?? '',
    );
    
    // Process {% if condition %} with {% else %} - keep the else part
    result = result.replaceAllMapped(
      RegExp(r'\{%\s*if\s+[^%]+%\}.*?\{%\s*else\s*%\}(.*?)\{%\s*endif\s*%\}', dotAll: true),
      (match) => match.group(1) ?? '',
    );
    
    // Remove remaining {% if %} blocks (assume false)
    result = result.replaceAll(
      RegExp(r'\{%\s*if\s+[^%]+%\}.*?\{%\s*endif\s*%\}', dotAll: true),
      '',
    );
    
    // Remove {% for %} loops - just remove the tags, keep content once
    result = result.replaceAllMapped(
      RegExp(r'\{%\s*for\s+[^%]+%\}(.*?)\{%\s*endfor\s*%\}', dotAll: true),
      (match) => match.group(1) ?? '',
    );
    
    // Remove {% case %} blocks - just remove the tags
    result = result.replaceAll(RegExp(r'\{%\s*case\s+[^%]+%\}'), '');
    result = result.replaceAll(RegExp(r'\{%\s*when\s+[^%]+%\}'), '');
    result = result.replaceAll(RegExp(r'\{%\s*endcase\s*%\}'), '');
    
    // Remove any other remaining {% %} tags
    result = result.replaceAll(RegExp(r'\{%-?\s*[^}]+?-?%\}'), '');
    
    return result;
  }
}
