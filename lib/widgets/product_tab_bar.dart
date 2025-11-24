import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/widgets/product_card.dart';
import 'package:iconnect/widgets/product_preview_modal.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/models/cart_item.dart';

/// A dynamic tab bar widget that displays products horizontally in each tab
/// Based on the provided image showing "Apple 17 Series", "Samsung", "Google" tabs
class ProductTabBar extends StatefulWidget {
  final List<ProductCategory> categories;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final double indicatorWeight;
  final double height;

  const ProductTabBar({
    super.key,
    required this.categories,
    this.isScrollable = true,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorWeight = 3.0,
    this.height = 400,
  });

  @override
  State<ProductTabBar> createState() => _ProductTabBarState();
}

class _ProductTabBarState extends State<ProductTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.categories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          // TabBar
          TabBar(
            controller: _tabController,
            isScrollable: widget.isScrollable,
            indicatorColor: widget.indicatorColor ?? AppPalette.blueColor,
            indicatorWeight: widget.indicatorWeight,
            dividerColor: Colors.transparent,
            padding: EdgeInsets.zero,
            indicatorPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            tabAlignment: TabAlignment.start,
            
            labelColor: widget.labelColor ?? AppPalette.blueColor,
            unselectedLabelColor:widget.unselectedLabelColor ?? AppPalette.greyColor,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: widget.categories
                .map(
                  (category) => Tab(text: category.name),
                )
                .toList(),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.categories
                  .map(
                    (category) => _buildProductListView(category),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListView(ProductCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: category.products.length,
        itemBuilder: (context, index) {
          final product = category.products[index];
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
                    // Navigate to product details
                    Navigator.pushNamed(
                      context,
                      '/product_details',
                      arguments: {'productId': product['id']},
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
    );
  }
}

/// Model class for product categories
class ProductCategory {
  final String name;
  final List<Map<String, dynamic>> products;

  ProductCategory({
    required this.name,
    required this.products,
  });
}
