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
import '../../features/menu/data/datasources/menu_remote_datasource.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/menu/domain/usecases/get_menu_usecase.dart';
import '../../features/menu/presentation/cubit/menu_cubit.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_brands_usecase.dart';
import '../../features/products/domain/usecases/get_collection_by_handle_usecase.dart';
import '../../features/products/domain/usecases/get_collections_usecase.dart';
import '../../features/products/domain/usecases/get_home_banners_usecase.dart';
import '../../features/products/domain/usecases/get_home_screen_sections_usecase.dart';
import '../../features/products/domain/usecases/get_offer_blocks_usecase.dart';
import '../../features/products/domain/usecases/get_product_by_handle_usecase.dart';
import '../../features/products/domain/usecases/get_product_recommendations_usecase.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../../services/graphql_base_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/get_orders_usecase.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/checkout/presentation/cubit/checkout_cubit.dart';

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
  sl.registerLazySingleton(() => GetHomeBannersUsecase(sl()));
  sl.registerLazySingleton(() => GetOfferBlocksUsecase(sl()));
  sl.registerLazySingleton(() => GetHomeScreenSectionsUsecase(sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(
    () => ProductBloc(
      getProductsUsecase: sl(),
      getProductByHandleUsecase: sl(),
      getCollectionsUsecase: sl(),
      getCollectionByHandleUsecase: sl(),
      getBrandsUsecase: sl(),
      getProductRecommendationsUsecase: sl(),
      getHomeBannersUsecase: sl(),
      getOfferBlocksUsecase: sl(),
      getHomeScreenSectionsUsecase: sl(),
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

  // ========== Menu Feature ==========
  // Data Sources
  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(graphQLService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetMenuUseCase(repository: sl()));

  // Cubit (Factory - new instance each time for drawer)
  sl.registerFactory(() => MenuCubit(getMenuUseCase: sl()));

  // ========== Auth Feature ==========
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(graphQLService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => SignupUsecase(sl()));

  // ========== Profile Feature ==========
  // Data Sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(graphQLService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProfileUsecase(sl()));

  // Cubit (Factory - new instance each time)
  sl.registerFactory(
    () => AuthCubit(
      loginUsecase: sl(),
      signupUsecase: sl(),
      getProfileUsecase: sl(),
    ),
  );

  // ========== Orders Feature ==========
  // Data Sources
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(graphQLService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetOrdersUsecase(sl()));

  // Cubit (Factory - new instance each time)
  sl.registerFactory(() => OrdersCubit(getOrdersUsecase: sl()));

  // ========== Checkout Feature ==========
  // Cubit (Factory - or Singleton depending on need, let's use Factory for fresh state on entry or Singleton for shared if needed across screens, but data passing is sequential so Singleton is safer for retaining data across push navigation if not passing bloc)
  // Actually, standard practice for sharing across screens is Singleton or providing strictly up the tree.
  // Given the user wants "global OrderCubit", making it a Singleton is the easiest way to ensure data persistence across the nav without complex provider passing if not using GoRouter/passing args.
  // Wait, sl.registerFactory makes a new one each time. If I use GetIt to access it in UserDetailsScreen, I need it to be the SAME instance.
  // So I MUST use registerLazySingleton for CheckoutCubit if I want `sl<CheckoutCubit>()` to return the same instance with the data.
  sl.registerLazySingleton(() => CheckoutCubit());
}
