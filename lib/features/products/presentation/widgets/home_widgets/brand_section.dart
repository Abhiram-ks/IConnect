import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/data/static_mobile_brands.dart';
import 'package:iconnect/features/products/presentation/widgets/home_widgets/brand_card.dart';

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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startContinuousScroll();
    });
  }

  void _startContinuousScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted || _isUserInteracting) return;
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;
      final maxScroll = position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      // Calculate the midpoint (where we reset)
      final midPoint = maxScroll / 2;

      // Smooth continuous scroll
      final newOffset = currentScroll + (_scrollSpeed * 0.05);

      // When we reach the midpoint, jump back to the start seamlessly
      if (newOffset >= midPoint) {
        _scrollController.jumpTo(0);
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
    // Get static mobile brands data
    final brands = StaticMobileBrands.getAllBrands();

    if (brands.isEmpty) {
      return const SizedBox.shrink();
    }

    // Duplicate the brands list to create infinite loop effect
    final duplicatedBrands = [...brands, ...brands];

    return SizedBox(
      height: 50.h,
      child: GestureDetector(
        onPanDown: (_) => _stopAutoScroll(),
        onPanEnd: (_) => _resumeAutoScroll(),
        onPanCancel: () => _resumeAutoScroll(),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          itemCount: duplicatedBrands.length,
          itemBuilder: (context, index) {
            final brand = duplicatedBrands[index];
            return SizedBox(
              child: BrandCard(
                imageUrl: brand.imageUrl,
                name: brand.name,
                onTap: () {
                  _stopAutoScroll();
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
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
