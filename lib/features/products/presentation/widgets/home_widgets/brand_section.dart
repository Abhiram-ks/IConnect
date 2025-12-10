import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/widgets/home_widgets/brand_card.dart';
import 'package:iconnect/screens/collection_products_screen.dart';

class BrandSection extends StatefulWidget {
  const BrandSection({super.key});

  @override
  State<BrandSection> createState() => _BrandSectionState();
}

class _BrandSectionState extends State<BrandSection> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  static const double _scrollSpeed = 30.0; // pixels per second
  bool _shouldLoop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Load brands from API
    context.read<ProductBloc>().add(LoadBrandsRequested(first: 100));
  }

  void _startContinuousScroll() {
    if (!_shouldLoop) {
      _autoScrollTimer?.cancel();
      return;
    }

    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted || _isUserInteracting) return;
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;
      final maxScroll = position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      // Calculate midpoint (where first copy ends and second copy starts)
      final midPoint = maxScroll / 2;

      // Smooth continuous scroll from left to right
      final newOffset = currentScroll + (_scrollSpeed * 0.05);

      // When we reach the midpoint (end of first copy), jump back to start seamlessly
      // This creates infinite loop effect without visible jump
      if (newOffset >= midPoint) {
        _scrollController.jumpTo(newOffset - midPoint);
      } else {
        _scrollController.jumpTo(newOffset);
      }
    });
  }

  void _stopAutoScroll() {
    _isUserInteracting = true;
    _autoScrollTimer?.cancel();
  }

  void _resumeAutoScroll() {
    _isUserInteracting = false;
    _startContinuousScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Handle different states
        if (state.brands.status == Status.loading ||
            state.brands.status == Status.initial) {
          return const SizedBox.shrink(); // Hide while loading
        }

        if (state.brands.status == Status.error) {
          return const SizedBox.shrink(); // Hide on error
        }

        final brands = state.brands.data ?? [];

        // Filter out brands without image URLs
        final brandsWithImages =
            brands
                .where(
                  (brand) =>
                      brand.imageUrl != null && brand.imageUrl!.isNotEmpty,
                )
                .toList();

        if (brandsWithImages.isEmpty) {
          return const SizedBox.shrink();
        }

        // Only enable infinite loop if there are more than 4 brands
        final shouldLoop = brandsWithImages.length > 4;

        // For seamless infinite loop, duplicate the list (only for display)
        // This allows us to jump back to start when reaching midpoint without visible jump
        final displayBrands =
            shouldLoop
                ? [...brandsWithImages, ...brandsWithImages]
                : brandsWithImages;

        // Update loop state and start/stop scrolling accordingly
        if (_shouldLoop != shouldLoop) {
          _shouldLoop = shouldLoop;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (_shouldLoop) {
                _startContinuousScroll();
              } else {
                _autoScrollTimer?.cancel();
              }
            }
          });
        } else if (_shouldLoop) {
          // Ensure scrolling is active if we should loop
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _autoScrollTimer == null) {
              _startContinuousScroll();
            }
          });
        }

        return SizedBox(
          height: 40.h,
          child: GestureDetector(
            onPanDown: (_) => _stopAutoScroll(),
            onPanEnd: (_) => _resumeAutoScroll(),
            onPanCancel: () => _resumeAutoScroll(),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics:
                  shouldLoop
                      ? const ClampingScrollPhysics()
                      : const BouncingScrollPhysics(),
              itemCount: displayBrands.length,
              itemBuilder: (context, index) {
                // Use modulo to get the actual brand from original list
                final brandIndex =
                    shouldLoop ? index % brandsWithImages.length : index;
                final brand = brandsWithImages[brandIndex];
                return SizedBox(
                  child: BrandCard(
                    imageUrl: brand.imageUrl!,
                    name: brand.name,
                    onTap: () {
                      _stopAutoScroll();
                      // Use categoryHandle if available, otherwise fallback to brand_details
                      final categoryHandle = brand.categoryHandle;

                      if (categoryHandle != null && categoryHandle.isNotEmpty) {
                        // Navigate to collection screen using category handle
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CollectionProductsScreen(
                                  collectionHandle: categoryHandle,
                                  collectionTitle: brand.name,
                                ),
                          ),
                        );
                      } else {
                        // Fallback to brand_details if no categoryHandle
                        Navigator.pushNamed(
                          context,
                          '/brand_details',
                          arguments: {
                            'brandId': brand.id.hashCode,
                            'brandName': brand.name,
                            'brandVendor': brand.vendor,
                            'brandImageUrl': brand.imageUrl,
                          },
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
