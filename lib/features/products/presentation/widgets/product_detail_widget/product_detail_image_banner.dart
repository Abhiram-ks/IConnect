import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';

Widget buildProductImageBanner(
  ProductEntity product, {
  String? selectedVariantImage,
  bool? isOutOfStock,
}) {
  return ProductDetailImageBanner(
    product: product,
    selectedVariantImage: selectedVariantImage,
    isOutOfStock: isOutOfStock,
  );
}

class ProductDetailImageBanner extends StatefulWidget {
  final ProductEntity product;
  final String? selectedVariantImage;
  final bool? isOutOfStock;

  const ProductDetailImageBanner({
    super.key,
    required this.product,
    this.selectedVariantImage,
    this.isOutOfStock,
  });

  @override
  State<ProductDetailImageBanner> createState() => _ProductDetailImageBannerState();
}

class _ProductDetailImageBannerState extends State<ProductDetailImageBanner> {
  late final PageController _pageController;
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  List<String> _buildImages(ProductEntity product, String? selectedVariantImage) {
    final List<String> orderedImages = [];
    final Set<String> seen = <String>{};

    void addIfValid(String? url) {
      if (url == null) return;
      final trimmed = url.trim();
      if (trimmed.isEmpty) return;
      if (seen.add(trimmed)) {
        orderedImages.add(trimmed);
      }
    }

    // Prefer selected variant image first if provided
    addIfValid(selectedVariantImage);

    // Product gallery images
    for (final img in product.images) {
      addIfValid(img);
    }

    // Fallback to featured image if nothing else
    if (orderedImages.isEmpty) {
      addIfValid(product.featuredImage);
    }

    return orderedImages;
  }

  @override
  Widget build(BuildContext context) {
    final productImages = _buildImages(widget.product, widget.selectedVariantImage);
    final bool outOfStock = widget.isOutOfStock ?? !widget.product.availableForSale;

    if (productImages.isEmpty) {
      return Container(
        height: 300.h,
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 300.h,
          width: double.infinity,
          color: outOfStock ? Colors.white : Colors.grey[100],
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => _currentIndex.value = index,
                itemCount: productImages.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    panEnabled: true,
                    scaleEnabled: true,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: productImages[index],
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: AppPalette.blueColor,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 100,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              if (outOfStock)
                Positioned.fill(
                  child: Container(
                    color: AppPalette.blackColor.withValues(alpha: 0.5),
                  ),
                ),
              if (outOfStock)
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppPalette.blackColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'OUT OF STOCK',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (productImages.length > 1)
          Container(
            height: 80.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: ValueListenableBuilder<int>(
              valueListenable: _currentIndex,
              builder: (context, current, _) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productImages.length,
                  itemBuilder: (context, index) {
                    final bool isActive = current == index;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60.w,
                        height: 60.h,
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isActive ? AppPalette.blackColor : Colors.grey[300]!,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: CachedNetworkImage(
                            imageUrl: productImages[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: AppPalette.blackColor,
                                strokeWidth: 1,
                              ),
                            ),
                            errorWidget: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        if (productImages.length > 1)
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: ValueListenableBuilder<int>(
              valueListenable: _currentIndex,
              builder: (context, current, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    productImages.length,
                    (index) => Container(
                      width: 8.w,
                      height: 8.h,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: current == index ? AppPalette.blackColor : AppPalette.hintColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}