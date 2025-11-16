import 'package:equatable/equatable.dart';

/// Product Entity - Pure business object
class ProductEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String descriptionHtml;
  final String handle;
  final String? featuredImage;
  final List<String> images;
  final double minPrice;
  final double maxPrice;
  final double? compareAtPrice;
  final String currencyCode;
  final bool availableForSale;
  final List<ProductVariantEntity> variants;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.descriptionHtml,
    required this.handle,
    this.featuredImage,
    required this.images,
    required this.minPrice,
    required this.maxPrice,
    this.compareAtPrice,
    required this.currencyCode,
    required this.availableForSale,
    this.variants = const [],
  });

  /// Calculate discount percentage
  double? get discountPercentage {
    if (compareAtPrice == null || compareAtPrice! <= minPrice) {
      return null;
    }
    return ((compareAtPrice! - minPrice) / compareAtPrice!) * 100;
  }

  /// Check if product has discount
  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > minPrice;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        handle,
        featuredImage,
        images,
        minPrice,
        maxPrice,
        compareAtPrice,
        currencyCode,
        availableForSale,
        variants,
      ];
}

/// Product Variant Entity
class ProductVariantEntity extends Equatable {
  final String id;
  final String title;
  final double price;
  final double? compareAtPrice;
  final String currencyCode;
  final bool availableForSale;
  final String? image;

  const ProductVariantEntity({
    required this.id,
    required this.title,
    required this.price,
    this.compareAtPrice,
    required this.currencyCode,
    required this.availableForSale,
    this.image,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        price,
        compareAtPrice,
        currencyCode,
        availableForSale,
        image,
      ];
}

/// Pagination info for products
class ProductsPageInfo extends Equatable {
  final bool hasNextPage;
  final String? endCursor;

  const ProductsPageInfo({
    required this.hasNextPage,
    this.endCursor,
  });

  @override
  List<Object?> get props => [hasNextPage, endCursor];
}

/// Products result with pagination
class ProductsResult extends Equatable {
  final List<ProductEntity> products;
  final ProductsPageInfo pageInfo;

  const ProductsResult({
    required this.products,
    required this.pageInfo,
  });

  @override
  List<Object?> get props => [products, pageInfo];
}

