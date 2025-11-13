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
  final bool loadMore;

  LoadProductsRequested({
    this.first = 20,
    this.after,
    this.query,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [first, after, query, loadMore];
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

  LoadCollectionsRequested({this.first = 10});

  @override
  List<Object?> get props => [first];
}

/// Load collection with products event
class LoadCollectionByHandleRequested extends ProductEvent {
  final String handle;
  final int first;

  LoadCollectionByHandleRequested({
    required this.handle,
    this.first = 20,
  });

  @override
  List<Object?> get props => [handle, first];
}

/// Refresh products event
class RefreshProductsRequested extends ProductEvent {}

