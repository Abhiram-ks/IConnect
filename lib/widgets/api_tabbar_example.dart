import 'package:flutter/material.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/widgets/dynamic_tabbar.dart';

/// Example showing how to use DynamicTabBar with API data
/// 
/// In your actual implementation, replace the mock API data with real API calls
class ApiTabBarExample extends StatefulWidget {
  const ApiTabBarExample({super.key});

  @override
  State<ApiTabBarExample> createState() => _ApiTabBarExampleState();
}

class _ApiTabBarExampleState extends State<ApiTabBarExample> {
  List<TabItem>? tabItems;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchTabData();
  }

  /// Simulates fetching tab data from an API
  /// Replace this with your actual API call
  Future<void> _fetchTabData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock API response
      final List<Map<String, dynamic>> apiResponse = [
        {'title': 'Electronics', 'icon': 'settings'},
        {'title': 'Fashion', 'icon': 'favorite'},
        {'title': 'Books', 'icon': 'search'},
        {'title': 'Sports', 'icon': 'home'},
        {'title': 'Home & Living', 'icon': 'profile'},
      ];

      // Convert API response to TabItem list
      final List<TabItem> fetchedTabs = apiResponse.map((json) {
        return TabItem(
          title: json['title'] as String,
          icon: _getIconFromString(json['icon'] as String),
          content: _buildCategoryContent(json['title'] as String),
        );
      }).toList();

      setState(() {
        tabItems = fetchedTabs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load tabs: $e';
        isLoading = false;
      });
    }
  }

  IconData? _getIconFromString(String iconName) {
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

  Widget _buildCategoryContent(String category) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppPalette.blackColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Showing items from $category category',
            style: TextStyle(
              fontSize: 14,
              color: AppPalette.greyColor,
            ),
          ),
          const SizedBox(height: 24),
          // Add your product list or content here
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppPalette.greyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: AppPalette.greyColor,
                    ),
                  ),
                  title: Text(
                    'Product ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '\$${(index + 1) * 10}.99',
                    style: TextStyle(
                      color: AppPalette.blueColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppPalette.greyColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.whiteColor,
      appBar: AppBar(
        backgroundColor: AppPalette.blueColor,
        title: const Text(
          'API TabBar Example',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTabData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppPalette.blueColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading tabs...',
              style: TextStyle(
                color: AppPalette.greyColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchTabData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.blueColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (tabItems == null || tabItems!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 60,
              color: AppPalette.greyColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No tabs available',
              style: TextStyle(
                fontSize: 16,
                color: AppPalette.greyColor,
              ),
            ),
          ],
        ),
      );
    }

    return DynamicTabBar(
      tabItems: tabItems!,
      isScrollable: true,
      indicatorColor: AppPalette.blueColor,
      labelColor: AppPalette.blueColor,
      unselectedLabelColor: AppPalette.greyColor,
    );
  }
}

