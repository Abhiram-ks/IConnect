import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/cubit/brand_scroll_cubit/brand_scroll_cubit.dart';
import 'package:iconnect/features/products/domain/entities/brand_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/widgets/brand_card.dart';

/// Brand Section Widget - Displays brands from Shopify API in a horizontal scrollable list
class BrandSection extends StatefulWidget {
  const BrandSection({super.key});

  @override
  State<BrandSection> createState() => _BrandSectionState();
}

class _BrandSectionState extends State<BrandSection> {
  @override
  void initState() {
    super.initState();
    // Load brands from Shopify API
    context.read<ProductBloc>().add(LoadBrandsRequested(first: 250));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Loading state
        if (state.brands.status == Status.loading) {
          return SizedBox(
            height: 28.h,
            child: Center(
              child: CircularProgressIndicator(
                color: AppPalette.blueColor,
                strokeWidth: 2,
              ),
            ),
          );
        }

        // Error state
        if (state.brands.status == Status.error) {
          return SizedBox(
            height: 28.h,
            child: Center(
              child: Text(
                'Failed to load brands',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ),
          );
        }

        // Success state
        if (state.brands.status == Status.completed) {
          final brands = state.brands.data ?? [];


          // Filter brands that have logos
          final brandsWithLogos =
              brands
                  .where((b) => b.imageUrl != null && b.imageUrl!.isNotEmpty)
                  .toList();

          if (brandsWithLogos.isEmpty) {
            return const SizedBox.shrink();
          }

          // Convert BrandEntity list to Map format for BrandScrollCubit compatibility
          final brandList =
              brandsWithLogos
                  .map(
                    (brand) => {
                      'id': brand.id.hashCode,
                      'name': brand.name,
                      'vendor': brand.vendor,
                      'imageUrl': brand.imageUrl!,
                    },
                  )
                  .toList();


          return BlocProvider(
            create: (context) => BrandScrollCubit(brandList: brandList),
            child: SizedBox(
              height: 28.h,
              child: BlocBuilder<BrandScrollCubit, int>(
                builder: (context, scrollState) {
                  final cubit = context.read<BrandScrollCubit>();
                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        cubit.updateScrollPosition(notification.metrics.pixels);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: cubit.scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: brandsWithLogos.length,
                      itemBuilder: (context, index) {
                        final brand = brandsWithLogos[index];
                        return BrandCard(
                          imageUrl: brand.imageUrl!,
                          onTap: () {
                            // Navigate to brand details page
                            Navigator.pushNamed(
                              context,
                              '/brand_details',
                              arguments: {
                                'brandId': brand.id.hashCode,
                                'brandName': brand.name,
                                'brandVendor': brand.vendor,
                                'brandImageUrl': brand.imageUrl!,
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        }

        // Initial state
        return const SizedBox.shrink();
      },
    );
  }
}
