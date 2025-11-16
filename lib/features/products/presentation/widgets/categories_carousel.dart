import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/widgets/category_card.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

/// Categories Carousel Widget - Displays categories in a horizontal scrollable carousel
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
    
    // Load categories (collections) from Shopify
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<ProductBloc>().add(
          LoadCollectionsRequested(first: 20, forBanners: false),
        );
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
        // Debug: Print current state
        print(
          '🔍 Categories State: ${state.collections.status}',
        );
        if (state.collections.data != null) {
          print(
            '📦 Collections count: ${state.collections.data!.length}',
          );
        }
        if (state.collections.message != null) {
          print('❌ Error: ${state.collections.message}');
        }

        // Show loading indicator while fetching
        if (state.collections.status == Status.loading) {
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
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show error state with message
        if (state.collections.status == Status.error) {
          return Container(
            height: 110.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppPalette.redColor,
                    size: 32.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Failed to load categories',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    state.collections.message ?? '',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(
                        LoadCollectionsRequested(
                          first: 20,
                          forBanners: false,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.blueColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show categories if loaded
        if (state.collections.status == Status.completed) {
          final collections = state.collections.data ?? [];

          // If no collections at all, show message
          if (collections.isEmpty) {
            return Container(
              height: 110.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Center(
                child: Text(
                  'No categories available',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }

          // Filter collections with images for categories
          final categoriesWithImages =
              collections
                  .where(
                    (c) =>
                        c.imageUrl != null &&
                        c.imageUrl!.isNotEmpty,
                  )
                  .toList();

          // If no collections have images, show all collections with placeholder
          final displayCategories =
              categoriesWithImages.isNotEmpty
                  ? categoriesWithImages
                  : collections.take(6).toList();

          // Update categories count for auto-scroll
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                _categoriesCount !=
                    displayCategories.length) {
              setState(() {
                _categoriesCount = displayCategories.length;
              });
            }
          });

          return SizedBox(
            height: 110.h,
            child: GestureDetector(
              onPanDown: (_) => _stopAutoScroll(),
              onPanEnd: (_) => _resumeAutoScroll(),
              onPanCancel: () => _resumeAutoScroll(),
              child: InfiniteCarousel.builder(
                itemCount: displayCategories.length,
                itemExtent: 110.w,
                center: true,
                anchor: 0.0,
                scrollBehavior:
                    kIsWeb
                        ? ScrollConfiguration.of(
                          context,
                        ).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        )
                        : null,
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
                  final collection =
                      displayCategories[itemIndex];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                    ),
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
                            'collectionHandle':
                                collection.handle,
                            'collectionTitle':
                                collection.title,
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
        return Container(
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

