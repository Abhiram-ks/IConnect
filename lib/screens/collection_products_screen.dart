import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';

import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart'
    as products;
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/screens/nav_screen.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';
import 'package:iconnect/widgets/sort_dropdown.dart';

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
  bool _filterInStock = false;
  bool _filterOutOfStock = false;
  RangeValues _currentPriceRange = const RangeValues(0, 14999);
  final double _minPrice = 0;
  final double _maxPrice = 14999;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: _minPrice.toStringAsFixed(0),
    );
    _maxPriceController = TextEditingController(
      text: _maxPrice.toStringAsFixed(0),
    );

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
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildFilterDrawer(),
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

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildCollectionHero(
                        collection?.title ?? '',
                        collection?.description ?? '',
                        collection?.imageUrl ?? '',
                        displayProducts.length,
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
                        displayProducts,
                        state.collectionProductsHasNextPage,
                        _isSorting,
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
          if (isLoading && !_isLoadingMore)
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

  Widget _buildFilterDrawer() {
    return Drawer(
      elevation: 0,

      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setDrawerState) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, size: 24.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ExpansionTile(
                            title: Text(
                              'Availability',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                            tilePadding: EdgeInsets.zero,
                            initiallyExpanded: true,
                            shape: Border.all(color: Colors.transparent),
                            children: [
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'In stock',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                value: _filterInStock,
                                activeColor: Colors.black,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (bool? value) {
                                  setDrawerState(() {
                                    _filterInStock = value ?? false;
                                  });
                                  setState(() {});
                                },
                              ),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'Out of stock',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                value: _filterOutOfStock,
                                activeColor: Colors.black,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (bool? value) {
                                  setDrawerState(() {
                                    _filterOutOfStock = value ?? false;
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 10.h),
                          ExpansionTile(
                            title: Text(
                              'Price',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                            tilePadding: EdgeInsets.zero,
                            initiallyExpanded: true,
                            shape: Border.all(color: Colors.transparent),
                            children: [
                              RangeSlider(
                                values: _currentPriceRange,
                                min: _minPrice,
                                max: _maxPrice,
                                activeColor: Colors.black,
                                inactiveColor: Colors.grey.shade300,
                                onChanged: (RangeValues values) {
                                  setDrawerState(() {
                                    _currentPriceRange = values;
                                    _minPriceController.text = values.start
                                        .toStringAsFixed(0);
                                    _maxPriceController.text = values.end
                                        .toStringAsFixed(0);
                                  });
                                  setState(() {});
                                },
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(
                                          30.r,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'QAR ',
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: _minPriceController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              textAlign: TextAlign.right,
                                              onChanged: (value) {
                                                if (value.isNotEmpty) {
                                                  double val =
                                                      double.tryParse(value) ??
                                                      _minPrice;
                                                  setDrawerState(() {
                                                    _currentPriceRange =
                                                        RangeValues(
                                                          val,
                                                          _currentPriceRange
                                                              .end,
                                                        );
                                                  });
                                                  setState(() {});
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                    ),
                                    child: Text(
                                      'To',
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(
                                          30.r,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'QAR ',
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: _maxPriceController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              textAlign: TextAlign.right,
                                              onChanged: (value) {
                                                if (value.isNotEmpty) {
                                                  double val =
                                                      double.tryParse(value) ??
                                                      _maxPrice;
                                                  setDrawerState(() {
                                                    _currentPriceRange =
                                                        RangeValues(
                                                          _currentPriceRange
                                                              .start,
                                                          val,
                                                        );
                                                  });
                                                  setState(() {});
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
