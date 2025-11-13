import 'package:flutter/material.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/presentation/widgets/shopify_product_card.dart';

/// Product Grid Widget
class ProductGridWidget extends StatelessWidget {
  final List<ProductEntity> products;
  final ScrollController? scrollController;
  final int crossAxisCount;

  const ProductGridWidget({
    super.key,
    required this.products,
    this.scrollController,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ShopifyProductCard(product: products[index]);
      },
    );
  }
}

