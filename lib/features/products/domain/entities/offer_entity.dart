import 'package:equatable/equatable.dart';

/// Offer Item Entity - Represents an item within an offer block
class OfferItemEntity extends Equatable {
  final String? imageUrl;
  final String? altText;
  final String? collectionHandle;
  final String? collectionTitle;
  final String? collectionId;

  const OfferItemEntity({
    this.imageUrl,
    this.altText,
    this.collectionHandle,
    this.collectionTitle,
    this.collectionId,
  });

  @override
  List<Object?> get props => [
        imageUrl,
        altText,
        collectionHandle,
        collectionTitle,
        collectionId,
      ];
}

/// Offer Block Entity - Represents an offer section block
class OfferBlockEntity extends Equatable {
  final String id;
  final String? title;
  final String? heroImageUrl;
  final String? heroImageAltText;
  final String? viewMoreCollectionHandle;
  final String? viewMoreCollectionTitle;
  final String? viewMoreCollectionId;
  final String? clearanceCollectionHandle;
  final String? clearanceCollectionTitle;
  final String? clearanceCollectionId;
  final List<OfferItemEntity> items;

  const OfferBlockEntity({
    required this.id,
    this.title,
    this.heroImageUrl,
    this.heroImageAltText,
    this.viewMoreCollectionHandle,
    this.viewMoreCollectionTitle,
    this.viewMoreCollectionId,
    this.clearanceCollectionHandle,
    this.clearanceCollectionTitle,
    this.clearanceCollectionId,
    this.items = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        heroImageUrl,
        heroImageAltText,
        viewMoreCollectionHandle,
        viewMoreCollectionTitle,
        viewMoreCollectionId,
        clearanceCollectionHandle,
        clearanceCollectionTitle,
        clearanceCollectionId,
        items,
      ];
}

