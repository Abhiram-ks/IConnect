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
  ApiResponse<List<ProductEntity>> allProducts; // Separate state for all products screen
  ApiResponse<ProductEntity> productDetail;
  ApiResponse<List<CollectionEntity>> collections;
  ApiResponse<List<CollectionEntity>> homeCategories; // Separate state for homepage categories (first 20)
  ApiResponse<List<CollectionEntity>> allCategories; // Separate state for all categories page (with imageUrls)
  ApiResponse<List<CollectionEntity>> banners;
  ApiResponse<CollectionWithProducts> collectionWithProducts;
  ApiResponse<List<BrandEntity>> brands;
  ApiResponse<List<ProductEntity>> brandProducts; // Separate state for brand products
  ApiResponse<List<ProductEntity>> recommendedProducts; // Recommended products
  Map<ModelName, SeriesModel>? seriesProducts; // Separate state for series products
  bool hasNextPage;
  String? endCursor;
  bool allProductsHasNextPage; // Separate pagination for all products
  String? allProductsEndCursor;
  bool brandProductsHasNextPage; // Separate pagination for brand products
  String? brandProductsEndCursor;
  // Category products - Map<CategoryName, CategoryProductData>
  Map<String, CategoryProductData> categoryProducts;

  ProductState({
    ApiResponse<List<ProductEntity>>? products,
    ApiResponse<List<ProductEntity>>? allProducts,
    ApiResponse<ProductEntity>? productDetail,
    ApiResponse<List<CollectionEntity>>? collections,
    ApiResponse<List<CollectionEntity>>? homeCategories,
    ApiResponse<List<CollectionEntity>>? allCategories,
    ApiResponse<List<CollectionEntity>>? banners,
    ApiResponse<CollectionWithProducts>? collectionWithProducts,
    ApiResponse<List<BrandEntity>>? brands,
    ApiResponse<List<ProductEntity>>? brandProducts,
    ApiResponse<List<ProductEntity>>? recommendedProducts,
    Map<ModelName, SeriesModel>? seriesProducts,
    this.hasNextPage = false,
    this.endCursor,
    this.allProductsHasNextPage = false,
    this.allProductsEndCursor,
    this.brandProductsHasNextPage = false,
    this.brandProductsEndCursor,
    Map<String, CategoryProductData>? categoryProducts,
  })  : products = products ?? ApiResponse.initial(),
        allProducts = allProducts ?? ApiResponse.initial(),
        productDetail = productDetail ?? ApiResponse.initial(),
        collections = collections ?? ApiResponse.initial(),
        homeCategories = homeCategories ?? ApiResponse.initial(),
        allCategories = allCategories ?? ApiResponse.initial(),
        banners = banners ?? ApiResponse.initial(),
        collectionWithProducts = collectionWithProducts ?? ApiResponse.initial(),
        brands = brands ?? ApiResponse.initial(),
        brandProducts = brandProducts ?? ApiResponse.initial(),
        recommendedProducts = recommendedProducts ?? ApiResponse.initial(),
        seriesProducts = seriesProducts ?? {},
        categoryProducts = categoryProducts ?? {};

  ProductState copyWith({
    ApiResponse<List<ProductEntity>>? products,
    ApiResponse<List<ProductEntity>>? allProducts,
    ApiResponse<ProductEntity>? productDetail,
    ApiResponse<List<CollectionEntity>>? collections,
    ApiResponse<List<CollectionEntity>>? homeCategories,
    ApiResponse<List<CollectionEntity>>? allCategories,
    ApiResponse<List<CollectionEntity>>? banners,
    ApiResponse<CollectionWithProducts>? collectionWithProducts,
    ApiResponse<List<BrandEntity>>? brands,
    ApiResponse<List<ProductEntity>>? brandProducts,
    ApiResponse<List<ProductEntity>>? recommendedProducts,
    Map<ModelName, SeriesModel>? seriesProducts,
    bool? hasNextPage,
    String? endCursor,
    bool? allProductsHasNextPage,
    String? allProductsEndCursor,
    bool? brandProductsHasNextPage,
    String? brandProductsEndCursor,
    Map<String, CategoryProductData>? categoryProducts,
  }) {
    return ProductState(
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      productDetail: productDetail ?? this.productDetail,
      collections: collections ?? this.collections,
      homeCategories: homeCategories ?? this.homeCategories,
      allCategories: allCategories ?? this.allCategories,
      banners: banners ?? this.banners,
      collectionWithProducts: collectionWithProducts ?? this.collectionWithProducts,
      brands: brands ?? this.brands,
      brandProducts: brandProducts ?? this.brandProducts,
      recommendedProducts: recommendedProducts ?? this.recommendedProducts,
      seriesProducts: seriesProducts ?? this.seriesProducts,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      endCursor: endCursor ?? this.endCursor,
      allProductsHasNextPage: allProductsHasNextPage ?? this.allProductsHasNextPage,
      allProductsEndCursor: allProductsEndCursor ?? this.allProductsEndCursor,
      brandProductsHasNextPage: brandProductsHasNextPage ?? this.brandProductsHasNextPage,
      brandProductsEndCursor: brandProductsEndCursor ?? this.brandProductsEndCursor,
      categoryProducts: categoryProducts ?? this.categoryProducts,
    );
  }
}

