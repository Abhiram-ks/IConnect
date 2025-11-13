import 'package:flutter/material.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/widgets/shopify_new_arrivals_section.dart';
import 'package:iconnect/widgets/shopify_product_grid_section.dart';

/// 🎯 Test Screen - See Real Shopify Products in Action!
/// 
/// This is a simple test screen to verify that products are loading from Shopify.
/// 
/// To view this screen:
/// 1. Run the app: flutter run
/// 2. Navigate to this route: Navigator.pushNamed(context, '/test-products')
/// 3. Or add a button in your home screen to navigate here
/// 
/// You should see:
/// - A horizontal scrolling list of products ("New Arrivals")
/// - A grid of products ("Featured Products")
/// - Real data from your Shopify store
/// - Loading spinners while fetching
/// - Error messages if something goes wrong
class TestShopifyProductsScreen extends StatelessWidget {
  const TestShopifyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Shopify Products'),
        backgroundColor: AppPalette.blueColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppPalette.blueColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppPalette.blueColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Shopify Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.blueColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The products below are loaded in real-time from your Shopify store using GraphQL queries.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Tap any product to view details',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const Text(
                    '• Pull down to refresh',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Horizontal Scroll Section
            const SizedBox(height: 16),
            ShopifyNewArrivalsSection(
              title: 'New Arrivals (Horizontal Scroll)',
              productCount: 10,
              onViewAll: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('View All tapped!'),
                    backgroundColor: AppPalette.blueColor,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(thickness: 1, color: Colors.grey.shade300),
            ),

            const SizedBox(height: 16),

            // Grid Section
            ShopifyProductGridSection(
              title: 'Featured Products (Grid Layout)',
              crossAxisCount: 2,
              productCount: 6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),

            const SizedBox(height: 32),

            // Another horizontal section
            ShopifyNewArrivalsSection(
              title: 'More Products',
              productCount: 8,
            ),

            const SizedBox(height: 64),

            // Success Message
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.celebration,
                    color: Colors.green,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '🎉 Integration Complete!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'If you can see products above, your Shopify integration is working perfectly!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Now you can use these widgets in any screen:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• ShopifyNewArrivalsSection',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const Text(
                    '• ShopifyProductGridSection',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

