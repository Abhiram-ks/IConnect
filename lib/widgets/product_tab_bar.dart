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

/// Sample data for different product categories
class ProductCategoryData {
  static List<ProductCategory> getCategories() {
    return [
      ProductCategory(
        name: 'Apple 17 Series',
        products: [
          {
            "id": 1,
            "imageUrl": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop&crop=center",
            "productName": "Apple iPhone Air 256GB - Space Black",
            "description": "Screen Protector Included",
            "originalPrice": 3899.00,
            "discountedPrice": 3749.00,
            "offerText": "-4%",
          },
          {
            "id": 2,
            "imageUrl": "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=300&h=300&fit=crop&crop=center",
            "productName": "Apple iPhone Air 256GB - Sky Blue",
            "description": "Screen Protector Included",
            "originalPrice": 3899.00,
            "discountedPrice": 3699.00,
            "offerText": "-5%",
          },
          {
            "id": 3,
            "imageUrl": "https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=300&h=300&fit=crop&crop=center",
            "productName": "Apple iPhone 15 Pro Max",
            "description": "6.7\" 256GB - Natural Titanium",
            "originalPrice": 4499.00,
            "discountedPrice": 4199.00,
            "offerText": "-7%",
          },
          {
            "id": 4,
            "imageUrl": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop&crop=center",
            "productName": "Apple iPhone 15 Plus",
            "description": "6.7\" 128GB - Pink",
            "originalPrice": 3499.00,
            "discountedPrice": 3299.00,
            "offerText": "-6%",
          },
        ],
      ),
      ProductCategory(
        name: 'Samsung',
        products: [
          {
            "id": 5,
            "imageUrl": "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=300&h=300&fit=crop&crop=center",
            "productName": "Samsung Galaxy S25 FE",
            "description": "5G 8GB 256GB - Icy Blue",
            "originalPrice": 2699.00,
            "discountedPrice": 2179.00,
            "offerText": "-19%",
          },
          {
            "id": 6,
            "imageUrl": "https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=300&h=300&fit=crop&crop=center",
            "productName": "Samsung Galaxy S24 Ultra",
            "description": "5G 12GB 512GB - Titanium Black",
            "originalPrice": 3999.00,
            "discountedPrice": 3599.00,
            "offerText": "-10%",
          },
          {
            "id": 7,
            "imageUrl": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop&crop=center",
            "productName": "Samsung Galaxy Z Fold 5",
            "description": "5G 12GB 512GB - Phantom Black",
            "originalPrice": 5999.00,
            "discountedPrice": 5499.00,
            "offerText": "-8%",
          },
          {
            "id": 8,
            "imageUrl": "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=300&h=300&fit=crop&crop=center",
            "productName": "Samsung Galaxy A55",
            "description": "5G 8GB 256GB - Awesome Graphite",
            "originalPrice": 1899.00,
            "discountedPrice": 1699.00,
            "offerText": "-11%",
          },
        ],
      ),
      ProductCategory(
        name: 'Google',
        products: [
          {
            "id": 9,
            "imageUrl": "https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=300&h=300&fit=crop&crop=center",
            "productName": "Google Pixel 8",
            "description": "5G 8GB 128GB - Obsidian",
            "originalPrice": 1999.00,
            "discountedPrice": 1799.00,
            "offerText": "-10%",
          },
          {
            "id": 10,
            "imageUrl": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop&crop=center",
            "productName": "Google Pixel 8 Pro",
            "description": "5G 12GB 256GB - Bay Blue",
            "originalPrice": 2999.00,
            "discountedPrice": 2699.00,
            "offerText": "-10%",
          },
          {
            "id": 11,
            "imageUrl": "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=300&h=300&fit=crop&crop=center",
            "productName": "Google Pixel 8a",
            "description": "5G 8GB 128GB - Aloe",
            "originalPrice": 1499.00,
            "discountedPrice": 1299.00,
            "offerText": "-13%",
          },
          {
            "id": 12,
            "imageUrl": "https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=300&h=300&fit=crop&crop=center",
            "productName": "Google Pixel Fold",
            "description": "5G 12GB 512GB - Obsidian",
            "originalPrice": 4499.00,
            "discountedPrice": 3999.00,
            "offerText": "-11%",
          },
        ],
      ),
      ProductCategory(
        name: 'OnePlus',
        products: [
          {
            "id": 13,
            "imageUrl": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop&crop=center",
            "productName": "OnePlus 12",
            "description": "5G 12GB 256GB - Silky Black",
            "originalPrice": 2499.00,
            "discountedPrice": 2199.00,
            "offerText": "-12%",
          },
          {
            "id": 14,
            "imageUrl": "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=300&h=300&fit=crop&crop=center",
            "productName": "OnePlus 12R",
            "description": "5G 8GB 128GB - Iron Gray",
            "originalPrice": 1899.00,
            "discountedPrice": 1699.00,
            "offerText": "-11%",
          },
          {
            "id": 15,
            "imageUrl": "https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=300&h=300&fit=crop&crop=center",
            "productName": "OnePlus Nord CE 4",
            "description": "5G 8GB 256GB - Celadon Marble",
            "originalPrice": 1299.00,
            "discountedPrice": 1099.00,
            "offerText": "-15%",
          },
        ],
      ),
    ];
  }
}
