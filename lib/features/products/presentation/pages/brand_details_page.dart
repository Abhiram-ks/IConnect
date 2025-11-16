import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconnect/app_drawer.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:iconnect/features/cart/presentation/widgets/cart_drawer_widget.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/screens/nav_screen.dart';
import 'package:iconnect/screens/search_screen.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';

/// Brand Details Page - Shows brand categories and products
class BrandDetailsPage extends StatefulWidget {
  final int brandId;
  final String brandName;
  final String brandVendor;
  final String brandImageUrl;

  const BrandDetailsPage({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.brandVendor,
    required this.brandImageUrl,
  });

  @override
  State<BrandDetailsPage> createState() => _BrandDetailsPageState();
}

class _BrandDetailsPageState extends State<BrandDetailsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load products filtered by vendor (brand) using separate state
    context.read<ProductBloc>().add(
      LoadBrandProductsRequested(vendor: widget.brandVendor, first: 20),
    );
    // Load collections (categories)
    context.read<ProductBloc>().add(
      LoadCollectionsRequested(first: 20, forBanners: false),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<ProductBloc>().state;
      if (state.brandProducts.status == Status.completed &&
          state.brandProductsHasNextPage) {
        context.read<ProductBloc>().add(
          LoadBrandProductsRequested(
            vendor: widget.brandVendor,
            after: state.brandProductsEndCursor,
            loadMore: true,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      endDrawer: const CartDrawerWidget(),
      appBar: CustomAppBarDashbord(),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Hero Section
                _buildBrandHero(),

                // Brand Categories Section (if available)
                _buildBrandCategoriesSection(),

                // Brand Products Section
                _buildBrandProductsSection(),

                // Bottom padding for floating button
                SizedBox(height: 100.h),
              ],
            ),
          ),
          const WhatsAppFloatingButton(),
        ],
      ),
      bottomNavigationBar: BlocBuilder<ButtomNavCubit, NavItem>(
        builder: (context, state) {
          return Builder(
            builder: (BuildContext scaffoldContext) {
              return SizedBox(
                height: 70.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppPalette.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.blackColor.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    enableFeedback: true,
                    useLegacyColorScheme: true,
                    elevation: 0,
                    iconSize: 26,
                    selectedItemColor: AppPalette.blueColor,
                    backgroundColor: Colors.transparent,
                    landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
                    unselectedLabelStyle: TextStyle(
                      color: AppPalette.hintColor,
                    ),
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: NavItem.values.indexOf(NavItem.home),
                    onTap: (index) {
                      if (NavItem.values[index] == NavItem.cart) {
                        Scaffold.of(scaffoldContext).openEndDrawer();
                      } else if (NavItem.values[index] == NavItem.search) {
                        Navigator.pushReplacementNamed(context, '/');
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            );
                          }
                        });
                      } else {
                        Navigator.pushReplacementNamed(context, '/');
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            context.read<ButtomNavCubit>().selectItem(
                              NavItem.values[index],
                            );
                          }
                        });
                      }
                    },
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined, size: 16),
                        label: 'Home',
                        activeIcon: Icon(
                          Icons.home,
                          color: AppPalette.blueColor,
                        ),
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.grid_view, size: 16),
                        label: 'Product',
                        activeIcon: Icon(
                          Icons.grid_view_sharp,
                          color: AppPalette.blueColor,
                        ),
                      ),
                      BottomNavigationBarItem(
                        icon: BlocBuilder<CartCubit, CartState>(
                          bloc: sl<CartCubit>(),
                          builder: (context, state) {
                            int itemCount = 0;
                            if (state is CartLoaded) {
                              itemCount = state.cart.itemCount;
                            } else if (state is CartOperationInProgress) {
                              itemCount = state.currentCart.itemCount;
                            }

                            return Stack(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 16,
                                ),
                                if (itemCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppPalette.redColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$itemCount',
                                        style: const TextStyle(
                                          color: AppPalette.whiteColor,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        label: 'Cart',
                        activeIcon: BlocBuilder<CartCubit, CartState>(
                          bloc: sl<CartCubit>(),
                          builder: (context, state) {
                            int itemCount = 0;
                            if (state is CartLoaded) {
                              itemCount = state.cart.itemCount;
                            } else if (state is CartOperationInProgress) {
                              itemCount = state.currentCart.itemCount;
                            }

                            return Stack(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_rounded,
                                  color: AppPalette.blueColor,
                                ),
                                if (itemCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppPalette.redColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$itemCount',
                                        style: const TextStyle(
                                          color: AppPalette.whiteColor,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.search, size: 16),
                        label: 'Search',
                        activeIcon: Icon(
                          Icons.search,
                          color: AppPalette.blueColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBrandHero() {
    return Container(
      width: double.infinity,
      height: 200.h,
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
            child: Row(
              children: [
                // Brand Logo
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CachedNetworkImage(
                      imageUrl: widget.brandImageUrl,
                      fit: BoxFit.contain,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppPalette.blueColor,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.branding_watermark,
                              color: Colors.grey,
                              size: 40.sp,
                            ),
                          ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Brand Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.brandName,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Explore ${widget.brandName} products',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCategoriesSection() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.collections.status != Status.completed) {
          return const SizedBox.shrink();
        }

        final collections = state.collections.data ?? [];
        if (collections.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 120.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/collection_products',
                            arguments: {
                              'collectionHandle': collection.handle,
                              'collectionTitle': collection.title,
                            },
                          );
                        },
                        child: Container(
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Category Image
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12.r),
                                  ),
                                  child:
                                      collection.imageUrl != null &&
                                              collection.imageUrl!.isNotEmpty
                                          ? CachedNetworkImage(
                                            imageUrl: collection.imageUrl!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            placeholder:
                                                (context, url) => Container(
                                                  color: Colors.grey[200],
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color:
                                                              AppPalette
                                                                  .blueColor,
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      color: Colors.grey[200],
                                                      child: Icon(
                                                        Icons.category,
                                                        color: Colors.grey,
                                                        size: 30.sp,
                                                      ),
                                                    ),
                                          )
                                          : Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.category,
                                              color: Colors.grey,
                                              size: 30.sp,
                                            ),
                                          ),
                                ),
                              ),
                              // Category Title
                              Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Text(
                                  collection.title,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrandProductsSection() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Loading state
        if (state.brandProducts.status == Status.loading) {
          return Container(
            padding: EdgeInsets.all(24.w),
            child: Center(
              child: CircularProgressIndicator(color: AppPalette.blueColor),
            ),
          );
        }

        // Error state
        if (state.brandProducts.status == Status.error) {
          return Container(
            padding: EdgeInsets.all(24.w),
            child: Center(
              child: Column(
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
                    state.brandProducts.message ?? 'Unknown error',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(
                        LoadBrandProductsRequested(
                          vendor: widget.brandVendor,
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
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Success state
        if (state.brandProducts.status == Status.completed) {
          final products = state.brandProducts.data ?? [];

          if (products.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(
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
                      'Check back later for ${widget.brandName} products',
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
                      '${widget.brandName} Products',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.blueColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        '${products.length} items',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppPalette.blueColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Products Grid
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
                    return _buildProductCard(product);
                  },
                ),
              ],
            ),
          );
        }

        // Initial state
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    final imageUrl = product.featuredImage ?? '';
    final title = product.title ?? 'No title';
    final currencyCode = product.currencyCode ?? 'QAR';
    final handle = product.handle ?? '';

    return GestureDetector(
      onTap: () {
        if (handle.isNotEmpty) {
          Navigator.pushNamed(
            context,
            '/product_details',
            arguments: {'productHandle': handle},
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child:
                  imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 150.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              height: 150.h,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppPalette.blueColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              height: 150.h,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40.sp,
                              ),
                            ),
                      )
                      : Container(
                        height: 150.h,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40.sp,
                        ),
                      ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '$currencyCode ${product.minPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.blueColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
