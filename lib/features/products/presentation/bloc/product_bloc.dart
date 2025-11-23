import 'package:bloc/bloc.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/domain/entities/brand_entity.dart';
import 'package:iconnect/features/products/domain/entities/collection_entity.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/domain/usecases/get_brands_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_collections_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_product_by_handle_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_products_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_collection_by_handle_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_product_recommendations_usecase.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';

part 'product_state.dart';

/// Product BLoC - Business logic orchestration
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUsecase getProductsUsecase;
  final GetProductByHandleUsecase getProductByHandleUsecase;
  final GetCollectionsUsecase getCollectionsUsecase;
  final GetCollectionByHandleUsecase getCollectionByHandleUsecase;
  final GetBrandsUsecase getBrandsUsecase;
  final GetProductRecommendationsUsecase getProductRecommendationsUsecase;

  // Keep track of current products for pagination
  List<ProductEntity> _currentProducts = [];
  List<ProductEntity> _currentAllProducts = [];
  List<ProductEntity> _currentBrandProducts = [];
  // Keep track of category products for pagination
  Map<String, List<ProductEntity>> _currentCategoryProducts = {};

  ProductBloc({
    required this.getProductsUsecase,
    required this.getProductByHandleUsecase,
    required this.getCollectionsUsecase,
    required this.getCollectionByHandleUsecase,
    required this.getBrandsUsecase,
    required this.getProductRecommendationsUsecase,
  }) : super(ProductState()) {
    on<LoadProductsRequested>(_onLoadProductsRequested);
    on<LoadAllProductsRequested>(_onLoadAllProductsRequested);
    on<LoadProductByHandleRequested>(_onLoadProductByHandleRequested);
    on<LoadCollectionsRequested>(_onLoadCollectionsRequested);
    on<LoadCollectionByHandleRequested>(_onLoadCollectionByHandleRequested);
    on<LoadBrandsRequested>(_onLoadBrandsRequested);
    on<LoadBrandProductsRequested>(_onLoadBrandProductsRequested);
    on<RefreshProductsRequested>(_onRefreshProductsRequested);
    on<LoadCategoryProductsRequested>(_onLoadCategoryProductsRequested);
    on<LoadProductRecommendationsRequested>(
      _onLoadProductRecommendationsRequested,
    );
  }

  /// Handle load products event
  Future<void> _onLoadProductsRequested(
    LoadProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (event.loadMore) {
      // Keep current products and don't show loading
      emit(state.copyWith());
    } else {
      // Reset current products and emit loading state
      _currentProducts = [];
      emit(
        state.copyWith(
          products: ApiResponse.loading(),
          hasNextPage: false,
          endCursor: null,
        ),
      );
    }

    final params = GetProductsParams(
      first: event.first,
      after: event.after,
      query: event.query,
      sortKey: event.sortKey,
      reverse: event.reverse,
    );

    final result = await getProductsUsecase(params);

    result.fold(
      (failure) => {
        emit(state.copyWith(products: ApiResponse.error(failure.message))),
      },
      (productsResult) {
        // Add new products to the list
        if (event.loadMore) {
          _currentProducts.addAll(productsResult.products);
        } else {
          _currentProducts = productsResult.products;
        }

        emit(
          state.copyWith(
            products: ApiResponse.completed(_currentProducts),
            hasNextPage: productsResult.pageInfo.hasNextPage,
            endCursor: productsResult.pageInfo.endCursor,
          ),
        );
      },
    );
  }

  /// Handle load all products event (for product screen)
  Future<void> _onLoadAllProductsRequested(
    LoadAllProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (event.loadMore) {
      // Keep current products and don't show loading
      emit(state.copyWith());
    } else {
      // Reset current products and emit loading state
      _currentAllProducts = [];
      emit(
        state.copyWith(
          allProducts: ApiResponse.loading(),
          allProductsHasNextPage: false,
          allProductsEndCursor: null,
        ),
      );
    }

    final params = GetProductsParams(
      first: event.first,
      after: event.after,
      sortKey: event.sortKey,
      reverse: event.reverse,
    );

    final result = await getProductsUsecase(params);

    result.fold(
      (failure) => {
        emit(state.copyWith(allProducts: ApiResponse.error(failure.message))),
      },
      (productsResult) {
        // Add new products to the list
        if (event.loadMore) {
          _currentAllProducts.addAll(productsResult.products);
        } else {
          _currentAllProducts = productsResult.products;
        }

        emit(
          state.copyWith(
            allProducts: ApiResponse.completed(_currentAllProducts),
            allProductsHasNextPage: productsResult.pageInfo.hasNextPage,
            allProductsEndCursor: productsResult.pageInfo.endCursor,
          ),
        );
      },
    );
  }

  /// Handle load product by handle event
  Future<void> _onLoadProductByHandleRequested(
    LoadProductByHandleRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(productDetail: ApiResponse.loading()));

    final params = GetProductByHandleParams(handle: event.handle);
    final result = await getProductByHandleUsecase(params);

    result.fold(
      (failure) => {
        emit(state.copyWith(productDetail: ApiResponse.error(failure.message))),
      },
      (product) => {
        emit(state.copyWith(productDetail: ApiResponse.completed(product))),
      },
    );
  }

  /// Handle load collections event
  Future<void> _onLoadCollectionsRequested(
    LoadCollectionsRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (event.forBanners) {
      // Load collections for banners
      emit(state.copyWith(banners: ApiResponse.loading()));

      final params = GetCollectionsParams(first: event.first);
      final result = await getCollectionsUsecase(params);

      result.fold(
        (failure) => {
          emit(state.copyWith(banners: ApiResponse.error(failure.message))),
        },
        (collections) {
          // Filter collections that have images
          final bannersWithImages =
              collections.where((c) => c.imageUrl != null).toList();
          emit(
            state.copyWith(banners: ApiResponse.completed(bannersWithImages)),
          );
        },
      );
    } else {
      // Load regular collections
      emit(state.copyWith(collections: ApiResponse.loading()));

      final params = GetCollectionsParams(first: event.first);
      final result = await getCollectionsUsecase(params);

      result.fold(
        (failure) => {
          emit(state.copyWith(collections: ApiResponse.error(failure.message))),
        },
        (collections) => {
          emit(state.copyWith(collections: ApiResponse.completed(collections))),
        },
      );
    }
  }

  /// Handle load collection by handle event
  Future<void> _onLoadCollectionByHandleRequested(
    LoadCollectionByHandleRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(collectionWithProducts: ApiResponse.loading()));

    final params = GetCollectionByHandleParams(
      handle: event.handle,
      first: event.first,
    );

    final result = await getCollectionByHandleUsecase(params);

    result.fold(
      (failure) => {
        emit(
          state.copyWith(
            collectionWithProducts: ApiResponse.error(failure.message),
          ),
        ),
      },
      (collectionWithProducts) => {
        emit(
          state.copyWith(
            collectionWithProducts: ApiResponse.completed(
              collectionWithProducts,
            ),
          ),
        ),
      },
    );
  }

  /// Handle load brands event
  Future<void> _onLoadBrandsRequested(
    LoadBrandsRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(brands: ApiResponse.loading()));

    final params = GetBrandsParams(first: event.first);
    final result = await getBrandsUsecase(params);

    result.fold(
      (failure) => {
        emit(state.copyWith(brands: ApiResponse.error(failure.message))),
      },
      (brands) => {emit(state.copyWith(brands: ApiResponse.completed(brands)))},
    );
  }

  /// Handle load brand products event
  Future<void> _onLoadBrandProductsRequested(
    LoadBrandProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (event.loadMore) {
      // Keep current brand products and don't show loading
      emit(state.copyWith());
    } else {
      // Reset current brand products and emit loading state
      _currentBrandProducts = [];
      emit(
        state.copyWith(
          brandProducts: ApiResponse.loading(),
          brandProductsHasNextPage: false,
          brandProductsEndCursor: null,
        ),
      );
    }

    // Build query string for vendor filter
    final query = 'vendor:${event.vendor}';

    final params = GetProductsParams(
      first: event.first,
      after: event.after,
      query: query,
    );

    final result = await getProductsUsecase(params);

    result.fold(
      (failure) => {
        emit(state.copyWith(brandProducts: ApiResponse.error(failure.message))),
      },
      (productsResult) {
        // Add new products to the list
        if (event.loadMore) {
          _currentBrandProducts.addAll(productsResult.products);
        } else {
          _currentBrandProducts = productsResult.products;
        }

        emit(
          state.copyWith(
            brandProducts: ApiResponse.completed(_currentBrandProducts),
            brandProductsHasNextPage: productsResult.pageInfo.hasNextPage,
            brandProductsEndCursor: productsResult.pageInfo.endCursor,
          ),
        );
      },
    );
  }

  /// Handle refresh products event
  Future<void> _onRefreshProductsRequested(
    RefreshProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    // Reset and reload products
    _currentProducts = [];
    add(LoadProductsRequested());
  }

  /// Handle load category products event
  Future<void> _onLoadCategoryProductsRequested(
    LoadCategoryProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    final categoryName = event.categoryName;

    if (!event.loadMore) {
      // Reset current category products and emit loading state
      _currentCategoryProducts[categoryName] = [];

      // Update the category data with loading state
      final updatedCategoryProducts = Map<String, CategoryProductData>.from(
        state.categoryProducts,
      );
      updatedCategoryProducts[categoryName] = CategoryProductData(
        products: ApiResponse.loading(),
        hasNextPage: false,
        endCursor: null,
      );

      emit(state.copyWith(categoryProducts: updatedCategoryProducts));
    }

    // Use getCollectionByHandle to get products for this specific collection
    final params = GetCollectionByHandleParams(
      handle: event.collectionHandle,
      first: event.first,
    );

    final result = await getCollectionByHandleUsecase(params);

    result.fold(
      (failure) {
        final updatedCategoryProducts = Map<String, CategoryProductData>.from(
          state.categoryProducts,
        );
        updatedCategoryProducts[categoryName] = CategoryProductData(
          products: ApiResponse.error(failure.message),
          hasNextPage: false,
          endCursor: null,
        );
        emit(state.copyWith(categoryProducts: updatedCategoryProducts));
      },
      (collectionWithProducts) {
        // Get products from the collection
        final productsResult = collectionWithProducts.products;

        // Set current category products (no pagination support for now as we load all at once)
        _currentCategoryProducts[categoryName] = productsResult.products;

        final updatedCategoryProducts = Map<String, CategoryProductData>.from(
          state.categoryProducts,
        );
        updatedCategoryProducts[categoryName] = CategoryProductData(
          products: ApiResponse.completed(
            _currentCategoryProducts[categoryName] ?? [],
          ),
          hasNextPage: productsResult.pageInfo.hasNextPage,
          endCursor: productsResult.pageInfo.endCursor,
        );

        emit(state.copyWith(categoryProducts: updatedCategoryProducts));
      },
    );
  }

  /// Handle load product recommendations event
  Future<void> _onLoadProductRecommendationsRequested(
    LoadProductRecommendationsRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(recommendedProducts: ApiResponse.loading()));

    final params = GetProductRecommendationsParams(productId: event.productId);
    final result = await getProductRecommendationsUsecase(params);

    result.fold(
      (failure) => {
        emit(
          state.copyWith(
            recommendedProducts: ApiResponse.error(failure.message),
          ),
        ),
      },
      (products) => {
        emit(
          state.copyWith(recommendedProducts: ApiResponse.completed(products)),
        ),
      },
    );
  }
}
