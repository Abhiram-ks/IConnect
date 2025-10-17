import 'package:flutter/material.dart';
import 'package:iconnect/app_palette.dart';

/// A simpler version of DynamicTabBar that can be embedded in any screen.
/// 
/// Example usage:
/// ```dart
/// SimpleDynamicTabBar(
///   tabs: ['Tab 1', 'Tab 2', 'Tab 3'],
///   tabViews: [
///     Center(child: Text('Content 1')),
///     Center(child: Text('Content 2')),
///     Center(child: Text('Content 3')),
///   ],
/// )
/// ```
class SimpleDynamicTabBar extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> tabViews;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final double indicatorWeight;
  final double height;

  const SimpleDynamicTabBar({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.isScrollable = true,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorWeight = 3.0,
    this.height = 400,
  }) : assert(tabs.length == tabViews.length, 'Tabs and TabViews must have the same length');

  @override
  State<SimpleDynamicTabBar> createState() => _SimpleDynamicTabBarState();
}

class _SimpleDynamicTabBarState extends State<SimpleDynamicTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
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
    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          // TabBar
          Container(
            decoration: BoxDecoration(
              color: AppPalette.whiteColor,
              border: Border(
                bottom: BorderSide(
                  color: AppPalette.greyColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: widget.isScrollable,
              indicatorColor: widget.indicatorColor ?? AppPalette.blueColor,
              indicatorWeight: widget.indicatorWeight,
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
              tabs: widget.tabs
                  .map(
                    (tab) => Tab(text: tab),
                  )
                  .toList(),
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.tabViews,
            ),
          ),
        ],
      ),
    );
  }
}

/// An even simpler TabBar that only shows text tabs with default content.
/// Useful for quick prototyping.
class QuickTabBar extends StatelessWidget {
  final List<String> tabs;
  final Color? indicatorColor;

  const QuickTabBar({
    super.key,
    required this.tabs,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDynamicTabBar(
      tabs: tabs,
      tabViews: tabs
          .map(
            (tab) => Center(
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
                    tab,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.blackColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Content for $tab',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppPalette.greyColor,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      indicatorColor: indicatorColor,
    );
  }
}

