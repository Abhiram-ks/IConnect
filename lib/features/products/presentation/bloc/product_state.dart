part of 'product_bloc.dart';

/// Category product data with pagination info
class CategoryProductData {
  final ApiResponse<List<ProductEntity>> products;
  final bool hasNextPage;
  final String? endCursor;

  CategoryProductData({
    ApiResponse<List<ProductEntity>>? products,
    this.hasNextPage = false,
    this.endCursor,
  }) : products = products ?? ApiResponse.initial();

  CategoryProductData copyWith({
    ApiResponse<List<ProductEntity>>? products,
    bool? hasNextPage,
    String? endCursor,
  }) {
    return CategoryProductData(
      products: products ?? this.products,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      endCursor: endCursor ?? this.endCursor,
    );
  }
}

class ProductState {
  ApiResponse<List<ProductEntity>> products;
  ApiResponse<ProductEntity> productDetail;
  ApiResponse<List<CollectionEntity>> collections;
  ApiResponse<List<CollectionEntity>> banners;
  ApiResponse<CollectionWithProducts> collectionWithProducts;
  ApiResponse<List<BrandEntity>> brands;
  ApiResponse<List<ProductEntity>> brandProducts; // Separate state for brand products
  bool hasNextPage;
  String? endCursor;
  bool brandProductsHasNextPage; // Separate pagination for brand products
  String? brandProductsEndCursor;
  
  // Category products - Map<CategoryName, CategoryProductData>
  Map<String, CategoryProductData> categoryProducts;

  ProductState({
    ApiResponse<List<ProductEntity>>? products,
    ApiResponse<ProductEntity>? productDetail,
    ApiResponse<List<CollectionEntity>>? collections,
    ApiResponse<List<CollectionEntity>>? banners,
    ApiResponse<CollectionWithProducts>? collectionWithProducts,
    ApiResponse<List<BrandEntity>>? brands,
    ApiResponse<List<ProductEntity>>? brandProducts,
    this.hasNextPage = false,
    this.endCursor,
    this.brandProductsHasNextPage = false,
    this.brandProductsEndCursor,
    Map<String, CategoryProductData>? categoryProducts,
  })  : products = products ?? ApiResponse.initial(),
        productDetail = productDetail ?? ApiResponse.initial(),
        collections = collections ?? ApiResponse.initial(),
        banners = banners ?? ApiResponse.initial(),
        collectionWithProducts = collectionWithProducts ?? ApiResponse.initial(),
        brands = brands ?? ApiResponse.initial(),
        brandProducts = brandProducts ?? ApiResponse.initial(),
        categoryProducts = categoryProducts ?? {};

  ProductState copyWith({
    ApiResponse<List<ProductEntity>>? products,
    ApiResponse<ProductEntity>? productDetail,
    ApiResponse<List<CollectionEntity>>? collections,
    ApiResponse<List<CollectionEntity>>? banners,
    ApiResponse<CollectionWithProducts>? collectionWithProducts,
    ApiResponse<List<BrandEntity>>? brands,
    ApiResponse<List<ProductEntity>>? brandProducts,
    bool? hasNextPage,
    String? endCursor,
    bool? brandProductsHasNextPage,
    String? brandProductsEndCursor,
    Map<String, CategoryProductData>? categoryProducts,
  }) {
    return ProductState(
      products: products ?? this.products,
      productDetail: productDetail ?? this.productDetail,
      collections: collections ?? this.collections,
      banners: banners ?? this.banners,
      collectionWithProducts: collectionWithProducts ?? this.collectionWithProducts,
      brands: brands ?? this.brands,
      brandProducts: brandProducts ?? this.brandProducts,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      endCursor: endCursor ?? this.endCursor,
      brandProductsHasNextPage: brandProductsHasNextPage ?? this.brandProductsHasNextPage,
      brandProductsEndCursor: brandProductsEndCursor ?? this.brandProductsEndCursor,
      categoryProducts: categoryProducts ?? this.categoryProducts,
    );
  }
}

