import 'package:iconnect/features/products/domain/entities/collection_entity.dart';

/// Collection Model - Extends domain entity and handles JSON serialization
class CollectionModel extends CollectionEntity {
  const CollectionModel({
    required super.id,
    required super.title,
    required super.handle,
    required super.description,
    super.imageUrl,
    super.link,
  });

  /// Factory constructor from JSON (Shopify GraphQL response)
  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image']?['url'] as String?,
      link: json['link'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'handle': handle,
      'description': description,
      'imageUrl': imageUrl,
      'link': link,
    };
  }

  /// Copy with method
  CollectionModel copyWith({
    String? id,
    String? title,
    String? handle,
    String? description,
    String? imageUrl,
    String? link,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      handle: handle ?? this.handle,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
    );
  }
}

