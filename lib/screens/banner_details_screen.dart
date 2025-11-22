import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_drawer.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/models/cart_item.dart';
import 'package:iconnect/screens/nav_screen.dart';
import 'package:iconnect/widgets/cart_drawer.dart';
import 'package:iconnect/widgets/navbar_widgets.dart';
import 'package:iconnect/widgets/product_card.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';

class BannerDetailsScreen extends StatelessWidget {
  final String bannerTitle;
  final List<Map<String, dynamic>> bannerProducts;

  const BannerDetailsScreen({
    super.key,
    required this.bannerTitle,
    required this.bannerProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      endDrawer: const CartDrawerWidget(),
      appBar: CustomAppBarDashbord(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Hero Section
                _buildBannerHero(),
                
                // Products Grid Section
                _buildProductsSection(),
                
                // Bottom padding for floating button
                const SizedBox(height: 100),
              ],
            ),
          ),
          const WhatsAppFloatingButton(),
        ],
      ),
      bottomNavigationBar: BottomNavWidget(),
    );
  }

  Widget _buildBannerHero() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPalette.blueColor,
            AppPalette.blueColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  bannerTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${bannerProducts.length} products available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Special Offers',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppPalette.blueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${bannerProducts.length} items',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppPalette.blueColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Products Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: bannerProducts.length,
            itemBuilder: (context, index) {
              final product = bannerProducts[index];
              return BlocBuilder<CartCubit, CartState>(
                builder: (context, cartState) {
                  final isInCart = cartState.items.any((item) => item.id == product['id']);
                  return ProductCard(
                    imageUrl: product['imageUrl'],
                    productName: product['productName'],
                    description: product['description'],
                    originalPrice: product['originalPrice'],
                    discountedPrice: product['discountedPrice'],
                    productId: product['id'],
                    offerText: product['offerText'],
                    isInCart: isInCart,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/product_details',
                        arguments: {'productId': product['id']},
                      );
                    },
                    onAddToCart: () {
                      final cartItem = CartItem(
                        id: product['id'],
                        imageUrl: product['imageUrl'],
                        productName: product['productName'],
                        description: product['description'],
                        originalPrice: product['originalPrice'],
                        discountedPrice: product['discountedPrice'],
                        offerText: product['offerText'],
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
                      // You can implement quick view functionality here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Quick view for ${product['productName']}'),
                          backgroundColor: AppPalette.greenColor,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
