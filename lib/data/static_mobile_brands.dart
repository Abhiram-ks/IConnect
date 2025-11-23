/// Static Mobile Brands Data for Qatar Market
/// Contains popular mobile phone brands available in Qatar with their logos
class StaticMobileBrand {
  final String id;
  final String name;
  final String vendor;
  final String imageUrl;

  const StaticMobileBrand({
    required this.id,
    required this.name,
    required this.vendor,
    required this.imageUrl,
  });
}

class StaticMobileBrands {
  static const List<StaticMobileBrand> brands = [
    StaticMobileBrand(
      id: 'apple',
      name: 'Apple',
      vendor: 'Apple',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/apple.jpg?v=1739776760',
    ),
    StaticMobileBrand(
      id: 'samsung',
      name: 'Samsung',
      vendor: 'Samsung',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/SAMSUNG.jpg?v=1739776760',
    ),
    StaticMobileBrand(
      id: 'xiaomi',
      name: 'Xiaomi',
      vendor: 'Xiaomi',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/Xiaomi_products_in_qatar_9fbf3ee0-ab6b-49c0-baf7-b16b2c37a663.png?v=1748692707',
    ),
    StaticMobileBrand(
      id: 'oppo',
      name: 'OPPO',
      vendor: 'OPPO',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/oppo.jpg?v=1739776760',
    ),
    StaticMobileBrand(
      id: 'vivo',
      name: 'Vivo',
      vendor: 'Vivo',
      imageUrl: 'https://logo.clearbit.com/vivo.com',
    ),
    StaticMobileBrand(
      id: 'huawei',
      name: 'Huawei',
      vendor: 'Huawei',
      imageUrl: 'https://logo.clearbit.com/huawei.com',
    ),
    StaticMobileBrand(
      id: 'oneplus',
      name: 'OnePlus',
      vendor: 'OnePlus',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/NEVER_SET.jpg?v=1739776760',
    ),
    StaticMobileBrand(
      id: 'realme',
      name: 'Realme',
      vendor: 'Realme',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/REALME_1.jpg?v=1739776760',
    ),
    StaticMobileBrand(
      id: 'nokia',
      name: 'Nokia',
      vendor: 'Nokia',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Nokia_wordmark.svg/200px-Nokia_wordmark.svg.png',
    ),
    StaticMobileBrand(
      id: 'honor',
      name: 'Honor',
      vendor: 'Honor',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/honor.jpg?v=1739776760',
    ),
    StaticMobileBrand(
      id: 'google',
      name: 'Google Pixel',
      vendor: 'Google',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/google.jpg?v=1739776760',
    ),
    StaticMobileBrand(
      id: 'motorola',
      name: 'Motorola',
      vendor: 'Motorola',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/MOTO.jpg?v=1747998628',
    ),
    // StaticMobileBrand(
    //   id: 'sony',
    //   name: 'Sony',
    //   vendor: 'Sony',
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Sony_logo.svg/800px-Sony_logo.svg.png',
    // ),
    // StaticMobileBrand(
    //   id: 'asus',
    //   name: 'ASUS',
    //   vendor: 'ASUS',
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/ASUS_Logo.svg/2048px-ASUS_Logo.svg.png',
    // ),
    StaticMobileBrand(
      id: 'lenovo',
      name: 'Lenovo',
      vendor: 'Lenovo',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Lenovo_logo_2015.svg/200px-Lenovo_logo_2015.svg.png',
    ),
    // StaticMobileBrand(
    //   id: 'infinix',
    //   name: 'Infinix',
    //   vendor: 'Infinix',
    //   imageUrl: 'https://logo.clearbit.com/infinixmobility.com',
    // ),
    StaticMobileBrand(
      id: 'tecno',
      name: 'Tecno',
      vendor: 'Tecno',
      imageUrl: 'https://logo.clearbit.com/tecno-mobile.com',
    ),
    StaticMobileBrand(
      id: 'nothing',
      name: 'Nothing',
      vendor: 'Nothing',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/nothing.jpg?v=1739776759',
    ),
    StaticMobileBrand(
      id: 'jbl',
      name: 'JBL',
      vendor: 'JBL',
      imageUrl: 'https://iconnectqatar.com/cdn/shop/files/jbl.jpg?v=1739776760',
    ),
    StaticMobileBrand(
      id: 'anker',
      name: 'Anker',
      vendor: 'Anker',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/anker.jpg?v=1739776760',
    ),
    StaticMobileBrand(
      id: 'bose',
      name: 'Bose',
      vendor: 'Bose',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/Bose_Speaker_in_qatar.png?v=1761566082',
    ),
    StaticMobileBrand(
      id: 'dyson',
      name: 'Dyson',
      vendor: 'Dyson',
      imageUrl:
          'https://iconnectqatar.com/cdn/shop/files/Dyson_products_in_qatar.png?v=1761566445',
    ),
  ];

  /// Get all brands
  static List<StaticMobileBrand> getAllBrands() {
    return brands;
  }

  /// Get brand by vendor name
  static StaticMobileBrand? getBrandByVendor(String vendor) {
    try {
      return brands.firstWhere(
        (brand) => brand.vendor.toLowerCase() == vendor.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get brand by id
  static StaticMobileBrand? getBrandById(String id) {
    try {
      return brands.firstWhere(
        (brand) => brand.id.toLowerCase() == id.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
