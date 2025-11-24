/// NOTE: All functions here must be top-level and return/send only
/// values transferable across isolates (Map/List/num/bool/String/null).
/// They are designed to be used with `compute` or `Isolate.run`.

// ===================== PRODUCTS =====================

/// Flattens Shopify GraphQL products structure to a list of simple product maps.
/// Input is the raw GraphQL `data` map.
List<Map<String, dynamic>> parseFlattenedProducts(Map<String, dynamic> data) {
  final products = <Map<String, dynamic>>[];

  final productsRoot = data['products'];
  if (productsRoot == null) return products;

  final edges = productsRoot['edges'] as List<dynamic>? ?? const [];
  for (final edge in edges) {
    final node = (edge as Map)['node'] as Map<String, dynamic>? ?? const {};
    products.add(_flattenProduct(node));
  }

  return products;
}

/// Flattens Shopify `productRecommendations` list to simple product maps.
List<Map<String, dynamic>> parseFlattenedRecommendations(Map<String, dynamic> data) {
  final list = <Map<String, dynamic>>[];
  final recs = data['productRecommendations'] as List<dynamic>? ?? const [];
  for (final item in recs) {
    list.add(_flattenProduct((item as Map<String, dynamic>)));
  }
  return list;
}

/// Flattens a single product node to a simple map.
Map<String, dynamic> parseFlattenedProduct(Map<String, dynamic> productNode) {
  return _flattenProduct(productNode);
}

Map<String, dynamic> _flattenProduct(Map<String, dynamic> node) {
  // Images
  final images = <String>[];
  final imagesRoot = node['images'] as Map<String, dynamic>?;
  final imageEdges = imagesRoot?['edges'] as List<dynamic>? ?? const [];
  for (final e in imageEdges) {
    final url = (e as Map)['node']?['url'] as String?;
    if (url != null) images.add(url);
  }

  // Featured image
  final featuredImage = node['featuredImage']?['url'] as String?;

  // Price range
  final priceRange = node['priceRange'] as Map<String, dynamic>?;
  final minVariantPrice = priceRange?['minVariantPrice'] as Map<String, dynamic>?;
  final maxVariantPrice = priceRange?['maxVariantPrice'] as Map<String, dynamic>?;

  final minPrice = double.tryParse(minVariantPrice?['amount']?.toString() ?? '0') ?? 0.0;
  final maxPrice =
      double.tryParse(maxVariantPrice?['amount']?.toString() ?? '0') ?? minPrice;
  final currencyCode = minVariantPrice?['currencyCode'] as String? ?? 'USD';

  // Compare at price
  double? compareAtPrice;
  final compareAtRange = node['compareAtPriceRange'] as Map<String, dynamic>?;
  if (compareAtRange != null) {
    final minCompare = compareAtRange['minVariantPrice'] as Map<String, dynamic>?;
    if (minCompare != null && minCompare['amount'] != null) {
      compareAtPrice = double.tryParse(minCompare['amount'].toString());
    }
  }

  // Variants
  final variants = <Map<String, dynamic>>[];
  final variantsRoot = node['variants'] as Map<String, dynamic>?;
  final variantEdges = variantsRoot?['edges'] as List<dynamic>? ?? const [];
  for (final e in variantEdges) {
    final v = (e as Map)['node'] as Map<String, dynamic>? ?? const {};
    final priceData = v['price'] as Map<String, dynamic>?;
    final price = double.tryParse(priceData?['amount']?.toString() ?? '0') ?? 0.0;
    final vCurrencyCode = priceData?['currencyCode'] as String? ?? 'USD';

    double? vCompareAtPrice;
    final vCompareData = v['compareAtPrice'] as Map<String, dynamic>?;
    if (vCompareData != null && vCompareData['amount'] != null) {
      vCompareAtPrice = double.tryParse(vCompareData['amount'].toString());
    }
    final vImage = (v['image'] as Map<String, dynamic>?)?['url'] as String?;

    variants.add({
      'id': v['id'],
      'title': v['title'] ?? '',
      'price': price,
      'compareAtPrice': vCompareAtPrice,
      'currencyCode': vCurrencyCode,
      'availableForSale': v['availableForSale'] ?? true,
      'image': vImage,
    });
  }

  return {
    'id': node['id'],
    'title': node['title'] ?? '',
    'description': node['description'] ?? '',
    'descriptionHtml': node['descriptionHtml'] ?? '',
    'handle': node['handle'] ?? '',
    'featuredImage': featuredImage,
    'images': images,
    'minPrice': minPrice,
    'maxPrice': maxPrice,
    'compareAtPrice': compareAtPrice,
    'currencyCode': currencyCode,
    'availableForSale': node['availableForSale'] ?? true,
    'variants': variants,
  };
}

// ===================== COLLECTIONS =====================

/// Flattens Shopify `collections` to simple collection maps.
List<Map<String, dynamic>> parseFlattenedCollections(Map<String, dynamic> data) {
  final collections = <Map<String, dynamic>>[];
  final root = data['collections'];
  if (root == null) return collections;
  final edges = root['edges'] as List<dynamic>? ?? const [];
  for (final e in edges) {
    final node = (e as Map)['node'] as Map<String, dynamic>? ?? const {};
    collections.add({
      'id': node['id'],
      'title': node['title'] ?? '',
      'handle': node['handle'] ?? '',
      'description': node['description'] ?? '',
      'imageUrl': (node['image'] as Map<String, dynamic>?)?['url'] as String?,
      'link': node['link'],
    });
  }
  return collections;
}

/// Flattens a collection with products and pageInfo from `collectionByHandle` shape.
Map<String, dynamic> parseFlattenedCollectionWithProducts(
  Map<String, dynamic> data,
) {
  final collection = data['collection'] as Map<String, dynamic>? ?? const {};

  // Flatten collection
  final flattenedCollection = {
    'id': collection['id'],
    'title': collection['title'] ?? '',
    'handle': collection['handle'] ?? '',
    'description': collection['description'] ?? '',
    'imageUrl': (collection['image'] as Map<String, dynamic>?)?['url'] as String?,
    'link': collection['link'],
  };

  // Flatten products
  final products = <Map<String, dynamic>>[];
  final productsRoot = collection['products'] as Map<String, dynamic>?;
  final edges = productsRoot?['edges'] as List<dynamic>? ?? const [];
  for (final e in edges) {
    final node = (e as Map)['node'] as Map<String, dynamic>? ?? const {};
    products.add(_flattenProduct(node));
  }

  // PageInfo
  final pageInfo = productsRoot?['pageInfo'] as Map<String, dynamic>? ?? const {};
  return {
    'collection': flattenedCollection,
    'products': products,
    'pageInfo': {
      'hasNextPage': pageInfo['hasNextPage'] ?? false,
      'endCursor': pageInfo['endCursor'],
    },
  };
}

// ===================== BRANDS =====================

/// Extracts unique vendor names from a products query result.
List<String> parseUniqueVendors(Map<String, dynamic> data) {
  final set = <String>{};
  final productsRoot = data['products'];
  if (productsRoot == null) return [];
  final edges = productsRoot['edges'] as List<dynamic>? ?? const [];
  for (final e in edges) {
    final node = (e as Map)['node'] as Map<String, dynamic>? ?? const {};
    final vendor = node['vendor'] as String?;
    if (vendor != null && vendor.isNotEmpty) set.add(vendor);
  }
  return set.toList();
}


