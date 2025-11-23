import 'package:equatable/equatable.dart';

/// Collection Entity - Pure business object
class CollectionEntity extends Equatable {
  final String id;
  final String title;
  final String handle;
  final String description;
  final String? imageUrl;
  final String? link; // URL/link for navigation (e.g., /products/..., /collections/..., /pages/...)

  const CollectionEntity({
    required this.id,
    required this.title,
    required this.handle,
    required this.description,
    this.imageUrl,
    this.link,
  });

  @override
  List<Object?> get props => [id, title, handle, description, imageUrl, link];
}

