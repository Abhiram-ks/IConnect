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
  String _selectedSortOption = 'Alphabetically, A-Z';

  // Filter States
  bool _filterInStock = false;
  bool _filterOutOfStock = false;
  RangeValues _currentPriceRange = const RangeValues(0, 14999);
  final double _minPrice = 0;
  final double _maxPrice = 14999;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  final List<String> _sortOptions = [
    'Featured',
    'Best selling',
    'Alphabetically, A-Z',
    'Alphabetically, Z-A',
    'Price, low to high',
    'Price, high to low',
    'Date, old to new',
    'Date, new to old',
  ];

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: _minPrice.toStringAsFixed(0),
    );
    _maxPriceController = TextEditingController(
      text: _maxPrice.toStringAsFixed(0),
    );

    context.read<products.ProductBloc>().add(
      LoadCollectionByHandleRequested(
        handle: widget.collectionHandle,
        first: 20,
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
    if (_isLoadingMore) return;

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

        context.read<products.ProductBloc>().add(
          LoadCollectionByHandleRequested(
            handle: widget.collectionHandle,
            first: 20,
            after: state.collectionProductsEndCursor,
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
              if (state.collectionWithProducts.status == Status.loading) {
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

              // Success state
              if (state.collectionWithProducts.status == Status.completed) {
                final collectionData = state.collectionWithProducts.data!;
                final collection = collectionData.collection;
                final products = collectionData.products.products;

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

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildCollectionHero(
                        collection.title,
                        collection.description,
                        collection.imageUrl,
                        products.length,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    'Filtered',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _scaffoldKey.currentState
                                          ?.openEndDrawer();
                                    },
                                    icon: Icon(Icons.keyboard_arrow_down_sharp),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _selectedSortOption,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _showSortBottomSheet(context);
                                    },
                                    icon: Icon(Icons.keyboard_arrow_down_sharp),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Products Grid Section
                      _buildProductsSection(
                        products,
                        state.collectionProductsHasNextPage,
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
                Text(
                  '$productCount products available',
                  style: TextStyle(
                    fontSize: 14.sp,

                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(List<dynamic> products, bool hasNextPage) {
    if (products.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(24.w),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 64.sp, color: Colors.grey),
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
      );
    }

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

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 24.sp),
                  ),
                ],
              ),
              ..._sortOptions.map((option) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSortOption = option;
                    });
                    // FUTURE: Trigger BLoC event to sort products here
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
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
