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

        // View More Button
        if (offerBlock.viewMoreCollectionHandle != null &&
            offerBlock.viewMoreCollectionHandle!.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.collectionProducts,
                    arguments: {
                      'collectionHandle': offerBlock.viewMoreCollectionHandle!,
                      'collectionTitle':
                          offerBlock.viewMoreCollectionTitle ?? 'View More',
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
                  'View More Offers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Center(
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 14.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'View More Offers',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

        SizedBox(height: 16.h),
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
