import 'package:flutter/material.dart';
import 'package:iconnect/app_palette.dart';
import '../widgets/product_card.dart';
import '../data/product_data.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Filter action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filter options coming soon!'),
                  backgroundColor: AppPalette.greenColor,
                ),
              );
            },
            icon: const Icon(
              Icons.filter_list,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: ProductData.products.length,
          itemBuilder: (context, index) {
            final product = ProductData.products[index];
            return ProductCard(
              imageUrl: product['imageUrl'],
              productName: product['productName'],
              description: product['description'],
              originalPrice: product['originalPrice'],
              discountedPrice: product['discountedPrice'],
              offerText: product['offerText'],
              onTap: () {
              },
              onWishlist: () {
              },
              onView: () {
              },
            );
          },
        ),
      ),
    );
  }
}