import 'package:equatable/equatable.dart';

/// Banner Entity - Pure business object for home banners
class BannerEntity extends Equatable {
  final String handle;
  final String? title;
  final String? imageUrl;
  final String? altText;

  const BannerEntity({
    required this.handle,
    this.title,
    this.imageUrl,
    this.altText,
  });

  @override
  List<Object?> get props => [handle, title, imageUrl, altText];
}

