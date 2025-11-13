import 'package:get_it/get_it.dart';
import 'package:iconnect/features/products/data/datasources/product_remote_datasource.dart';
import 'package:iconnect/features/products/data/repositories/product_repository_impl.dart';
import 'package:iconnect/features/products/domain/repositories/product_repository.dart';
import 'package:iconnect/features/products/domain/usecases/get_collections_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_product_by_handle_usecase.dart';
import 'package:iconnect/features/products/domain/usecases/get_products_usecase.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/services/graphql_base_service.dart';

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

  // BLoC (Factory - new instance each time)
  sl.registerFactory(
    () => ProductBloc(
      getProductsUsecase: sl(),
      getProductByHandleUsecase: sl(),
      getCollectionsUsecase: sl(),
    ),
  );
}

