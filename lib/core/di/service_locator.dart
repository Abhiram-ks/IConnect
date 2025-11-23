


import 'package:get_it/get_it.dart';

import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_line_items_usecase.dart';
import '../../features/cart/domain/usecases/create_checkout_usecase.dart';
import '../../features/cart/domain/usecases/get_checkout_usecase.dart';
import '../../features/cart/domain/usecases/remove_line_items_usecase.dart';
import '../../features/cart/domain/usecases/update_line_items_usecase.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_brands_usecase.dart';
import '../../features/products/domain/usecases/get_collection_by_handle_usecase.dart';
import '../../features/products/domain/usecases/get_collections_usecase.dart';
import '../../features/products/domain/usecases/get_product_by_handle_usecase.dart';
import '../../features/products/domain/usecases/get_product_recommendations_usecase.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../../services/graphql_base_service.dart';

/// Service Locator Instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // ========== External Dependencies ==========
  // GraphQL Service (Singleton)
  sl.registerLazySingleton<ShopifyGraphQLService>(
    () => ShopifyGraphQLService(),
  );

  // ========== Products Feature ==========
  // Data Sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(graphQLService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProductsUsecase(sl()));
  sl.registerLazySingleton(() => GetProductByHandleUsecase(sl()));
  sl.registerLazySingleton(() => GetCollectionsUsecase(sl()));
  sl.registerLazySingleton(() => GetCollectionByHandleUsecase(sl()));
  sl.registerLazySingleton(() => GetBrandsUsecase(sl()));
  sl.registerLazySingleton(() => GetProductRecommendationsUsecase(sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(
    () => ProductBloc(
      getProductsUsecase: sl(),
      getProductByHandleUsecase: sl(),
      getCollectionsUsecase: sl(),
      getCollectionByHandleUsecase: sl(),
      getBrandsUsecase: sl(),
      getProductRecommendationsUsecase: sl(),
    ),
  );

  // ========== Cart Feature ==========
  // Data Sources
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(graphQLService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateCheckoutUsecase(sl()));
  sl.registerLazySingleton(() => GetCheckoutUsecase(sl()));
  sl.registerLazySingleton(() => AddLineItemsUsecase(sl()));
  sl.registerLazySingleton(() => UpdateLineItemsUsecase(sl()));
  sl.registerLazySingleton(() => RemoveLineItemsUsecase(sl()));

  // Cubit (Singleton - shared cart state across app)
  sl.registerLazySingleton(
    () => CartCubit(
      createCheckoutUsecase: sl(),
      getCheckoutUsecase: sl(),
      addLineItemsUsecase: sl(),
      updateLineItemsUsecase: sl(),
      removeLineItemsUsecase: sl(),
    ),
  );
}
