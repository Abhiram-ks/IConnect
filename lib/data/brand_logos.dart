/// Brand Logo Mapping
/// Maps vendor names to their brand logos
/// You can update this with actual brand logos or fetch from Shopify metafields
class BrandLogos {
  static const Map<String, String> logos = {
    'Apple': 'https://graphicsprings.com/wp-content/uploads/2023/07/image-58-1024x512.png',
    'Nothing': 'https://images.indianexpress.com/2021/07/Nothing-logo.jpg',
    'Samsung': 'https://cdn.logojoy.com/wp-content/uploads/20240909124957/Samsung-logo-1993-600x319.png',
    'Nokia': 'https://static.vecteezy.com/system/resources/previews/019/909/657/non_2x/nokia-transparent-nokia-free-free-png.png',
    'Sony': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Sony_logo.svg/800px-Sony_logo.svg.png',
    'OPPO': 'https://upload.wikimedia.org/wikipedia/commons/1/13/OPPO_Logo_wiki.png',
    'Vivo': 'https://upload.wikimedia.org/wikipedia/commons/e/e5/Vivo_mobile_logo.png',
    'Microsoft': 'https://toppng.com/uploads/preview/windows-logo-and-name-116093828229pgbffxv7q.png',
    'Google': 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png',
    'Xiaomi': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Xiaomi_logo.svg/2048px-Xiaomi_logo.svg.png',
    'OnePlus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/OnePlus_logo.svg/2048px-OnePlus_logo.svg.png',
    'Huawei': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Huawei_Standard_logo.svg/2048px-Huawei_Standard_logo.svg.png',
    'Realme': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Realme_logo.svg/2048px-Realme_logo.svg.png',
    'Motorola': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Motorola_logo.svg/2048px-Motorola_logo.svg.png',
    'LG': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/LG_symbol.svg/2048px-LG_symbol.svg.png',
    'Asus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/ASUS_Logo.svg/2048px-ASUS_Logo.svg.png',
    'Lenovo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Lenovo_logo_2015.svg/2048px-Lenovo_logo_2015.svg.png',
    'HP': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/HP_logo_2012.svg/2048px-HP_logo_2012.svg.png',
    'Dell': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Dell_Logo.svg/2048px-Dell_Logo.svg.png',
    'Acer': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Acer_2011.svg/2048px-Acer_2011.svg.png',
  };

  /// Get logo URL for a vendor
  /// Returns null if vendor logo is not found
  static String? getLogoForVendor(String vendor) {
    // Try exact match first
    if (logos.containsKey(vendor)) {
      return logos[vendor];
    }

    // Try case-insensitive match
    final vendorLower = vendor.toLowerCase();
    for (final entry in logos.entries) {
      if (entry.key.toLowerCase() == vendorLower) {
        return entry.value;
      }
    }

    return null;
  }

  /// Check if vendor has a logo
  static bool hasLogo(String vendor) {
    return getLogoForVendor(vendor) != null;
  }
}

