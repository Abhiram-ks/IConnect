import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconnect/app_drawer.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/cubit/nav_cubit/navigation_cubit.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/screens/nav_screen.dart';
import 'package:iconnect/screens/search_screen.dart';
import 'package:iconnect/widgets/cart_drawer.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';

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
  @override
  void initState() {
    super.initState();
    // Debug: Print the collection handle being used
    print(
      '🔍 DEBUG: Loading collection with handle: "${widget.collectionHandle}"',
    );
    print('🔍 DEBUG: Collection title: "${widget.collectionTitle}"');

    // Load collection with products
    context.read<ProductBloc>().add(
      LoadCollectionByHandleRequested(
        handle: widget.collectionHandle,
        first: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      endDrawer: const CartDrawerWidget(),
      appBar: CustomAppBarDashbord(),
      body: Stack(
        children: [
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              // Loading state
              if (state.collectionWithProducts.status == Status.loading) {
                return Center(
                  child: CircularProgressIndicator(color: AppPalette.blueColor),
                );
              }

              // Error state
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
                          context.read<ProductBloc>().add(
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

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Collection Hero Section
                      _buildCollectionHero(
                        collection.title,
                        collection.description,
                        collection.imageUrl,
                        products.length,
                      ),

                      // Products Grid Section
                      _buildProductsSection(products),

                      // Bottom padding for floating button
                      SizedBox(height: 100.h),
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
                          builder: (context, state) {
                            return Stack(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 16,
                                ),
                                if (state.itemCount > 0)
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
                                        '${state.itemCount}',
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
                          builder: (context, state) {
                            return Stack(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_rounded,
                                  color: AppPalette.blueColor,
                                ),
                                if (state.itemCount > 0)
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
                                        '${state.itemCount}',
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

  Widget _buildCollectionHero(
    String title,
    String description,
    String? imageUrl,
    int productCount,
  ) {
    return Container(
      width: double.infinity,
      height: 250.h,
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
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
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
                SizedBox(height: 8.h),
                Text(
                  '$productCount products available',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Shop Now',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(List<dynamic> products) {
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
