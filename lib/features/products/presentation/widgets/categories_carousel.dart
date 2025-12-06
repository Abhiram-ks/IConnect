import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/widgets/category_card.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class CategoriesCarousel extends StatefulWidget {
  const CategoriesCarousel({super.key});

  @override
  State<CategoriesCarousel> createState() => _CategoriesCarouselState();
}

class _CategoriesCarouselState extends State<CategoriesCarousel> {
  late InfiniteScrollController infiniteScrollController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;
  int _categoriesCount = 0;

  @override
  void initState() {
    super.initState();
    infiniteScrollController = InfiniteScrollController(initialItem: 0);

    // Load home categories (first 20) from Shopify
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<ProductBloc>().add(LoadHomeCategoriesRequested(first: 20));
      }
    });

    // Delay auto-scroll to let UI settle
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 2500), (
      timer,
    ) {
      if (mounted &&
          infiniteScrollController.hasClients &&
          _categoriesCount > 0) {
        _currentIndex = (_currentIndex + 1) % _categoriesCount;
        infiniteScrollController.animateToItem(
          _currentIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _resumeAutoScroll() {
    _stopAutoScroll();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    infiniteScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.homeCategories.status == Status.loading) {
          return SizedBox(
            height: 110.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppPalette.blueColor,
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Loading categories...',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // Show error state with message
        // Show categories if loaded
        if (state.homeCategories.status == Status.completed) {
          final collections = state.homeCategories.data ?? [];

          // If no collections at all, show message
          if (collections.isEmpty) {
            return Container(
              height: 110.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Center(
                child: Text(
                  'No categories available',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ),
            );
          }

          // Filter collections with images for categories
          final categoriesWithImages =
              collections
                  .where((c) => c.imageUrl != null && c.imageUrl!.isNotEmpty)
                  .toList();

          // If no collections have images, show all collections with placeholder
          final displayCategories =
              categoriesWithImages.isNotEmpty
                  ? categoriesWithImages
                  : collections.take(6).toList();

          // Update categories count for auto-scroll
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _categoriesCount != displayCategories.length) {
              setState(() {
                _categoriesCount = displayCategories.length;
              });
            }
          });

          return SizedBox(
            height: 95.h,
            child: GestureDetector(
              onPanDown: (_) => _stopAutoScroll(),
              onPanEnd: (_) => _resumeAutoScroll(),
              onPanCancel: () => _resumeAutoScroll(),
              child: InfiniteCarousel.builder(
                itemCount: displayCategories.length,
                itemExtent: 80.w,
                center: true,
                anchor: 0.0,
                loop: true,
                velocityFactor: 0.15,
                physics: const BouncingScrollPhysics(),
                onIndexChanged: (index) {
                  if (mounted) {
                    _currentIndex = index;
                  }
                },
                controller: infiniteScrollController,
                axisDirection: Axis.horizontal,
                itemBuilder: (context, itemIndex, __) {
                  final collection = displayCategories[itemIndex];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: CategoryCard(
                      imageUrl:
                          collection.imageUrl ??
                          'https://via.placeholder.com/150',
                      title: collection.title,
                      onTap: () {
                        _stopAutoScroll();
                        // Navigate to collection products screen
                        Navigator.pushNamed(
                          context,
                          '/collection_products',
                          arguments: {
                            'collectionHandle': collection.handle,
                            'collectionTitle': collection.title,
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

        // Initial state - show loading
        return SizedBox(
          height: 110.h,
          child: Center(
            child: CircularProgressIndicator(
              color: AppPalette.blueColor,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}
