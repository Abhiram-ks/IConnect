
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/widgets/shopify_product_grid_section.dart';

enum ProductSortFilter {
  featured,
  bestSelling,
  alphabeticallyAZ,
  alphabeticallyZA,
  priceLowToHigh,
  priceHighToLow,
  dateOldToNew,
  dateNewToOld,
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  ProductSortFilter _currentFilter = ProductSortFilter.alphabeticallyAZ;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // Load products with initial filter
    _loadProducts();

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  void _loadProducts() {
    final bloc = context.read<ProductBloc>();
    final sortParams = _getSortParamsForFilter();

    bloc.add(
      LoadAllProductsRequested(
        first: 50,
        sortKey: sortParams['sortKey'],
        reverse: sortParams['reverse'],
      ),
    );
  }

  void _loadMoreProducts() {
    if (_isLoadingMore) return;

    final bloc = context.read<ProductBloc>();
    final state = bloc.state;

    if (state.allProductsHasNextPage && state.allProductsEndCursor != null) {
      setState(() => _isLoadingMore = true);

      final sortParams = _getSortParamsForFilter();

      bloc.add(
        LoadAllProductsRequested(
          first: 50,
          after: state.allProductsEndCursor,
          sortKey: sortParams['sortKey'],
          reverse: sortParams['reverse'],
          loadMore: true,
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isLoadingMore = false);
        }
      });
    }
  }

  Map<String, dynamic> _getSortParamsForFilter() {
    switch (_currentFilter) {
      case ProductSortFilter.featured:
        return {'sortKey': 'RELEVANCE', 'reverse': false};
      case ProductSortFilter.bestSelling:
        return {'sortKey': 'BEST_SELLING', 'reverse': false};
      case ProductSortFilter.alphabeticallyAZ:
        return {'sortKey': 'TITLE', 'reverse': false};
      case ProductSortFilter.alphabeticallyZA:
        return {'sortKey': 'TITLE', 'reverse': true};
      case ProductSortFilter.priceLowToHigh:
        return {'sortKey': 'PRICE', 'reverse': false};
      case ProductSortFilter.priceHighToLow:
        return {'sortKey': 'PRICE', 'reverse': true};
      case ProductSortFilter.dateOldToNew:
        return {'sortKey': 'CREATED_AT', 'reverse': false};
      case ProductSortFilter.dateNewToOld:
        return {'sortKey': 'CREATED_AT', 'reverse': true};
    }
  }

  String _getFilterDisplayName(ProductSortFilter filter) {
    switch (filter) {
      case ProductSortFilter.featured:
        return 'Featured';
      case ProductSortFilter.bestSelling:
        return 'Best selling';
      case ProductSortFilter.alphabeticallyAZ:
        return 'Alphabetically, A-Z';
      case ProductSortFilter.alphabeticallyZA:
        return 'Alphabetically, Z-A';
      case ProductSortFilter.priceLowToHigh:
        return 'Price, low to high';
      case ProductSortFilter.priceHighToLow:
        return 'Price, high to low';
      case ProductSortFilter.dateOldToNew:
        return 'Date, old to new';
      case ProductSortFilter.dateNewToOld:
        return 'Date, new to old';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.whiteColor,
      body: Column(
        children: [
          // Filter Dropdown Header
          _buildFilterHeader(),

          // Products Grid
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                switch (state.allProducts.status) {
                  case Status.initial:
                    return const SizedBox.shrink();
                  case Status.loading:
                    return _buildLoadingState();
                  case Status.completed:
                    final products = state.allProducts.data ?? [];
                    if (products.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Products are already sorted by server
                    return _buildProductsGrid(
                      products,
                      state.allProductsHasNextPage,
                    );
                  case Status.error:
                    return _buildErrorState(
                      state.allProducts.message ?? 'Unknown error',
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.blackColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppPalette.greyColor.withValues(alpha: .3),
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ProductSortFilter>(
                  value: _currentFilter,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppPalette.blackColor,
                    size: 20.sp,
                  ),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppPalette.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                  items:
                      ProductSortFilter.values.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(_getFilterDisplayName(filter)),
                        );
                      }).toList(),
                  onChanged: (newFilter) {
                    if (newFilter != null && newFilter != _currentFilter) {
                      setState(() {
                        _currentFilter = newFilter;
                      });
                      _loadProducts();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(List<ProductEntity> products, bool hasNextPage) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 16.h,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return ShopifyGridProductCard(product: product);
            }, childCount: products.length),
          ),
        ),

        // Loading more indicator
        if (hasNextPage || _isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppPalette.blueColor,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),

        // Bottom spacing
        SliverToBoxAdapter(child: SizedBox(height: 80.h)),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppPalette.blueColor,
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading products...',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppPalette.greyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80.sp,
            color: AppPalette.greyColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppPalette.blackColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 14.sp, color: AppPalette.greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 80.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'Failed to Load Products',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppPalette.blackColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppPalette.greyColor),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: Icon(Icons.refresh, size: 20.sp),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.blueColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
