import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/models/series_model.dart';
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

  // Define tabs with ModelName for collection handles
  final List<Map<String, dynamic>> _tabs = [
    {'title': 'iPhone 17 Series', 'model': ModelName.iPhone17},
    {'title': 'Samsung', 'model': ModelName.samsung},
    {'title': 'Google', 'model': ModelName.google},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    for (int i = 0; i < _tabs.length; i++) {
      _scrollControllers[i] = ScrollController();
      _tabProducts[i] = [];
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

  void _loadProducts(int tabIndex) {
    final model = _tabs[tabIndex]['model'] as ModelName;
    context.read<ProductBloc>().add(
      LoadSeriesProduct(model: model, first: 100),
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
              (index) => KeepAliveWrapper(child: _buildTabContent(index)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(int tabIndex) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final model = _tabs[tabIndex]['model'] as ModelName;
        final seriesData = state.seriesProducts?[model];

        // Get products from series data or use cached products
        final products = seriesData?.products ?? _tabProducts[tabIndex] ?? [];

        // Update cached products when series data is available
        if (seriesData != null && seriesData.products.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _tabProducts[tabIndex] = List.from(seriesData.products);
              });
            }
          });
        }

        // Show loading for initial load
        if (products.isEmpty && (seriesData?.loading ?? false)) {
          return Center(
            child: CircularProgressIndicator(color: AppPalette.blueColor),
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
          itemCount: products.length,
          itemBuilder: (context, index) {
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

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
