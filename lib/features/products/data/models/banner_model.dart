import 'package:iconnect/features/products/domain/entities/banner_entity.dart';

/// Banner Model - Extends domain entity and handles JSON serialization
class BannerModel extends BannerEntity {
  const BannerModel({
    required super.handle,
    super.title,
    super.imageUrl,
    super.altText,
    super.categoryHandle,
  });

  /// Factory constructor from JSON (Shopify GraphQL response)
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    // Extract title from nested structure: title.field.value
    final titleField = json['title'] as Map<String, dynamic>?;
    final title = titleField?['value'] as String?;

    // Extract image from nested structure: image.reference.image.url and image.reference.image.altText
    final imageField = json['image'] as Map<String, dynamic>?;
    final reference = imageField?['reference'] as Map<String, dynamic>?;
    final image = reference?['image'] as Map<String, dynamic>?;

    // Extract category handle from nested structure: category.reference.handle
    final categoryField = json['category'] as Map<String, dynamic>?;
    final categoryReference =
        categoryField?['reference'] as Map<String, dynamic>?;
    final categoryHandle = categoryReference?['handle'] as String?;

    return BannerModel(
      handle: json['handle'] as String? ?? '',
      title: title,
      imageUrl: image?['url'] as String?,
      altText: image?['altText'] as String?,
      categoryHandle: categoryHandle,
    );
  }

  /// Factory constructor from a flattened map produced in an isolate.
  factory BannerModel.fromFlattenedJson(Map<String, dynamic> json) {
    return BannerModel(
      handle: json['handle'] as String? ?? '',
      title: json['title'] as String?,
      imageUrl: json['imageUrl'] as String?,
      altText: json['altText'] as String?,
      categoryHandle: json['categoryHandle'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'handle': handle,
      'title': title,
      'imageUrl': imageUrl,
      'altText': altText,
      'categoryHandle': categoryHandle,
    };
  }

  /// Copy with method
  BannerModel copyWith({
    String? handle,
    String? title,
    String? imageUrl,
    String? altText,
    String? categoryHandle,
  }) {
    return BannerModel(
      handle: handle ?? this.handle,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      altText: altText ?? this.altText,
      categoryHandle: categoryHandle ?? this.categoryHandle,
    );
  }
}
