import 'package:equatable/equatable.dart';
import 'package:iconnect/models/series_model.dart';

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

/// Search products event - uses Shopify's search API for better results
class SearchProductsRequested extends ProductEvent {
  final String query;
  final int first;
  final String? after;
  final bool loadMore;

  SearchProductsRequested({
    required this.query,
    this.first = 20,
    this.after,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [query, first, after, loadMore];
}

/// Load collections event
class LoadCollectionsRequested extends ProductEvent {
  final int first;
  final bool forBanners;

  LoadCollectionsRequested({this.first = 10, this.forBanners = false});

  @override
  List<Object?> get props => [first, forBanners];
}

/// Load home categories event (first 20 for homepage)
class LoadHomeCategoriesRequested extends ProductEvent {
  final int first;

  LoadHomeCategoriesRequested({this.first = 20});

  @override
  List<Object?> get props => [first];
}

/// Load all categories event (for all categories page, with imageUrls only)
class LoadAllCategoriesRequested extends ProductEvent {
  final int first;

  LoadAllCategoriesRequested({this.first = 250});

  @override
  List<Object?> get props => [first];
}

/// Load collection with products event
class LoadCollectionByHandleRequested extends ProductEvent {
  final String handle;
  final int first;
  final String? after;
  final String? sortKey;
  final bool? reverse;
  final bool loadMore;
  final List<Map<String, dynamic>>? filters;

  LoadCollectionByHandleRequested({
    required this.handle,
    this.first = 20,
    this.after,
    this.sortKey,
    this.reverse,
    this.loadMore = false,
    this.filters,
  });

  @override
  List<Object?> get props => [handle, first, after, sortKey, reverse, loadMore, filters];
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

/// Load product recommendations event
class LoadProductRecommendationsRequested extends ProductEvent {
  final String productId;

  LoadProductRecommendationsRequested({required this.productId});

  @override
  List<Object?> get props => [productId];
}

/// Load all products event (for product screen)
class LoadAllProductsRequested extends ProductEvent {
  final int first;
  final String? after;
  final String? sortKey;
  final bool? reverse;
  final bool loadMore;

  LoadAllProductsRequested({
    this.first = 50,
    this.after,
    this.sortKey,
    this.reverse,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [first, after, sortKey, reverse, loadMore];
}

/// Load iPhone 17 products event (for iPhone 17 screen)
class LoadSeriesProduct extends ProductEvent {
  final ModelName model;
  final int first;
  final String? after;

  LoadSeriesProduct({required this.model, this.first = 100, this.after});

  @override
  List<Object?> get props => [model, first, after];
}

/// Load home banners event
class LoadHomeBannersRequested extends ProductEvent {
  final int first;

  LoadHomeBannersRequested({this.first = 10});

  @override
  List<Object?> get props => [first];
}

/// Load offer blocks event
class LoadOfferBlocksRequested extends ProductEvent {
  LoadOfferBlocksRequested();

  @override
  List<Object?> get props => [];
}

/// Load home screen sections event
class LoadHomeScreenSectionsRequested extends ProductEvent {
  LoadHomeScreenSectionsRequested();

  @override
  List<Object?> get props => [];
}