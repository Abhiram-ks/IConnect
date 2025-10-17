import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/widgets/product_card.dart';
import 'package:iconnect/widgets/product_preview_modal.dart';
import 'package:iconnect/screens/product_details_screen.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/models/cart_item.dart';

/// A horizontal product section with a header
/// Shows products like "New Arrivals" with a title and horizontal scrolling
class NewArrivalsSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> products;
  final VoidCallback? onViewAll;

  const NewArrivalsSection({
    super.key,
    required this.title,
    required this.products,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and "View All" button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppPalette.blueColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Horizontal product list
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) {
                    final isInCart = cartState.items.any((item) => item.id == product['id']);
                    return ProductCard(
                      imageUrl: product['imageUrl'] as String,
                      productName: product['productName'] as String,
                      description: product['description'] as String,
                      originalPrice: product['originalPrice'] as double,
                      discountedPrice: product['discountedPrice'] as double,
                      productId: product['id'] as int,
                      offerText: product['offerText'] as String?,
                      isInCart: isInCart,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider(create: (context) => CartCubit()),
                              ],
                              child: ProductDetailsScreen(
                                productId: product['id'] as int,
                              ),
                            ),
                          ),
                        );
                      },
                      onAddToCart: () {
                        final cartItem = CartItem(
                          id: product['id'] as int,
                          imageUrl: product['imageUrl'] as String,
                          productName: product['productName'] as String,
                          description: product['description'] as String,
                          originalPrice: product['originalPrice'] as double,
                          discountedPrice: product['discountedPrice'] as double,
                          offerText: product['offerText'] as String?,
                        );
                        context.read<CartCubit>().addToCart(cartItem);
                        
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product['productName']} added to cart'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppPalette.blueColor,
                          ),
                        );
                      },
                      onView: () {
                        showDialog(
                          context: context,
                          builder: (context) => ProductPreviewModal(
                            product: product,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Service banner widget for repair services
class ServiceBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String buttonText;
  final VoidCallback onTap;
  final bool isMainBanner;

  const ServiceBanner({
    super.key,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.buttonText,
    required this.onTap,
    this.isMainBanner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: isMainBanner ? 120 : 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[100],
              child: Center(
                child: CircularProgressIndicator(
                  color: AppPalette.blueColor,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[100],
              child: const Icon(
                Icons.image,
                color: Colors.grey,
                size: 50,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Sample data for New Arrivals products
class NewArrivalsData {
  static List<Map<String, dynamic>> getNewArrivalsProducts() {
    return [
      {
        "id": 101,
        "imageUrl": "https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=300&h=300&fit=crop&crop=center",
        "productName": "Apple Watch SE 3 GPS 44mm",
        "description": "Starlight - SOLD OUT",
        "originalPrice": 1219.00,
        "discountedPrice": 1119.00,
        "offerText": "-8%",
      },
      {
        "id": 102,
        "imageUrl": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop&crop=center",
        "productName": "Samsung Galaxy S25 FE",
        "description": "5G 8GB 256GB - Navy",
        "originalPrice": 2699.00,
        "discountedPrice": 2059.00,
        "offerText": "-23%",
      },
      {
        "id": 103,
        "imageUrl": "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=300&h=300&fit=crop&crop=center",
        "productName": "iPhone 15 Pro Max",
        "description": "6.7\" 256GB - Natural Titanium",
        "originalPrice": 4499.00,
        "discountedPrice": 4199.00,
        "offerText": "-7%",
      },
      {
        "id": 104,
        "imageUrl": "https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=300&h=300&fit=crop&crop=center",
        "productName": "Google Pixel 8 Pro",
        "description": "5G 12GB 256GB - Bay Blue",
        "originalPrice": 2999.00,
        "discountedPrice": 2699.00,
        "offerText": "-10%",
      },
    ];
  }
}
