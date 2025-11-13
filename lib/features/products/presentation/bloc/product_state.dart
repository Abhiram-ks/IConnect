import 'package:equatable/equatable.dart';
import 'package:iconnect/features/products/domain/entities/collection_entity.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';

/// Product States
abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class ProductInitial extends ProductState {}

/// Loading state
class ProductLoading extends ProductState {}

/// Load more state (for pagination)
class ProductLoadingMore extends ProductState {
  final List<ProductEntity> currentProducts;

  ProductLoadingMore({required this.currentProducts});

  @override
  List<Object?> get props => [currentProducts];
}

/// Products loaded successfully
class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;
  final bool hasNextPage;
  final String? endCursor;

  ProductsLoaded({
    required this.products,
    required this.hasNextPage,
    this.endCursor,
  });

  @override
  List<Object?> get props => [products, hasNextPage, endCursor];
}

/// Single product loaded successfully
class ProductDetailLoaded extends ProductState {
  final ProductEntity product;

  ProductDetailLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

/// Collections loaded successfully
class CollectionsLoaded extends ProductState {
  final List<CollectionEntity> collections;

  CollectionsLoaded({required this.collections});

  @override
  List<Object?> get props => [collections];
}

/// Collection with products loaded successfully
class CollectionWithProductsLoaded extends ProductState {
  final CollectionEntity collection;
  final List<ProductEntity> products;
  final bool hasNextPage;
  final String? endCursor;

  CollectionWithProductsLoaded({
    required this.collection,
    required this.products,
    required this.hasNextPage,
    this.endCursor,
  });

  @override
  List<Object?> get props => [collection, products, hasNextPage, endCursor];
}

/// Error state
class ProductError extends ProductState {
  final String message;

  ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}

