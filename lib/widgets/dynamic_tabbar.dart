import 'package:flutter/material.dart';
import 'package:iconnect/app_palette.dart';

/// A widget that creates a TabBar with dynamically generated tabs based on a list.
/// 
/// This widget is designed to work with API responses where tab data comes dynamically.
/// 
/// Example usage:
/// ```dart
/// // 1. Create a list of tab items
/// final List<TabItem> tabItems = [
///   TabItem(
///     title: 'Home',
///     icon: Icons.home,
///     content: YourCustomWidget(),
///   ),
///   TabItem(
///     title: 'Profile',
///     icon: Icons.person,
///     content: ProfileWidget(),
///   ),
/// ];
/// 
/// // 2. Use the DynamicTabBar widget
/// DynamicTabBar(
///   tabItems: tabItems,
///   isScrollable: true,
///   indicatorColor: AppPalette.blueColor,
/// )
/// 
/// // 3. For API response, convert JSON to TabItem:
/// List<TabItem> tabItems = apiResponse.map((json) => TabItem.fromJson(json)).toList();
/// ```
class DynamicTabBar extends StatefulWidget {
  final List<TabItem> tabItems;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final double? indicatorWeight;

  const DynamicTabBar({
    super.key,
    required this.tabItems,
    this.isScrollable = true,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorWeight = 3.0,
  });

  @override
  State<DynamicTabBar> createState() => _DynamicTabBarState();
}

class _DynamicTabBarState extends State<DynamicTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabItems.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TabBar
        Container(
          decoration: BoxDecoration(
            color: AppPalette.whiteColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: widget.isScrollable,
            indicatorColor: widget.indicatorColor ?? AppPalette.blueColor,
            indicatorWeight: widget.indicatorWeight!,
            labelColor: widget.labelColor ?? AppPalette.blueColor,
            unselectedLabelColor:
                widget.unselectedLabelColor ?? AppPalette.greyColor,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: widget.tabItems
                .map(
                  (item) => Tab(
                    icon: item.icon != null
                        ? Icon(item.icon, size: 20)
                        : null,
                    text: item.title,
                  ),
                )
                .toList(),
          ),
        ),
        
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabItems
                .map(
                  (item) => item.content ?? _buildDefaultContent(item.title),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // Default content when no custom content is provided
  Widget _buildDefaultContent(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 60,
            color: AppPalette.greyColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '$title Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppPalette.blackColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is the content for $title tab',
            style: TextStyle(
              fontSize: 14,
              color: AppPalette.greyColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Model class for tab items
class TabItem {
  final String title;
  final IconData? icon;
  final Widget? content;

  TabItem({
    required this.title,
    this.icon,
    this.content,
  });

  // Factory constructor for creating from API response
  factory TabItem.fromJson(Map<String, dynamic> json) {
    return TabItem(
      title: json['title'] ?? '',
      icon: json['icon'] != null ? _iconFromString(json['icon']) : null,
    );
  }

  // Helper method to convert string to IconData
  static IconData? _iconFromString(String iconName) {
    // You can expand this mapping based on your needs
    final iconMap = {
      'home': Icons.home,
      'settings': Icons.settings,
      'profile': Icons.person,
      'cart': Icons.shopping_cart,
      'favorite': Icons.favorite,
      'search': Icons.search,
    };
    return iconMap[iconName.toLowerCase()];
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon?.codePoint,
    };
  }
}

