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
  final String? pdfUrl;
  final String? featuredCollectionTitle;
  final String? featuredCollectionHandle;
  final String? featuredCollectionId;
  final String? clearanceCollectionHandle;
  final String? clearanceCollectionTitle;
  final String? clearanceCollectionId;

  const OfferBlockEntity({
    required this.id,
    this.title,
    this.pdfUrl,
    this.featuredCollectionTitle,
    this.featuredCollectionHandle,
    this.featuredCollectionId,
    this.clearanceCollectionHandle,
    this.clearanceCollectionTitle,
    this.clearanceCollectionId,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        pdfUrl,
        featuredCollectionTitle,
        featuredCollectionHandle,
        featuredCollectionId,
        clearanceCollectionHandle,
        clearanceCollectionTitle,
        clearanceCollectionId,
      ];
}

