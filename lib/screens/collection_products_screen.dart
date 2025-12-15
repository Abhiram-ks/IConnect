import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/data/datasources/product_remote_datasource.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart'
    as products;
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/models/collection_filter.dart';
import 'package:iconnect/screens/nav_screen.dart';
import 'package:iconnect/services/collection_filter_service.dart';
import 'package:iconnect/widgets/active_filter_chips.dart';
import 'package:iconnect/widgets/collection_filter_drawer.dart';
import 'package:iconnect/widgets/sort_dropdown.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';

import '../widgets/shopify_product_grid_section.dart';

class CollectionProductsScreen extends StatefulWidget {
  final String collectionHandle;
  final String collectionTitle;

  const CollectionProductsScreen({
    super.key,
    required this.collectionHandle,
    required this.collectionTitle,
  });

  @override
  State<CollectionProductsScreen> createState() =>
      _CollectionProductsScreenState();
}

class _CollectionProductsScreenState extends State<CollectionProductsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isInitialLoad = true;
  bool _isSorting = false;
  ProductSortFilter _currentSortFilter = ProductSortFilter.featured;
  List<dynamic> _cachedProducts = [];

  // Filter States
  List<CollectionFilter> _availableFilters = [];
  List<ActiveFilter> _activeFilters = [];

  @override
  void initState() {
    super.initState();

    final initialSortParams = getSortParamsForFilter(_currentSortFilter);
    context.read<products.ProductBloc>().add(
      LoadCollectionByHandleRequested(
        handle: widget.collectionHandle,
        first: 20,
        sortKey: initialSortParams['sortKey'],
        reverse: initialSortParams['reverse'],
      ),
    );
    _scrollController.addListener(_onScroll);
    _loadFilters();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Load available filters from API
  Future<void> _loadFilters() async {
    try {
      // Get the remote data source from service locator
      final remoteDataSource = sl<ProductRemoteDataSource>();
      final filterService = CollectionFilterService(remoteDataSource);

      final filters = await filterService.getCollectionFilters(
        handle: widget.collectionHandle,
      );

      if (mounted) {
        setState(() {
          _availableFilters = filters;
        });
      }
    } catch (e) {
      print('Error loading filters: $e');
      // If error, filters will remain empty
    }
  }

  void _onScroll() {
    if (_isLoadingMore || _isSorting) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = 200.0; // Trigger when 200px from bottom

    if (currentScroll >= (maxScroll - delta)) {
      final state = context.read<products.ProductBloc>().state;
      if (state.collectionProductsHasNextPage &&
          state.collectionWithProducts.status == Status.completed) {
        setState(() {
          _isLoadingMore = true;
        });

        final sortParams = getSortParamsForFilter(_currentSortFilter);
        context.read<products.ProductBloc>().add(
          LoadCollectionByHandleRequested(
            handle: widget.collectionHandle,
            first: 20,
            after: state.collectionProductsEndCursor,
            sortKey: sortParams['sortKey'],
            reverse: sortParams['reverse'],
            loadMore: true,
          ),
        );
      }
    }
  }

  void _onFiltersApplied(List<ActiveFilter> filters) {
    setState(() {
      _activeFilters = filters;
    });

    // Apply filters to products
    _applyFilters();
  }

  void _onRemoveFilter(ActiveFilter filter) {
    setState(() {
      _activeFilters.remove(filter);
    });

    _applyFilters();
  }

  void _onClearAllFilters() {
    setState(() {
      _activeFilters.clear();
    });

    _applyFilters();
  }

  void _applyFilters() {
    // Convert active filters to Shopify filter format
    final shopifyFilters = _convertToShopifyFilters(_activeFilters);

    // Reload products with filters
    final sortParams = getSortParamsForFilter(_currentSortFilter);
    context.read<products.ProductBloc>().add(
      LoadCollectionByHandleRequested(
        handle: widget.collectionHandle,
        first: 20,
        sortKey: sortParams['sortKey'],
        reverse: sortParams['reverse'],
        filters: shopifyFilters,
      ),
    );
  }

  /// Convert ActiveFilter list to Shopify GraphQL filter format
  List<Map<String, dynamic>> _convertToShopifyFilters(
    List<ActiveFilter> activeFilters,
  ) {
    final shopifyFilters = <Map<String, dynamic>>[];

    for (final filter in activeFilters) {
      try {
        // Parse the input JSON string to get the filter value
        final input = filter.input;

        // The input from Shopify API is already in JSON format
        // We need to parse it and use it directly as the filter object
        if (input.isNotEmpty) {
          try {
            // Remove any escaped backslashes and parse the JSON
            final cleanInput = input.replaceAll(r'\', '');
            final parsedInput = jsonDecode(cleanInput) as Map<String, dynamic>;

            // Add the parsed input directly to the filters array
            // Shopify expects each filter to be an object with specific fields like:
            // {available: true}, {price: {min: 100, max: 500}}, {productVendor: "Brand"}, etc.
            shopifyFilters.add(parsedInput);

            print('Parsed filter: $parsedInput');
          } catch (e) {
            print('Error parsing filter input JSON: $e');
            // If parsing fails, skip this filter
          }
        }
      } catch (e) {
        print('Error converting filter ${filter.filterId}: $e');
      }
    }

    return shopifyFilters;
  }

  /// Extract filters from API response
  void _extractFiltersFromResponse(products.ProductState state) {
    // Reload filters whenever products are loaded
    // This ensures filters are always up to date
    if (_availableFilters.isEmpty) {
      _loadFilters();
    }
  }

  List<dynamic> _getFilteredProducts(List<dynamic> products) {
    // Filters are now applied server-side via the GraphQL API
    // No need for client-side filtering
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: CollectionFilterDrawer(
        availableFilters: _availableFilters,
        activeFilters: _activeFilters,
        onFiltersApplied: _onFiltersApplied,
        onClearAll: _onClearAllFilters,
      ),
      appBar: CustomAppBarDashbord(onBack: () => Navigator.pop(context)),
      body: Stack(
        children: [
          BlocBuilder<products.ProductBloc, products.ProductState>(
            builder: (context, state) {
              // Show full page loading only on initial load
              if (state.collectionWithProducts.status == Status.loading &&
                  _isInitialLoad) {
                return Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppPalette.blueColor,
                      backgroundColor: AppPalette.hintColor,
                      strokeWidth: 1.3,
                    ),
                  ),
                );
              }

              if (state.collectionWithProducts.status == Status.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppPalette.redColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error loading products',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        state.collectionWithProducts.message ?? 'Unknown error',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<products.ProductBloc>().add(
                            LoadCollectionByHandleRequested(
                              handle: widget.collectionHandle,
                              first: 20,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.blueColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Success state or loading during sort/filter
              if (state.collectionWithProducts.status == Status.completed ||
                  (state.collectionWithProducts.status == Status.loading &&
                      !_isInitialLoad)) {
                final collectionData = state.collectionWithProducts.data;
                final collection = collectionData?.collection;
                final productsList = collectionData?.products.products ?? [];

                // Update cached products when new data arrives
                if (state.collectionWithProducts.status == Status.completed) {
                  _cachedProducts = productsList;

                  // Extract filters from API response
                  _extractFiltersFromResponse(state);

                  // Mark initial load as complete
                  if (_isInitialLoad) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _isInitialLoad = false;
                        });
                      }
                    });
                  }

                  // Reset sorting flag
                  if (_isSorting) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _isSorting = false;
                        });
                      }
                    });
                  }
                }

                // Reset loading more flag when new data arrives
                if (_isLoadingMore) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isLoadingMore = false;
                      });
                    }
                  });
                }

                // Use cached products while sorting to maintain UI
                final displayProducts =
                    _isSorting ? _cachedProducts : productsList;

                // Apply filters to displayed products
                final filteredProducts = _getFilteredProducts(displayProducts);

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildCollectionHero(
                        collection?.title ?? '',
                        collection?.description ?? '',
                        collection?.imageUrl ?? '',
                        filteredProducts.length,
                      ),

                      // Active Filter Chips
                      ActiveFilterChips(
                        activeFilters: _activeFilters,
                        onRemoveFilter: _onRemoveFilter,
                        onClearAll: _onClearAllFilters,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: InkWell(
                                onTap: () {
                                  _scaffoldKey.currentState?.openEndDrawer();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Filter',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    if (_activeFilters.isNotEmpty)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                        child: Text(
                                          '${_activeFilters.length}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.keyboard_arrow_down_sharp,
                                      size: 24.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(width: 16.w),

                            Flexible(
                              flex: 2,
                              child: SortDropdown(
                                initialFilter: _currentSortFilter,
                                onFilterChanged: (filter, sortParams) {
                                  setState(() {
                                    _currentSortFilter = filter;
                                    _isSorting = true;
                                  });
                                  // Trigger BLoC event to sort products
                                  context.read<products.ProductBloc>().add(
                                    LoadCollectionByHandleRequested(
                                      handle: widget.collectionHandle,
                                      first: 20,
                                      sortKey: sortParams['sortKey'],
                                      reverse: sortParams['reverse'],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Products Grid Section
                      _buildProductsSection(
                        filteredProducts,
                        state.collectionProductsHasNextPage,
                        _isSorting,
                        state.collectionWithProducts.status,
                      ),
                    ],
                  ),
                );
              }

              // Initial state
              return const SizedBox.shrink();
            },
          ),
          const WhatsAppFloatingButton(),
        ],
      ),
    );
  }

  Widget buildCollectionHero(
    String title,
    String description,
    String? imageUrl,
    int productCount,
  ) {
    return Container(
      width: double.infinity,
      height: 150.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPalette.blueColor,
            AppPalette.blueColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background image if available
          if (imageUrl != null && imageUrl.isNotEmpty)
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            ),

          // Background pattern
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(
    List<dynamic> products,
    bool hasNextPage,
    bool isLoading,
    Status status,
  ) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Products',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Show loading indicator when sorting/filtering (but not during pagination)
          if (isLoading || status == Status.loading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: CircularProgressIndicator(
                  color: AppPalette.blueColor,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (products.isEmpty && !isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No products available',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Check back later for new products',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ShopifyGridProductCard(product: product);
              },
            ),

          // Loading indicator at bottom when loading more
          if (_isLoadingMore && hasNextPage)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: CircularProgressIndicator(color: AppPalette.blueColor),
              ),
            ),
        ],
      ),
    );
  }
}
