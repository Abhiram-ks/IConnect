import '../models/category.dart';

class CategoryData {
  static List<Category> getCategories() {
    return [
      Category(
        id: 'mobiles',
        name: 'Mobiles',
        icon: '📱',
        subcategories: [
          Category(id: 'apple', name: 'Apple'),
          Category(id: 'samsung', name: 'Samsung'),
          Category(id: 'honor', name: 'Honor'),
          Category(id: 'xiaomi', name: 'Xiaomi'),
          Category(id: 'oneplus', name: 'OnePlus'),
          Category(id: 'oppo', name: 'OPPO'),
          Category(id: 'vivo', name: 'Vivo'),
          Category(id: 'realme', name: 'Realme'),
          Category(id: 'nothing', name: 'Nothing'),
          Category(id: 'google', name: 'Google Pixel'),
          Category(id: 'sony', name: 'Sony'),
          Category(id: 'huawei', name: 'Huawei'),
        ],
      ),
      Category(
        id: 'accessories',
        name: 'Accessories',
        icon: '🎧',
        subcategories: [
          Category(id: 'phone_cases', name: 'Phone Cases'),
          Category(id: 'screen_protectors', name: 'Screen Protectors'),
          Category(id: 'chargers', name: 'Chargers & Cables'),
          Category(id: 'headphones', name: 'Headphones & Earphones'),
          Category(id: 'power_banks', name: 'Power Banks'),
          Category(id: 'car_holders', name: 'Car Holders'),
          Category(id: 'bluetooth_speakers', name: 'Bluetooth Speakers'),
          Category(id: 'smart_watches', name: 'Smart Watches'),
        ],
      ),
      Category(
        id: 'tablets',
        name: 'Tablets',
        icon: '📱',
        subcategories: [
          Category(id: 'ipad', name: 'iPad'),
          Category(id: 'samsung_tablets', name: 'Samsung Tablets'),
          Category(id: 'huawei_tablets', name: 'Huawei Tablets'),
          Category(id: 'lenovo_tablets', name: 'Lenovo Tablets'),
          Category(id: 'xiaomi_tablets', name: 'Xiaomi Tablets'),
          Category(id: 'amazon_tablets', name: 'Amazon Tablets'),
        ],
      ),
      Category(
        id: 'laptops_desktops',
        name: 'Laptops & Desktops',
        icon: '💻',
        subcategories: [
          Category(id: 'laptops', name: 'Laptops'),
          Category(id: 'desktops', name: 'Desktops'),
          Category(id: 'gaming_laptops', name: 'Gaming Laptops'),
          Category(id: 'business_laptops', name: 'Business Laptops'),
          Category(id: 'ultrabooks', name: 'Ultrabooks'),
          Category(id: 'workstations', name: 'Workstations'),
        ],
      ),
      Category(
        id: 'watches',
        name: 'Watches',
        icon: '⌚',
        subcategories: [
          Category(id: 'apple_watch', name: 'Apple Watch'),
          Category(id: 'samsung_watch', name: 'Samsung Galaxy Watch'),
          Category(id: 'fitbit', name: 'Fitbit'),
          Category(id: 'garmin', name: 'Garmin'),
          Category(id: 'huawei_watch', name: 'Huawei Watch'),
          Category(id: 'fossil_watch', name: 'Fossil Smartwatch'),
        ],
      ),
      Category(
        id: 'home_appliances',
        name: 'Home Appliances',
        icon: '🏠',
        subcategories: [
          Category(id: 'kitchen_appliances', name: 'Kitchen Appliances'),
          Category(id: 'cleaning_appliances', name: 'Cleaning Appliances'),
          Category(id: 'air_conditioners', name: 'Air Conditioners'),
          Category(id: 'refrigerators', name: 'Refrigerators'),
          Category(id: 'washing_machines', name: 'Washing Machines'),
          Category(id: 'smart_home', name: 'Smart Home Devices'),
        ],
      ),
      Category(
        id: 'games',
        name: 'Games',
        icon: '🎮',
        subcategories: [
          Category(id: 'console_games', name: 'Console Games'),
          Category(id: 'pc_games', name: 'PC Games'),
          Category(id: 'mobile_games', name: 'Mobile Games'),
          Category(id: 'gaming_accessories', name: 'Gaming Accessories'),
          Category(id: 'vr_games', name: 'VR Games'),
        ],
      ),
    ];
  }

  static Category? getCategoryById(String id) {
    return _findCategoryById(getCategories(), id);
  }

  static Category? _findCategoryById(List<Category> categories, String id) {
    for (var category in categories) {
      if (category.id == id) {
        return category;
      }
      if (category.subcategories != null) {
        var found = _findCategoryById(category.subcategories!, id);
        if (found != null) {
          return found;
        }
      }
    }
    return null;
  }

  static List<Category> getSubcategories(String parentId) {
    var parent = getCategoryById(parentId);
    return parent?.subcategories ?? [];
  }
}
