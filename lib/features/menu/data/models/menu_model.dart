import '../../domain/entities/menu_entity.dart';

/// Menu Model - Extends domain entity and handles JSON serialization
class MenuModel extends MenuEntity {
  const MenuModel({
    required super.title,
    required super.items,
  });

  /// Factory constructor from JSON (Shopify GraphQL response)
  factory MenuModel.fromJson(Map<String, dynamic> json) {
    final itemsList = <MenuItemModel>[];
    
    if (json['items'] != null) {
      final items = json['items'] as List;
      for (final item in items) {
        itemsList.add(MenuItemModel.fromJson(item));
      }
    }

    return MenuModel(
      title: json['title'] as String? ?? '',
      items: itemsList,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'items': items.map((item) => (item as MenuItemModel).toJson()).toList(),
    };
  }
}

/// Menu Item Model - Extends domain entity and handles JSON serialization
class MenuItemModel extends MenuItemEntity {
  const MenuItemModel({
    required super.title,
    required super.url,
    super.items,
  });

  /// Factory constructor from JSON (Shopify GraphQL response)
  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    final nestedItems = <MenuItemModel>[];
    
    if (json['items'] != null) {
      final items = json['items'] as List;
      for (final item in items) {
        nestedItems.add(MenuItemModel.fromJson(item));
      }
    }

    return MenuItemModel(
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      items: nestedItems,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'items': items.map((item) => (item as MenuItemModel).toJson()).toList(),
    };
  }
}

