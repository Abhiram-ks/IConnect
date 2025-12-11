import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/domain/entities/offer_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart'
    as products;
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/routes.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';
import 'package:iconnect/widgets/shopify_product_grid_section.dart';
import 'package:url_launcher/url_launcher.dart';

class OfferViewScreen extends StatefulWidget {
  const OfferViewScreen({super.key});

  @override
  State<OfferViewScreen> createState() => _OfferViewScreenState();
}

class _OfferViewScreenState extends State<OfferViewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<products.ProductBloc>().add(LoadOfferBlocksRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<products.ProductBloc, products.ProductState>(
            builder: (context, state) {
              // Loading state
              if (state.offerBlocks.status == Status.loading) {
                return Center(
                  child: CircularProgressIndicator(color: AppPalette.blueColor),
                );
              }

              // Error state
              if (state.offerBlocks.status == Status.error) {
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
                        'Error loading offers',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        state.offerBlocks.message ?? 'Unknown error',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<products.ProductBloc>().add(
                            LoadOfferBlocksRequested(),
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
              if (state.offerBlocks.status == Status.completed) {
                final offerBlocks = state.offerBlocks.data ?? [];

                if (offerBlocks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No offers available',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Check back later for new offers',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: offerBlocks.length,
                  itemBuilder: (context, index) {
                    final offerBlock = offerBlocks[index];
                    return _buildOfferBlock(offerBlock);
                  },
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

  Widget _buildOfferBlock(OfferBlockEntity offerBlock) {
    // Load featured collection products if available
    if (offerBlock.featuredCollectionHandle != null &&
        offerBlock.featuredCollectionHandle!.isNotEmpty) {
      final categoryKey = 'offer_featured_${offerBlock.id}';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final state = context.read<products.ProductBloc>().state;
        final categoryData = state.categoryProducts[categoryKey];
        // Only load if not already loaded or loading
        if (categoryData == null ||
            categoryData.products.status == Status.initial) {
          context.read<products.ProductBloc>().add(
            LoadCategoryProductsRequested(
              categoryName: categoryKey,
              collectionHandle: offerBlock.featuredCollectionHandle!,
              first: 10,
            ),
          );
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Image
        if (offerBlock.heroImageUrl != null &&
            offerBlock.heroImageUrl!.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16.h),
            child: CachedNetworkImage(
              imageUrl: offerBlock.heroImageUrl!,
              fit: BoxFit.fitWidth,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppPalette.blueColor,
                      ),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48.sp,
                      color: Colors.grey[400],
                    ),
                  ),
            ),
          ),

        // Items Horizontal Scroll
        if (offerBlock.items.isNotEmpty)
          SizedBox(
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: offerBlock.items.length,
              itemBuilder: (context, index) {
                final item = offerBlock.items[index];
                return _buildOfferItem(item);
              },
            ),
          ),

        // Title
        if (offerBlock.title != null && offerBlock.title!.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Center(
              child: Text(
                offerBlock.title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

        // Button (from button_link field) - shown above featured collection
        if (offerBlock.buttonText != null &&
            offerBlock.buttonText!.isNotEmpty &&
            offerBlock.buttonUrl != null &&
            offerBlock.buttonUrl!.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse(offerBlock.buttonUrl!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.blueColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 14.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  offerBlock.buttonText!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

        // Featured Collection Products Section
        if (offerBlock.featuredCollectionHandle != null &&
            offerBlock.featuredCollectionHandle!.isNotEmpty)
          _buildFeaturedCollectionSection(offerBlock),

        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildFeaturedCollectionSection(OfferBlockEntity offerBlock) {
    final categoryKey = 'offer_featured_${offerBlock.id}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Collection Title
        if (offerBlock.featuredCollectionTitle != null &&
            offerBlock.featuredCollectionTitle!.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              offerBlock.featuredCollectionTitle!,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // Featured Collection Products Horizontal Scroll
        SizedBox(
          height: 250.h,
          child: BlocBuilder<products.ProductBloc, products.ProductState>(
            builder: (context, state) {
              final categoryData = state.categoryProducts[categoryKey];

              if (categoryData == null ||
                  categoryData.products.status == Status.initial) {
                return Center(
                  child: CircularProgressIndicator(color: AppPalette.blueColor),
                );
              }

              if (categoryData.products.status == Status.loading) {
                return Center(
                  child: CircularProgressIndicator(color: AppPalette.blueColor),
                );
              }

              if (categoryData.products.status == Status.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
                      SizedBox(height: 8.h),
                      Text(
                        'Failed to load products',
                        style: TextStyle(fontSize: 14.sp, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }

              if (categoryData.products.status == Status.completed) {
                final products = categoryData.products.data ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No products available',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: SizedBox(
                        width: 160.w,
                        child: ShopifyGridProductCard(product: product),
                      ),
                    );
                  },
                );
              }

              return SizedBox.shrink();
            },
          ),
        ),

        // Shop More Button
        if (offerBlock.featuredCollectionHandle != null &&
            offerBlock.featuredCollectionHandle!.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.collectionProducts,
                    arguments: {
                      'collectionHandle': offerBlock.featuredCollectionHandle!,
                      'collectionTitle':
                          offerBlock.featuredCollectionTitle ?? 'Shop More',
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.blueColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 14.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Shop More',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOfferItem(OfferItemEntity item) {
    return GestureDetector(
      onTap: () {
        if (item.collectionHandle != null &&
            item.collectionHandle!.isNotEmpty) {
          Navigator.pushNamed(
            context,
            AppRoutes.collectionProducts,
            arguments: {
              'collectionHandle': item.collectionHandle!,
              'collectionTitle': item.collectionTitle ?? 'Collection',
            },
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        constraints: BoxConstraints(minWidth: 150.w, maxWidth: 200.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child:
              item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    fit: BoxFit.contain,
                    width: 150.w,
                    height: 180.h,
                    placeholder:
                        (context, url) => Container(
                          width: 150.w,
                          height: 180.h,
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
                          width: 150.w,
                          height: 180.h,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 32.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                  )
                  : Container(
                    width: 150.w,
                    height: 180.h,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 32.sp,
                      color: Colors.grey[400],
                    ),
                  ),
        ),
      ),
    );
  }
}
