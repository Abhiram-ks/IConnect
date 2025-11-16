import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_drawer.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/models/cart_item.dart';
import 'package:iconnect/screens/nav_screen.dart';
import 'package:iconnect/screens/search_screen.dart';
import 'package:iconnect/widgets/cart_drawer.dart';
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
      bottomNavigationBar: BlocBuilder<ButtomNavCubit, NavItem>(
        builder: (context, state) {
          return Builder(
            builder: (BuildContext scaffoldContext) {
              return SizedBox(
                height: 70.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppPalette.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.blackColor.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    enableFeedback: true,
                    useLegacyColorScheme: true,
                    elevation: 0,
                    iconSize: 26,
                    selectedItemColor: AppPalette.blueColor,
                    backgroundColor: Colors.transparent,
                    landscapeLayout:
                        BottomNavigationBarLandscapeLayout.spread,
                    unselectedLabelStyle: TextStyle(
                      color: AppPalette.hintColor,
                    ),
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: NavItem.values.indexOf(NavItem.home), // Always show home as selected
                    onTap: (index) {
                      if (NavItem.values[index] == NavItem.cart) {
                        // Open cart drawer when cart icon is tapped
                        Scaffold.of(scaffoldContext).openEndDrawer();
                      } else if (NavItem.values[index] == NavItem.search) {
                        // Navigate back to home screen and then open search
                        Navigator.pushReplacementNamed(context, '/');
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          }
                        });
                      } else {
                        // Navigate back to home and switch to the selected tab
                        Navigator.pushReplacementNamed(context, '/');
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            context.read<ButtomNavCubit>().selectItem(
                              NavItem.values[index],
                            );
                          }
                        });
                      }
                    },
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined, size: 16),
                        label: 'Home',
                        activeIcon: Icon(
                          Icons.home,
                          color: AppPalette.blueColor,
                        ),
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.grid_view, size: 16),
                        label: 'Product',
                        activeIcon: Icon(
                          Icons.grid_view_sharp,
                          color: AppPalette.blueColor,
                        ),
                      ),
                      BottomNavigationBarItem(
                        icon: BlocBuilder<CartCubit, CartState>(
                          builder: (context, state) {
                            return Stack(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 16,
                                ),
                                if (state.itemCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppPalette.redColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${state.itemCount}',
                                        style: const TextStyle(
                                          color: AppPalette.whiteColor,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        label: 'Cart',
                        activeIcon: BlocBuilder<CartCubit, CartState>(
                          builder: (context, state) {
                            return Stack(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_rounded,
                                  color: AppPalette.blueColor,
                                ),
                                if (state.itemCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppPalette.redColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${state.itemCount}',
                                        style: const TextStyle(
                                          color: AppPalette.whiteColor,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.search, size: 16),
                        label: 'Search',
                        activeIcon: Icon(
                          Icons.search,
                          color: AppPalette.blueColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
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
