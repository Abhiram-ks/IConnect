import 'package:iconnect/features/products/domain/entities/home_screen_entity.dart';

/// Banner item model
class BannerItemModel extends BannerItemEntity {
  const BannerItemModel({
    required super.id,
    required super.handle,
    super.imageUrl,
    super.altText,
    required super.actionType,
    super.productId,
    super.productHandle,
    super.productTitle,
    super.productImageUrl,
    super.collectionId,
    super.collectionHandle,
    super.collectionTitle,
    super.collectionImageUrl,
    super.pageName,
  });

  factory BannerItemModel.fromJson(Map<String, dynamic> json) {
    // Extract action type
    final actionTypeValue = json['actionType']?['value'] as String?;
    final actionType = BannerActionType.fromString(actionTypeValue);

    // Extract image data
    final imageRef = json['image']?['reference'] as Map<String, dynamic>?;
    final imageData = imageRef?['image'] as Map<String, dynamic>?;
    final imageUrl = imageData?['url'] as String?;
    final altText = imageData?['altText'] as String?;

    // Extract product data
    final productRef = json['product']?['reference'] as Map<String, dynamic>?;
    final productId = productRef?['id'] as String?;
    final productHandle = productRef?['handle'] as String?;
    final productTitle = productRef?['title'] as String?;
    final productFeaturedImage = productRef?['featuredImage'] as Map<String, dynamic>?;
    final productImageUrl = productFeaturedImage?['url'] as String?;

    // Extract collection data
    final collectionRef = json['collection']?['reference'] as Map<String, dynamic>?;
    final collectionId = collectionRef?['id'] as String?;
    final collectionHandle = collectionRef?['handle'] as String?;
    final collectionTitle = collectionRef?['title'] as String?;
    final collectionImage = collectionRef?['image'] as Map<String, dynamic>?;
    final collectionImageUrl = collectionImage?['url'] as String?;

    // Extract page data
    final pageRef = json['page']?['reference'] as Map<String, dynamic>?;
    final pageTitle = pageRef?['title']?['value'] as String?;

    return BannerItemModel(
      id: json['id'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      imageUrl: imageUrl,
      altText: altText,
      actionType: actionType,
      productId: productId,
      productHandle: productHandle,
      productTitle: productTitle,
      productImageUrl: productImageUrl,
      collectionId: collectionId,
      collectionHandle: collectionHandle,
      collectionTitle: collectionTitle,
      collectionImageUrl: collectionImageUrl,
      pageName: pageTitle,
    );
  }
}

/// Featured collection model
class FeaturedCollectionModel extends FeaturedCollectionEntity {
  const FeaturedCollectionModel({
    required super.id,
    required super.handle,
    required super.title,
    super.imageUrl,
    super.altText,
  });

  factory FeaturedCollectionModel.fromJson(Map<String, dynamic> json) {
    final imageData = json['image'] as Map<String, dynamic>?;
    
    return FeaturedCollectionModel(
      id: json['id'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: imageData?['url'] as String?,
      altText: imageData?['altText'] as String?,
    );
  }
}

/// Home screen section model
class HomeScreenSectionModel extends HomeScreenSectionEntity {
  const HomeScreenSectionModel({
    required super.id,
    required super.handle,
    super.collectionTitle,
    super.featuredCollection,
    super.horizontalBanners,
    super.verticalBanners,
  });

  factory HomeScreenSectionModel.fromJson(Map<String, dynamic> json) {
    // Extract collection title
    final collectionTitleField = json['collectionTitle'] as Map<String, dynamic>?;
    final collectionTitle = collectionTitleField?['value'] as String?;

    // Extract featured collection
    final featuredCollectionField = json['featuredCollection'] as Map<String, dynamic>?;
    final featuredCollectionRef = featuredCollectionField?['reference'] as Map<String, dynamic>?;
    FeaturedCollectionModel? featuredCollection;
    if (featuredCollectionRef != null) {
      featuredCollection = FeaturedCollectionModel.fromJson(featuredCollectionRef);
    }

    // Extract horizontal banners
    final horizontalBannersField = json['horizontalBanners'] as Map<String, dynamic>?;
    final horizontalBannersRefs = horizontalBannersField?['references'] as Map<String, dynamic>?;
    final horizontalBannersNodes = horizontalBannersRefs?['nodes'] as List<dynamic>? ?? [];
    final horizontalBanners = horizontalBannersNodes
        .map((node) => BannerItemModel.fromJson(node as Map<String, dynamic>))
        .toList();

    // Extract vertical banners
    final verticalBannersField = json['verticalBanners'] as Map<String, dynamic>?;
    final verticalBannersRefs = verticalBannersField?['references'] as Map<String, dynamic>?;
    final verticalBannersNodes = verticalBannersRefs?['nodes'] as List<dynamic>? ?? [];
    final verticalBanners = verticalBannersNodes
        .map((node) => BannerItemModel.fromJson(node as Map<String, dynamic>))
        .toList();

    return HomeScreenSectionModel(
      id: json['id'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      collectionTitle: collectionTitle,
      featuredCollection: featuredCollection,
      horizontalBanners: horizontalBanners,
      verticalBanners: verticalBanners,
    );
  }
}

