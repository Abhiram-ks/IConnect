import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/widgets/shopify_product_grid_section.dart';

/// Tabbed Products Section with horizontal scrolling and pagination
class TabbedProductsSection extends StatefulWidget {
  const TabbedProductsSection({super.key});

  @override
  State<TabbedProductsSection> createState() => _TabbedProductsSectionState();
}

class _TabbedProductsSectionState extends State<TabbedProductsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<int, ScrollController> _scrollControllers = {};
  final Map<int, List<ProductEntity>> _tabProducts = {};
  final Map<int, bool> _isLoadingMore = {};
  final Map<int, String?> _endCursors = {};
  final Map<int, bool> _hasNextPage = {};

  // Define tabs with specific search queries for latest models only
  // Customize these queries based on your actual product titles in Shopify
  final List<Map<String, String>> _tabs = [
    {
      'title': 'iPhone 17 Series',
      'query': 'tag:iphone-17 OR tag:iphone-17-pro OR tag:iphone-17-pro-max',
    },
    {
      'title': 'Samsung',
      'query':
          "tag:galaxy-s25 OR tag:galaxy-s24 OR tag:galaxy-z-fold6 OR tag:galaxy-z-fold7", 
    },
    {
      'title': 'Google',
      'query': 'tag:pixel-9 OR tag:pixel-8', 
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    
    for (int i = 0; i < _tabs.length; i++) {
      _scrollControllers[i] = ScrollController();
      _tabProducts[i] = [];
      _isLoadingMore[i] = false;
      _endCursors[i] = null;
      _hasNextPage[i] = false;

      // Add scroll listener for pagination
      _scrollControllers[i]!.addListener(() => _onScroll(i));
    }

    // Load initial products for first tab
    _loadProducts(0);

    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final currentTab = _tabController.index;
        if (_tabProducts[currentTab]!.isEmpty) {
          _loadProducts(currentTab);
        }
      }
    });
  }

  void _onScroll(int tabIndex) {
    final scrollController = _scrollControllers[tabIndex]!;
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore[tabIndex]! &&
        _hasNextPage[tabIndex]!) {
      _loadMoreProducts(tabIndex);
    }
  }

  void _loadProducts(int tabIndex) {
    final query = _tabs[tabIndex]['query']!;
    context.read<ProductBloc>().add(
      LoadProductsRequested(first: 20, query: query, loadMore: false),
    );
  }

  void _loadMoreProducts(int tabIndex) {
    if (_isLoadingMore[tabIndex]! || !_hasNextPage[tabIndex]!) return;

    setState(() {
      _isLoadingMore[tabIndex] = true;
    });

    final query = _tabs[tabIndex]['query']!;
    context.read<ProductBloc>().add(
      LoadProductsRequested(
        first: 20,
        query: query,
        after: _endCursors[tabIndex],
        loadMore: true,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Bar
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppPalette.blackColor,
          dividerColor: Colors.transparent,
          
          unselectedLabelColor: AppPalette.greyColor,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
          ),
          indicatorColor: AppPalette.blackColor,
          indicatorWeight: 1.5,
          
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: EdgeInsets.symmetric(horizontal: 20.w),
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((tab) => Tab(text: tab['title'])).toList(),
        ),

        SizedBox(height: 16.h),

        // Tab Content with horizontal scroll
        SizedBox(
          height: 280.h,
          child: TabBarView(
            controller: _tabController,
            children: List.generate(
              _tabs.length,
              (index) => _buildTabContent(index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(int tabIndex) {
    return BlocConsumer<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state.products.status == Status.completed) {
          setState(() {
            if (_isLoadingMore[tabIndex]!) {
              // Append products for pagination
              _tabProducts[tabIndex]!.addAll(state.products.data ?? []);
              _isLoadingMore[tabIndex] = false;
            } else {
              // Replace products for initial load
              _tabProducts[tabIndex] = List.from(state.products.data ?? []);
            }
            _endCursors[tabIndex] = state.endCursor;
            _hasNextPage[tabIndex] = state.hasNextPage;
          });
        } else if (state.products.status == Status.error) {
          setState(() {
            _isLoadingMore[tabIndex] = false;
          });
        }
      },
      builder: (context, state) {
        final products = _tabProducts[tabIndex] ?? [];

        // Show loading for initial load
        if (products.isEmpty && state.products.status == Status.loading) {
          return Center(
            child: CircularProgressIndicator(color: AppPalette.blueColor),
          );
        }

        // Show error
        if (products.isEmpty && state.products.status == Status.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                SizedBox(height: 8.h),
                Text(
                  state.products.message ?? 'Failed to load products',
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              ],
            ),
          );
        }

        // Show empty state
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 48.sp, color: Colors.grey),
                SizedBox(height: 8.h),
                Text(
                  'No products found',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Show products with horizontal scroll
        return ListView.builder(
          controller: _scrollControllers[tabIndex],
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: products.length + (_hasNextPage[tabIndex]! ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == products.length) {
              // Loading indicator for pagination
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: CircularProgressIndicator(color: AppPalette.blueColor),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: SizedBox(
                width: 160.w,
                child: ShopifyGridProductCard(product: products[index]),
              ),
            );
          },
        );
      },
    );
  }
}
