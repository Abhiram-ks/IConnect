import 'package:equatable/equatable.dart';

/// Product Events
abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load products event
class LoadProductsRequested extends ProductEvent {
  final int first;
  final String? after;
  final String? query;
  final String? sortKey;
  final bool? reverse;
  final bool loadMore;

  LoadProductsRequested({
    this.first = 20,
    this.after,
    this.query,
    this.sortKey,
    this.reverse,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [first, after, query, sortKey, reverse, loadMore];
}

/// Load product by handle event
class LoadProductByHandleRequested extends ProductEvent {
  final String handle;

  LoadProductByHandleRequested({required this.handle});

  @override
  List<Object?> get props => [handle];
}

/// Load collections event
class LoadCollectionsRequested extends ProductEvent {
  final int first;
  final bool forBanners;

  LoadCollectionsRequested({this.first = 10, this.forBanners = false});

  @override
  List<Object?> get props => [first, forBanners];
}

/// Load collection with products event
class LoadCollectionByHandleRequested extends ProductEvent {
  final String handle;
  final int first;

  LoadCollectionByHandleRequested({required this.handle, this.first = 20});

  @override
  List<Object?> get props => [handle, first];
}

/// Load brands event
class LoadBrandsRequested extends ProductEvent {
  final int first;

  LoadBrandsRequested({this.first = 250});

  @override
  List<Object?> get props => [first];
}

/// Load products by brand (vendor) event
class LoadBrandProductsRequested extends ProductEvent {
  final String vendor;
  final int first;
  final String? after;
  final bool loadMore;

  LoadBrandProductsRequested({
    required this.vendor,
    this.first = 20,
    this.after,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [vendor, first, after, loadMore];
}

/// Refresh products event
class RefreshProductsRequested extends ProductEvent {}

/// Load category products event
class LoadCategoryProductsRequested extends ProductEvent {
  final String categoryName;
  final String collectionHandle;
  final int first;
  final bool loadMore;

  LoadCategoryProductsRequested({
    required this.categoryName,
    required this.collectionHandle,
    this.first = 10,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [categoryName, collectionHandle, first, loadMore];
}