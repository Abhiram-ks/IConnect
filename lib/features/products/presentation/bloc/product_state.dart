part of 'product_bloc.dart';

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
  })  : products = products ?? ApiResponse.initial(),
        productDetail = productDetail ?? ApiResponse.initial(),
        collections = collections ?? ApiResponse.initial(),
        banners = banners ?? ApiResponse.initial(),
        collectionWithProducts = collectionWithProducts ?? ApiResponse.initial(),
        brands = brands ?? ApiResponse.initial(),
        brandProducts = brandProducts ?? ApiResponse.initial();

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
    );
  }
}

