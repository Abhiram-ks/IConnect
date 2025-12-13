import 'package:iconnect/features/products/domain/entities/product_entity.dart';

/// Product Model - Extends domain entity and handles JSON serialization
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.descriptionHtml,
    required super.handle,
    super.featuredImage,
    required super.images,
    required super.minPrice,
    required super.maxPrice,
    super.compareAtPrice,
    required super.currencyCode,
    required super.availableForSale,
    super.variants,
  });

  /// Factory constructor from JSON (Shopify GraphQL response)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Extract images
    final imagesList = <String>[];
    if (json['images'] != null && json['images']['edges'] != null) {
      final edges = json['images']['edges'] as List;
      for (final edge in edges) {
        final url = edge['node']['url'] as String?;
        if (url != null) imagesList.add(url);
      }
    }

    // Extract featured image
    final featuredImage = json['featuredImage']?['url'] as String?;

    // Extract price range
    final priceRange = json['priceRange'] as Map<String, dynamic>?;
    final minVariantPrice =
        priceRange?['minVariantPrice'] as Map<String, dynamic>?;
    final maxVariantPrice =
        priceRange?['maxVariantPrice'] as Map<String, dynamic>?;

    final minPrice =
        double.tryParse(minVariantPrice?['amount']?.toString() ?? '0') ?? 0.0;
    final maxPrice =
        double.tryParse(maxVariantPrice?['amount']?.toString() ?? '0') ??
        minPrice;
    final currencyCode = minVariantPrice?['currencyCode'] as String? ?? 'USD';

    // Extract compare at price
    double? compareAtPrice;
    final compareAtPriceRange =
        json['compareAtPriceRange'] as Map<String, dynamic>?;
    if (compareAtPriceRange != null) {
      final minComparePrice =
          compareAtPriceRange['minVariantPrice'] as Map<String, dynamic>?;
      if (minComparePrice != null && minComparePrice['amount'] != null) {
        compareAtPrice = double.tryParse(minComparePrice['amount'].toString());
      }
    }

    // Extract variants
    final variantsList = <ProductVariantModel>[];
    if (json['variants'] != null && json['variants']['edges'] != null) {
      final variantsEdges = json['variants']['edges'] as List;
      for (final edge in variantsEdges) {
        variantsList.add(ProductVariantModel.fromJson(edge['node']));
      }
    }

    return ProductModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionHtml: json['descriptionHtml'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      featuredImage: featuredImage,
      images: imagesList,
      minPrice: minPrice,
      maxPrice: maxPrice,
      compareAtPrice: compareAtPrice,
      currencyCode: currencyCode,
      availableForSale: json['availableForSale'] as bool? ?? true,
      variants: variantsList,
    );
  }

  /// Factory constructor from a flattened map produced in an isolate.
  /// Expects already-processed fields: images (List<String>), variants (List<Map>),
  /// featuredImage (String?), prices as doubles, etc.
  factory ProductModel.fromFlattenedJson(Map<String, dynamic> json) {
    final variantsList = <ProductVariantModel>[];
    final variantMaps = json['variants'] as List<dynamic>? ?? const [];
    for (final v in variantMaps) {
      variantsList.add(
        ProductVariantModel.fromFlattenedJson(v as Map<String, dynamic>),
      );
    }

    return ProductModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionHtml: json['descriptionHtml'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      featuredImage: json['featuredImage'] as String?,
      images: (json['images'] as List<dynamic>? ?? const []).cast<String>(),
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice:
          (json['maxPrice'] as num?)?.toDouble() ??
          ((json['minPrice'] as num?)?.toDouble() ?? 0.0),
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      availableForSale: json['availableForSale'] as bool? ?? true,
      variants: variantsList,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'descriptionHtml': descriptionHtml,
      'handle': handle,
      'featuredImage': featuredImage,
      'images': images,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'compareAtPrice': compareAtPrice,
      'currencyCode': currencyCode,
      'availableForSale': availableForSale,
      'variants':
          variants.map((v) => (v as ProductVariantModel).toJson()).toList(),
    };
  }

  /// Copy with method
  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    String? descriptionHtml,
    String? handle,
    String? featuredImage,
    List<String>? images,
    double? minPrice,
    double? maxPrice,
    double? compareAtPrice,
    String? currencyCode,
    bool? availableForSale,
    List<ProductVariantEntity>? variants,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      descriptionHtml: descriptionHtml ?? this.descriptionHtml,
      handle: handle ?? this.handle,
      featuredImage: featuredImage ?? this.featuredImage,
      images: images ?? this.images,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      currencyCode: currencyCode ?? this.currencyCode,
      availableForSale: availableForSale ?? this.availableForSale,
      variants: variants ?? this.variants,
    );
  }
}

/// Product Variant Model
class ProductVariantModel extends ProductVariantEntity {
  const ProductVariantModel({
    required super.id,
    required super.title,
    required super.price,
    super.compareAtPrice,
    required super.currencyCode,
    required super.availableForSale,
    super.image,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final priceData = json['price'] as Map<String, dynamic>?;
    final price =
        double.tryParse(priceData?['amount']?.toString() ?? '0') ?? 0.0;
    final currencyCode = priceData?['currencyCode'] as String? ?? 'USD';

    double? compareAtPrice;
    final compareAtPriceData = json['compareAtPrice'] as Map<String, dynamic>?;
    if (compareAtPriceData != null && compareAtPriceData['amount'] != null) {
      compareAtPrice = double.tryParse(compareAtPriceData['amount'].toString());
    }

    // Extract variant image
    final imageData = json['image'] as Map<String, dynamic>?;
    final variantImage = imageData?['url'] as String?;

    return ProductVariantModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      price: price,
      compareAtPrice: compareAtPrice,
      currencyCode: currencyCode,
      availableForSale: json['availableForSale'] as bool? ?? true,
      image: variantImage,
    );
  }

  factory ProductVariantModel.fromFlattenedJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      availableForSale: json['availableForSale'] as bool? ?? true,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'currencyCode': currencyCode,
      'availableForSale': availableForSale,
      'image': image,
    };
  }
}

/// Products Page Info Model
class ProductsPageInfoModel extends ProductsPageInfo {
  const ProductsPageInfoModel({required super.hasNextPage, super.endCursor});

  factory ProductsPageInfoModel.fromJson(Map<String, dynamic> json) {
    return ProductsPageInfoModel(
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      endCursor: json['endCursor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'hasNextPage': hasNextPage, 'endCursor': endCursor};
  }
}

/// Products Result Model
class ProductsResultModel extends ProductsResult {
  const ProductsResultModel({required super.products, required super.pageInfo});

  factory ProductsResultModel.fromJson(Map<String, dynamic> json) {
    final productsList = <ProductModel>[];

    if (json['products'] != null && json['products']['edges'] != null) {
      final edges = json['products']['edges'] as List;
      for (final edge in edges) {
        productsList.add(ProductModel.fromJson(edge['node']));
      }
    }

    final pageInfo = json['products']?['pageInfo'] as Map<String, dynamic>?;

    return ProductsResultModel(
      products: productsList,
      pageInfo: ProductsPageInfoModel.fromJson(pageInfo ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => (p as ProductModel).toJson()).toList(),
      'pageInfo': (pageInfo as ProductsPageInfoModel).toJson(),
    };
  }
}
