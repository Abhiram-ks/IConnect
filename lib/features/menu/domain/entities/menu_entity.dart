import 'package:equatable/equatable.dart';

/// Menu Entity - Pure business object representing a Shopify menu
class MenuEntity extends Equatable {
  final String title;
  final List<MenuItemEntity> items;

  const MenuEntity({
    required this.title,
    required this.items,
  });

  @override
  List<Object?> get props => [title, items];
}

/// Menu Item Entity - Represents a menu item with potential nested items
class MenuItemEntity extends Equatable {
  final String title;
  final String url;
  final List<MenuItemEntity> items;

  const MenuItemEntity({
    required this.title,
    required this.url,
    this.items = const [],
  });

  /// Extract collection handle from URL
  /// Example: /collections/electronics -> electronics
  String? get collectionHandle {
    if (url.contains('/collections/')) {
      final parts = url.split('/collections/');
      if (parts.length > 1) {
        // Remove any query parameters or trailing slashes
        final handle = parts[1].split('?').first.split('#').first;
        return handle.replaceAll('/', '');
      }
    }
    return null;
  }

  /// Check if this menu item links to a collection
  bool get isCollection => collectionHandle != null;

  @override
  List<Object?> get props => [title, url, items];
}

