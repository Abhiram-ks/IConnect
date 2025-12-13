import 'package:bloc/bloc.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/domain/entities/banner_entity.dart';
import 'package:iconnect/features/products/domain/entities/brand_entity.dart';
import 'package:iconnect/features/products/domain/entities/collection_entity.dart';
import 'package:iconnect/features/products/domain/entities/home_screen_entity.dart';
import 'package:iconnect/features/products/domain/entities/offer_entity.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/domain/usecases/get_brands_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_collections_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_product_by_handle_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_products_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_collection_by_handle_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_product_recommendations_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_home_banners_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_home_screen_sections_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_offer_blocks_usecase.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/models/series_model.dart';

part 'product_state.dart';

/// Product BLoC - Business logic orchestration
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUsecase getProductsUsecase;
  final GetProductByHandleUsecase getProductByHandleUsecase;
  final GetCollectionsUsecase getCollectionsUsecase;
  final GetCollectionByHandleUsecase getCollectionByHandleUsecase;
  final GetBrandsUsecase getBrandsUsecase;
  final GetProductRecommendationsUsecase getProductRecommendationsUsecase;
  final GetHomeBannersUsecase getHomeBannersUsecase;
  final GetOfferBlocksUsecase getOfferBlocksUsecase;
  final GetHomeScreenSectionsUsecase getHomeScreenSectionsUsecase;

  // Keep track of current products for pagination
  List<ProductEntity> _currentProducts = [];
  List<ProductEntity> _currentAllProducts = [];
  List<ProductEntity> _currentBrandProducts = [];
  Map<String, List<ProductEntity>> _currentCategoryProducts = {};
  List<ProductEntity> _currentCollectionProducts = [];
  CollectionEntity? _currentCollection;

  ProductBloc({
    required this.getProductsUsecase,
    required this.getProductByHandleUsecase,
    required this.getCollectionsUsecase,
    required this.getCollectionByHandleUsecase,
    required this.getBrandsUsecase,
    required this.getProductRecommendationsUsecase,
    required this.getHomeBannersUsecase,
    required this.getOfferBlocksUsecase,
    required this.getHomeScreenSectionsUsecase,
  }) : super(ProductState()) {
    on<LoadProductsRequested>(_onLoadProductsRequested);
    on<LoadAllProductsRequested>(_onLoadAllProductsRequested);
    on<LoadProductByHandleRequested>(_onLoadProductByHandleRequested);
    on<LoadCollectionsRequested>(_onLoadCollectionsRequested);
    on<LoadHomeCategoriesRequested>(_onLoadHomeCategoriesRequested);
    on<LoadAllCategoriesRequested>(_onLoadAllCategoriesRequested);
    on<LoadCollectionByHandleRequested>(_onLoadCollectionByHandleRequested);
    on<LoadBrandsRequested>(_onLoadBrandsRequested);
    on<LoadBrandProductsRequested>(_onLoadBrandProductsRequested);
    on<RefreshProductsRequested>(_onRefreshProductsRequested);
    on<LoadCategoryProductsRequested>(_onLoadCategoryProductsRequested);
    on<LoadProductRecommendationsRequested>(
      _onLoadProductRecommendationsRequested,
    );
    on<LoadSeriesProduct>(_onLoadSeriesProduct);
    on<LoadHomeBannersRequested>(_onLoadHomeBannersRequested);
    on<LoadOfferBlocksRequested>(_onLoadOfferBlocksRequested);
    on<LoadHomeScreenSectionsRequested>(_onLoadHomeScreenSectionsRequested);
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

  /// Handle load home categories event (first 20 for homepage)
  Future<void> _onLoadHomeCategoriesRequested(
    LoadHomeCategoriesRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(homeCategories: ApiResponse.loading()));

    final params = GetCollectionsParams(first: event.first);
    final result = await getCollectionsUsecase(params);

    result.fold(
      (failure) => {
        emit(
          state.copyWith(homeCategories: ApiResponse.error(failure.message)),
        ),
      },
      (collections) {
        // Limit to first 20 for homepage
        final homeCategoriesList = collections.take(event.first).toList();
        emit(
          state.copyWith(
            homeCategories: ApiResponse.completed(homeCategoriesList),
          ),
        );
      },
    );
  }

  /// Handle load all categories event (for all categories page, with imageUrls only)
  Future<void> _onLoadAllCategoriesRequested(
    LoadAllCategoriesRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(allCategories: ApiResponse.loading()));

    final params = GetCollectionsParams(first: event.first);
    final result = await getCollectionsUsecase(params);

    result.fold(
      (failure) => {
        emit(state.copyWith(allCategories: ApiResponse.error(failure.message))),
      },
      (collections) {
        // Filter only collections that have imageUrls
        final categoriesWithImages =
            collections
                .where((c) => c.imageUrl != null && c.imageUrl!.isNotEmpty)
                .toList();
        emit(
          state.copyWith(
            allCategories: ApiResponse.completed(categoriesWithImages),
          ),
        );
      },
    );
  }

  /// Handle load collection by handle event
  Future<void> _onLoadCollectionByHandleRequested(
    LoadCollectionByHandleRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (event.loadMore) {
      // Keep current collection and don't show loading
      emit(state.copyWith());
    } else {
      // Reset current collection products and emit loading state
      _currentCollectionProducts = [];
      _currentCollection = null;
      emit(
        state.copyWith(
          collectionWithProducts: ApiResponse.loading(),
          collectionProductsHasNextPage: false,
          collectionProductsEndCursor: null,
        ),
      );
    }

    final params = GetCollectionByHandleParams(
      handle: event.handle,
      first: event.first,
      after: event.after,
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
      (collectionWithProducts) {
        // Store collection info (only on first load)
        if (!event.loadMore) {
          _currentCollection = collectionWithProducts.collection;
        }

        // Add new products to the list
        if (event.loadMore) {
          _currentCollectionProducts.addAll(
            collectionWithProducts.products.products,
          );
        } else {
          _currentCollectionProducts = collectionWithProducts.products.products;
        }

        // Create updated CollectionWithProducts with accumulated products
        final updatedCollectionWithProducts = CollectionWithProducts(
          collection: _currentCollection ?? collectionWithProducts.collection,
          products: ProductsResult(
            products: _currentCollectionProducts,
            pageInfo: collectionWithProducts.products.pageInfo,
          ),
        );

        emit(
          state.copyWith(
            collectionWithProducts: ApiResponse.completed(
              updatedCollectionWithProducts,
            ),
            collectionProductsHasNextPage:
                collectionWithProducts.products.pageInfo.hasNextPage,
            collectionProductsEndCursor:
                collectionWithProducts.products.pageInfo.endCursor,
          ),
        );
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

  /// Get collection handle for a given model
  String _getCollectionHandleForModel(ModelName model) {
    switch (model) {
      case ModelName.iPhone17:
        return 'iphones-in-qatar';
      case ModelName.samsung:
        return 'samsung-in-qatar';
      case ModelName.google:
        return 'google-pixel-qatar-iconnect-qatar';
    }
  }

  /// Handle load iPhone 17 products event
  Future<void> _onLoadSeriesProduct(
    LoadSeriesProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(
      state.copyWith(seriesProducts: {event.model: SeriesModel(loading: true)}),
    );

    // Get collection handle for the model
    final collectionHandle = _getCollectionHandleForModel(event.model);

    final params = GetCollectionByHandleParams(
      handle: collectionHandle,
      first: event.first,
    );

    final result = await getCollectionByHandleUsecase(params);

    result.fold(
      (failure) {
        // Keep the model data but set loading to false on error
        emit(
          state.copyWith(
            seriesProducts: {event.model: SeriesModel(loading: false)},
          ),
        );
      },
      (collectionWithProducts) {
        // Extract products from collection result
        final productsResult = collectionWithProducts.products;

        // Update only the model that matches the event
        // Note: getCollectionByHandle doesn't support pagination with 'after',
        // so we replace products for now
        final updatedSeriesModel = {
          event.model: SeriesModel(
            products: productsResult.products,
            loading: false,
          ),
        };
        emit(state.copyWith(seriesProducts: updatedSeriesModel));
      },
    );
  }

  /// Handle load home banners event
  Future<void> _onLoadHomeBannersRequested(
    LoadHomeBannersRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(homeBanners: ApiResponse.loading()));

    final params = GetHomeBannersParams(first: event.first);
    final result = await getHomeBannersUsecase(params);

    result.fold(
      (failure) => {
        emit(state.copyWith(homeBanners: ApiResponse.error(failure.message))),
      },
      (banners) => {
        emit(state.copyWith(homeBanners: ApiResponse.completed(banners))),
      },
    );
  }

  /// Handle load offer blocks event
  Future<void> _onLoadOfferBlocksRequested(
    LoadOfferBlocksRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(offerBlocks: ApiResponse.loading()));

    final params = GetOfferBlocksParams();
    final result = await getOfferBlocksUsecase(params);

    result.fold(
      (failure) => {
        emit(state.copyWith(offerBlocks: ApiResponse.error(failure.message))),
      },
      (offerBlocks) => {
        emit(state.copyWith(offerBlocks: ApiResponse.completed(offerBlocks))),
      },
    );
  }

  /// Handle load home screen sections event
  Future<void> _onLoadHomeScreenSectionsRequested(
    LoadHomeScreenSectionsRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(homeScreenSections: ApiResponse.loading()));

    final params = GetHomeScreenSectionsParams();
    final result = await getHomeScreenSectionsUsecase(params);

    result.fold(
      (failure) => {
        emit(
          state.copyWith(
            homeScreenSections: ApiResponse.error(failure.message),
          ),
        ),
      },
      (sections) => {
        emit(
          state.copyWith(
            homeScreenSections: ApiResponse.completed(sections),
          ),
        ),
      },
    );
  }
}
