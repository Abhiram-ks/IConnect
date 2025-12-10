import 'package:iconnect/features/products/domain/entities/offer_entity.dart';

/// Offer Item Model - Extends domain entity and handles JSON serialization
class OfferItemModel extends OfferItemEntity {
  const OfferItemModel({
    super.imageUrl,
    super.altText,
    super.collectionHandle,
    super.collectionTitle,
    super.collectionId,
  });

  /// Factory constructor from a flattened map produced in an isolate.
  factory OfferItemModel.fromFlattenedJson(Map<String, dynamic> json) {
    return OfferItemModel(
      imageUrl: json['imageUrl'] as String?,
      altText: json['altText'] as String?,
      collectionHandle: json['collectionHandle'] as String?,
      collectionTitle: json['collectionTitle'] as String?,
      collectionId: json['collectionId'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'altText': altText,
      'collectionHandle': collectionHandle,
      'collectionTitle': collectionTitle,
      'collectionId': collectionId,
    };
  }
}

/// Offer Block Model - Extends domain entity and handles JSON serialization
class OfferBlockModel extends OfferBlockEntity {
  const OfferBlockModel({
    required super.id,
    super.title,
    super.heroImageUrl,
    super.heroImageAltText,
    super.viewMoreCollectionHandle,
    super.viewMoreCollectionTitle,
    super.viewMoreCollectionId,
    super.clearanceCollectionHandle,
    super.clearanceCollectionTitle,
    super.clearanceCollectionId,
    super.items,
  });

  /// Factory constructor from a flattened map produced in an isolate.
  factory OfferBlockModel.fromFlattenedJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map((item) => OfferItemModel.fromFlattenedJson(
              item as Map<String, dynamic>,
            ))
        .toList();

    return OfferBlockModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String?,
      heroImageUrl: json['heroImageUrl'] as String?,
      heroImageAltText: json['heroImageAltText'] as String?,
      viewMoreCollectionHandle: json['viewMoreCollectionHandle'] as String?,
      viewMoreCollectionTitle: json['viewMoreCollectionTitle'] as String?,
      viewMoreCollectionId: json['viewMoreCollectionId'] as String?,
      clearanceCollectionHandle:
          json['clearanceCollectionHandle'] as String?,
      clearanceCollectionTitle: json['clearanceCollectionTitle'] as String?,
      clearanceCollectionId: json['clearanceCollectionId'] as String?,
      items: items,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'heroImageUrl': heroImageUrl,
      'heroImageAltText': heroImageAltText,
      'viewMoreCollectionHandle': viewMoreCollectionHandle,
      'viewMoreCollectionTitle': viewMoreCollectionTitle,
      'viewMoreCollectionId': viewMoreCollectionId,
      'clearanceCollectionHandle': clearanceCollectionHandle,
      'clearanceCollectionTitle': clearanceCollectionTitle,
      'clearanceCollectionId': clearanceCollectionId,
      'items': items.map((item) => (item as OfferItemModel).toJson()).toList(),
    };
  }
}

