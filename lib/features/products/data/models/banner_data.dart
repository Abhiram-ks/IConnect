import 'package:iconnect/features/products/domain/entities/collection_entity.dart';

/// Banner data model - represents a banner/slider item
class BannerData {
  final String imageUrl;
  final String? mobileImageUrl;
  final String link;
  final String? title;

  const BannerData({
    required this.imageUrl,
    this.mobileImageUrl,
    required this.link,
    this.title,
  });

  /// Convert to CollectionEntity for compatibility with existing code
  CollectionEntity toCollectionEntity() {
    return CollectionEntity(
      id: 'banner-${imageUrl.hashCode}',
      title: title ?? 'Banner',
      handle: '',
      description: '',
      imageUrl: imageUrl,
      link: link,
    );
  }
}

/// Static banner data - extracted from website HTML
class BannerDataSource {
  static const String baseUrl = 'https://iconnectqatar.com/cdn/shop/files';

  static List<BannerData> getBanners() {
    return [
      // Banner 1: Offers/Deals (data-slide="0")
      BannerData(
        imageUrl:
            '$baseUrl/1920_x_367_banner_Pc_size-4.webp?v=1763378902&width=3840',
        mobileImageUrl:
            '$baseUrl/Moblie_Deals_explosion_week.webp?v=1763378925&width=1000',
        link: '/pages/offers',
        title: 'Deals Explosion Week',
      ),

      // Banner 2: iPhone 17 Pro Max (data-slide="1")
      BannerData(
        imageUrl: '$baseUrl/iphone_17_banner.webp?v=1763116515&width=3840',
        mobileImageUrl:
            '$baseUrl/IPhone_17_Pro_Max_Qatar.webp?v=1758520965&width=1000',
        link: '/pages/iphone-17-pro-max-price-in-qatar',
        title: 'iPhone 17 Pro Max',
      ),

      // Banner 3: Motorola Edge 70 (data-slide="2")
      BannerData(
        imageUrl: '$baseUrl/motorola_edge_70.webp?v=1763034672&width=3840',
        mobileImageUrl:
            '$baseUrl/motorola_edge_70_qatar.webp?v=1763034692&width=1000',
        link:
            '/search?options%5Bunavailable_products%5D=last&options%5Bprefix%5D=last&options%5Bfields%5D=title%2Cvendor%2Cproduct_type%2Cvariants.title&q=motorola+edge+70',
        title: 'Motorola Edge 70',
      ),

      // Banner 4: OnePlus 15 (data-slide="3")
      BannerData(
        imageUrl:
            '$baseUrl/1920_x_367_banner_ONE_PLUS_15.webp?v=1763531410&width=3840',
        mobileImageUrl:
            '$baseUrl/Moblie_-_oneplus_15.webp?v=1763531411&width=1000',
        link: '/collections/one-plus-15-price-in-qatar',
        title: 'OnePlus 15',
      ),

      // Banner 5: Apple Watch Series 11 (data-slide="4")
      BannerData(
        imageUrl: '$baseUrl/Apple_watch_11_seires.webp?v=1758180205&width=3840',
        mobileImageUrl:
            '$baseUrl/iwatch_series_11_Moblie.webp?v=1758180204&width=1000',
        link: '/collections/apple-watch-series-11-se-and-ultra',
        title: 'Apple Watch Series 11',
      ),

      // Banner 6: PS5 Bundle (data-slide="5")
      BannerData(
        imageUrl: '$baseUrl/ps5_banner.webp?v=1763116687&width=3840',
        mobileImageUrl:
            '$baseUrl/ps5_mobile_banner.webp?v=1763116687&width=1000',
        link:
            '/products/sony-playstation-ps5-digital-825gb-with-ea-sports-fc-26-bundle',
        title: 'PS5 Digital Bundle',
      ),
    ];
  }
}
