import '../features/products/data/datasources/product_remote_datasource.dart';
import '../models/collection_filter.dart';

/// Service for fetching collection filters from Shopify API
class CollectionFilterService {
  final ProductRemoteDataSource remoteDataSource;

  CollectionFilterService(this.remoteDataSource);

  /// Fetch filters for a collection
  Future<List<CollectionFilter>> getCollectionFilters({
    required String handle,
  }) async {
    try {
      final result = await remoteDataSource.getCollectionWithFilters(
        handle: handle,
      );

      final collection = result['collection'] as Map<String, dynamic>?;
      if (collection == null) {
        return [];
      }

      final products = collection['products'] as Map<String, dynamic>?;
      if (products == null) {
        return [];
      }

      final filters = products['filters'] as List<dynamic>?;
      if (filters == null || filters.isEmpty) {
        return [];
      }

      return filters
          .map(
            (filter) =>
                CollectionFilter.fromJson(filter as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching collection filters: $e');
      return [];
    }
  }
}
