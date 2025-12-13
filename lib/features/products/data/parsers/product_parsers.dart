import 'dart:convert';

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
List<Map<String, dynamic>> parseFlattenedRecommendations(
  Map<String, dynamic> data,
) {
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
  final minVariantPrice =
      priceRange?['minVariantPrice'] as Map<String, dynamic>?;
  final maxVariantPrice =
      priceRange?['maxVariantPrice'] as Map<String, dynamic>?;

  final minPrice =
      double.tryParse(minVariantPrice?['amount']?.toString() ?? '0') ?? 0.0;
  final maxPrice =
      double.tryParse(maxVariantPrice?['amount']?.toString() ?? '0') ??
      minPrice;
  final currencyCode = minVariantPrice?['currencyCode'] as String? ?? 'USD';

  // Compare at price
  double? compareAtPrice;
  final compareAtRange = node['compareAtPriceRange'] as Map<String, dynamic>?;
  if (compareAtRange != null) {
    final minCompare =
        compareAtRange['minVariantPrice'] as Map<String, dynamic>?;
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
    final price =
        double.tryParse(priceData?['amount']?.toString() ?? '0') ?? 0.0;
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
List<Map<String, dynamic>> parseFlattenedCollections(
  Map<String, dynamic> data,
) {
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
    'imageUrl':
        (collection['image'] as Map<String, dynamic>?)?['url'] as String?,
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
  final pageInfo =
      productsRoot?['pageInfo'] as Map<String, dynamic>? ?? const {};
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

/// Flattens Shopify `metaobjects` (brand type) to simple brand maps.
/// Flattens nested structures: name.field.value -> name, image.reference.image.url -> imageUrl
List<Map<String, dynamic>> parseFlattenedBrands(Map<String, dynamic> data) {
  final brands = <Map<String, dynamic>>[];
  final metaobjects = data['metaobjects'] as Map<String, dynamic>?;
  if (metaobjects == null) return brands;

  final nodes = metaobjects['nodes'] as List<dynamic>? ?? const [];
  for (final node in nodes) {
    final nodeMap = node as Map<String, dynamic>? ?? const {};
    final id = nodeMap['id'] as String? ?? '';
    final handle = nodeMap['handle'] as String? ?? '';

    // Extract name from nested structure: name.field.value
    final nameField = nodeMap['name'] as Map<String, dynamic>?;
    final name = nameField?['value'] as String? ?? '';

    // Extract image from nested structure: image.reference.image.url and image.reference.image.altText
    final imageField = nodeMap['image'] as Map<String, dynamic>?;
    final reference = imageField?['reference'] as Map<String, dynamic>?;
    final image = reference?['image'] as Map<String, dynamic>?;
    final imageUrl = image?['url'] as String?;

    // Extract category handle from nested structure: category.reference.handle
    final categoryField = nodeMap['category'] as Map<String, dynamic>?;
    final categoryReference =
        categoryField?['reference'] as Map<String, dynamic>?;
    final categoryHandle = categoryReference?['handle'] as String?;

    // Use name as vendor (or handle if name is empty)
    final vendor = name.isNotEmpty ? name : handle;

    brands.add({
      'id': id,
      'handle': handle,
      'name': name,
      'vendor': vendor,
      'imageUrl': imageUrl,
      'categoryHandle': categoryHandle,
    });
  }
  return brands;
}

// ===================== BANNERS =====================

/// Flattens Shopify `metaobjects` (home_banner type) to simple banner maps.
/// Flattens nested structures: title.field.value -> title, image.reference.image.url -> imageUrl
List<Map<String, dynamic>> parseFlattenedBanners(Map<String, dynamic> data) {
  final banners = <Map<String, dynamic>>[];
  final metaobjects = data['metaobjects'] as Map<String, dynamic>?;
  if (metaobjects == null) return banners;

  final nodes = metaobjects['nodes'] as List<dynamic>? ?? const [];
  for (final node in nodes) {
    final nodeMap = node as Map<String, dynamic>? ?? const {};
    final handle = nodeMap['handle'] as String? ?? '';

    // Extract title from nested structure: title.field.value
    final titleField = nodeMap['title'] as Map<String, dynamic>?;
    final title = titleField?['value'] as String?;

    // Extract image from nested structure: image.reference.image.url and image.reference.image.altText
    final imageField = nodeMap['image'] as Map<String, dynamic>?;
    final reference = imageField?['reference'] as Map<String, dynamic>?;
    final image = reference?['image'] as Map<String, dynamic>?;
    final imageUrl = image?['url'] as String?;
    final altText = image?['altText'] as String?;

    // Extract category handle from nested structure: category.reference.handle
    final categoryField = nodeMap['category'] as Map<String, dynamic>?;
    final categoryReference =
        categoryField?['reference'] as Map<String, dynamic>?;
    final categoryHandle = categoryReference?['handle'] as String?;

    banners.add({
      'handle': handle,
      'title': title,
      'imageUrl': imageUrl,
      'altText': altText,
      'categoryHandle': categoryHandle,
    });
  }
  return banners;
}

// ===================== OFFER BLOCKS =====================

/// Flattens Shopify `metaobjects` (offer_section type) to simple offer block maps.
/// Flattens nested structures for hero image, button, featured collection, and items
List<Map<String, dynamic>> parseFlattenedOfferBlocks(
  Map<String, dynamic> data,
) {
  final offerBlocks = <Map<String, dynamic>>[];
  final metaobjects = data['metaobjects'] as Map<String, dynamic>?;
  if (metaobjects == null) return offerBlocks;

  final edges = metaobjects['edges'] as List<dynamic>? ?? const [];
  for (final edge in edges) {
    final nodeMap = (edge as Map)['node'] as Map<String, dynamic>? ?? const {};
    final id = nodeMap['id'] as String? ?? '';

    // Extract title from nested structure: title.field.value
    final titleField = nodeMap['title'] as Map<String, dynamic>?;
    final title = titleField?['value'] as String?;

    // Extract hero image from nested structure: heroImage.reference.image.url
    final heroImageField = nodeMap['heroImage'] as Map<String, dynamic>?;
    final heroReference = heroImageField?['reference'] as Map<String, dynamic>?;
    final heroImage = heroReference?['image'] as Map<String, dynamic>?;
    final heroImageUrl = heroImage?['url'] as String?;
    final heroImageAltText = heroImage?['altText'] as String?;

    // Extract button from button.field.value (JSON string)
    String? buttonText;
    String? buttonUrl;
    final buttonField = nodeMap['button'] as Map<String, dynamic>?;
    final buttonValue = buttonField?['value'] as String?;
    if (buttonValue != null && buttonValue.isNotEmpty) {
      try {
        // Parse JSON string: {"text":"View more offers","url":"https://..."}
        final buttonJson = jsonDecode(buttonValue) as Map<String, dynamic>?;
        buttonText = buttonJson?['text'] as String?;
        buttonUrl = buttonJson?['url'] as String?;
      } catch (e) {
        // If parsing fails, ignore button
        buttonText = null;
        buttonUrl = null;
      }
    }

    // Extract featured collection title
    final featuredCollectionTitleField =
        nodeMap['featured_collection_title'] as Map<String, dynamic>?;
    final featuredCollectionTitle =
        featuredCollectionTitleField?['value'] as String?;

    // Extract featured collection
    final featuredCollectionField =
        nodeMap['featured_collection'] as Map<String, dynamic>?;
    final featuredCollectionReference =
        featuredCollectionField?['reference'] as Map<String, dynamic>?;
    final featuredCollectionHandle =
        featuredCollectionReference?['handle'] as String?;
    final featuredCollectionTitleFromRef =
        featuredCollectionReference?['title'] as String?;
    final featuredCollectionId = featuredCollectionReference?['id'] as String?;
    // Use featured_collection_title field value if available, otherwise use collection title
    final finalFeaturedCollectionTitle =
        featuredCollectionTitle ?? featuredCollectionTitleFromRef;

    // Extract items
    final itemsList = <Map<String, dynamic>>[];
    final itemsField = nodeMap['items'] as Map<String, dynamic>?;
    final itemsReferences = itemsField?['references'] as Map<String, dynamic>?;
    final itemsNodes = itemsReferences?['nodes'] as List<dynamic>? ?? const [];
    for (final itemNode in itemsNodes) {
      final itemMap = itemNode as Map<String, dynamic>? ?? const {};

      // Extract item image
      final itemImageField = itemMap['itemImage'] as Map<String, dynamic>?;
      final itemImageReference =
          itemImageField?['reference'] as Map<String, dynamic>?;
      final itemImage = itemImageReference?['image'] as Map<String, dynamic>?;
      final itemImageUrl = itemImage?['url'] as String?;
      final itemAltText = itemImage?['altText'] as String?;

      // Extract item collection
      final itemCollectionField =
          itemMap['itemCollection'] as Map<String, dynamic>?;
      final itemCollectionReference =
          itemCollectionField?['reference'] as Map<String, dynamic>?;
      final itemCollectionHandle =
          itemCollectionReference?['handle'] as String?;
      final itemCollectionTitle = itemCollectionReference?['title'] as String?;
      final itemCollectionId = itemCollectionReference?['id'] as String?;

      itemsList.add({
        'imageUrl': itemImageUrl,
        'altText': itemAltText,
        'collectionHandle': itemCollectionHandle,
        'collectionTitle': itemCollectionTitle,
        'collectionId': itemCollectionId,
      });
    }

    offerBlocks.add({
      'id': id,
      'title': title,
      'heroImageUrl': heroImageUrl,
      'heroImageAltText': heroImageAltText,
      'buttonText': buttonText,
      'buttonUrl': buttonUrl,
      'featuredCollectionTitle': finalFeaturedCollectionTitle,
      'featuredCollectionHandle': featuredCollectionHandle,
      'featuredCollectionId': featuredCollectionId,
      'items': itemsList,
    });
  }
  return offerBlocks;
}
