import 'package:equatable/equatable.dart';

/// Collection Entity - Pure business object
class CollectionEntity extends Equatable {
  final String id;
  final String title;
  final String handle;
  final String description;
  final String? imageUrl;

  const CollectionEntity({
    required this.id,
    required this.title,
    required this.handle,
    required this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, handle, description, imageUrl];
}

