import 'package:iconnect/data/brand_logos.dart';
import 'package:iconnect/features/products/domain/entities/brand_entity.dart';

/// Brand Model - Extends domain entity and handles JSON serialization
class BrandModel extends BrandEntity {
  const BrandModel({
    required super.id,
    required super.name,
    required super.vendor,
    super.imageUrl,
  });

  /// Factory constructor from vendor name
  /// Automatically fetches logo from BrandLogos mapping
  factory BrandModel.fromVendor({required String vendor, String? imageUrl}) {
    // Generate ID from vendor name (convert to lowercase, replace spaces with hyphens)
    final id = vendor.toLowerCase().replaceAll(' ', '-');

    // Get logo from mapping, fallback to provided imageUrl
    final logoUrl = imageUrl ?? BrandLogos.getLogoForVendor(vendor);

    return BrandModel(id: id, name: vendor, vendor: vendor, imageUrl: logoUrl);
  }

  /// Factory constructor from a flattened map produced in an isolate.
  /// Used for parsing brands from metaobjects GraphQL response
  factory BrandModel.fromFlattenedJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      vendor: json['vendor'] as String? ?? json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'vendor': vendor, 'imageUrl': imageUrl};
  }

  /// Copy with method
  BrandModel copyWith({
    String? id,
    String? name,
    String? vendor,
    String? imageUrl,
  }) {
    return BrandModel(
      id: id ?? this.id,
      name: name ?? this.name,
      vendor: vendor ?? this.vendor,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
