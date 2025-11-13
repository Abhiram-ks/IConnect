import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/domain/usecases/get_collections_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_product_by_handle_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_products_usecase.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/bloc/product_state.dart';

/// Product BLoC - Business logic orchestration
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUsecase getProductsUsecase;
  final GetProductByHandleUsecase getProductByHandleUsecase;
  final GetCollectionsUsecase getCollectionsUsecase;

  // Keep track of current products for pagination
  List<ProductEntity> _currentProducts = [];

  ProductBloc({
    required this.getProductsUsecase,
    required this.getProductByHandleUsecase,
    required this.getCollectionsUsecase,
  }) : super(ProductInitial()) {
    on<LoadProductsRequested>(_onLoadProductsRequested);
    on<LoadProductByHandleRequested>(_onLoadProductByHandleRequested);
    on<LoadCollectionsRequested>(_onLoadCollectionsRequested);
    on<RefreshProductsRequested>(_onRefreshProductsRequested);
  }

  /// Handle load products event
  Future<void> _onLoadProductsRequested(
    LoadProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    if (event.loadMore) {
      // Emit loading more state
      emit(ProductLoadingMore(currentProducts: _currentProducts));
    } else {
      // Reset current products and emit loading state
      _currentProducts = [];
      emit(ProductLoading());
    }

    final params = GetProductsParams(
      first: event.first,
      after: event.after,
      query: event.query,
    );

    final result = await getProductsUsecase(params);

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (productsResult) {
        // Add new products to the list
        if (event.loadMore) {
          _currentProducts.addAll(productsResult.products);
        } else {
          _currentProducts = productsResult.products;
        }

        emit(ProductsLoaded(
          products: _currentProducts,
          hasNextPage: productsResult.pageInfo.hasNextPage,
          endCursor: productsResult.pageInfo.endCursor,
        ));
      },
    );
  }

  /// Handle load product by handle event
  Future<void> _onLoadProductByHandleRequested(
    LoadProductByHandleRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final params = GetProductByHandleParams(handle: event.handle);
    final result = await getProductByHandleUsecase(params);

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }

  /// Handle load collections event
  Future<void> _onLoadCollectionsRequested(
    LoadCollectionsRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final params = GetCollectionsParams(first: event.first);
    final result = await getCollectionsUsecase(params);

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (collections) => emit(CollectionsLoaded(collections: collections)),
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
}

