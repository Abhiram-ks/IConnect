import 'package:equatable/equatable.dart';

/// Action types for banner navigation
enum BannerActionType {
  product,
  collection,
  page,
  none;

  static BannerActionType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'product':
        return BannerActionType.product;
      case 'collection':
        return BannerActionType.collection;
      case 'page':
        return BannerActionType.page;
      default:
        return BannerActionType.none;
    }
  }
}

/// Banner item entity for horizontal and vertical banners
class BannerItemEntity extends Equatable {
  final String id;
  final String handle;
  final String? imageUrl;
  final String? altText;
  final BannerActionType actionType;
  
  // Product action data
  final String? productId;
  final String? productHandle;
  final String? productTitle;
  final String? productImageUrl;
  
  // Collection action data
  final String? collectionId;
  final String? collectionHandle;
  final String? collectionTitle;
  final String? collectionImageUrl;
  
  // Page action data
  final String? pageName;

  const BannerItemEntity({
    required this.id,
    required this.handle,
    this.imageUrl,
    this.altText,
    required this.actionType,
    this.productId,
    this.productHandle,
    this.productTitle,
    this.productImageUrl,
    this.collectionId,
    this.collectionHandle,
    this.collectionTitle,
    this.collectionImageUrl,
    this.pageName,
  });

  @override
  List<Object?> get props => [
        id,
        handle,
        imageUrl,
        altText,
        actionType,
        productId,
        productHandle,
        productTitle,
        productImageUrl,
        collectionId,
        collectionHandle,
        collectionTitle,
        collectionImageUrl,
        pageName,
      ];
}

/// Featured collection entity
class FeaturedCollectionEntity extends Equatable {
  final String id;
  final String handle;
  final String title;
  final String? imageUrl;
  final String? altText;

  const FeaturedCollectionEntity({
    required this.id,
    required this.handle,
    required this.title,
    this.imageUrl,
    this.altText,
  });

  @override
  List<Object?> get props => [id, handle, title, imageUrl, altText];
}

/// Home screen section entity
class HomeScreenSectionEntity extends Equatable {
  final String id;
  final String handle;
  final String? collectionTitle;
  final FeaturedCollectionEntity? featuredCollection;
  final List<BannerItemEntity> horizontalBanners;
  final List<BannerItemEntity> verticalBanners;

  const HomeScreenSectionEntity({
    required this.id,
    required this.handle,
    this.collectionTitle,
    this.featuredCollection,
    this.horizontalBanners = const [],
    this.verticalBanners = const [],
  });

  @override
  List<Object?> get props => [
        id,
        handle,
        collectionTitle,
        featuredCollection,
        horizontalBanners,
        verticalBanners,
      ];
}

