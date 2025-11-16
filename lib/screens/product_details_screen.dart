import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_button.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/screens/search_screen.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productHandle;

  const ProductDetailsScreen({super.key, required this.productHandle});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  late PageController _pageController;
  int _currentImageIndex = 0;
  ProductVariantEntity? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Load product details from Shopify API
    context.read<ProductBloc>().add(
      LoadProductByHandleRequested(handle: widget.productHandle),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Loading state
        if (state.productDetail.status == Status.loading) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.15),
              surfaceTintColor: Colors.white,
              centerTitle: true,
              title: Center(
                child: Image.asset(
                  'assets/iconnect_logo.png',
                  height: 25.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppPalette.blueColor),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading product details...',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // Error state
        if (state.productDetail.status == Status.error) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.15),
              surfaceTintColor: Colors.white,
              centerTitle: true,
              title: Center(
                child: Image.asset(
                  'assets/iconnect_logo.png',
                  height: 25.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load product',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.productDetail.message ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ProductBloc>().add(
                          LoadProductByHandleRequested(
                            handle: widget.productHandle,
                          ),
                        );
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.blueColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Product loaded successfully
        if (state.productDetail.status == Status.completed) {
          final product = state.productDetail.data;

          if (product == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Product Not Found')),
              body: const Center(child: Text('Product not found')),
            );
          }

          // Set initial variant if not set
          if (_selectedVariant == null && product.variants.isNotEmpty) {
            _selectedVariant = product.variants.first;
          }

          return _buildProductDetails(product);
        }

        // Initial/unknown state
        return Scaffold(
          appBar: AppBar(title: const Text('Product Details')),
          body: const Center(child: Text('Loading...')),
        );
      },
    );
  }

  Widget _buildProductDetails(ProductEntity product) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Center(
          child: Image.asset(
            'assets/iconnect_logo.png',
            height: 25.h,
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Banner
                _buildProductImageBanner(product),

                // Product Details Section
                _buildProductDetailsSection(product),

                // Variant Selection (if available)
                // if (product.variants.isNotEmpty)
                //   _buildVariantSelection(product),

                // Price Section
                _buildPriceSection(product),

                // Quantity Section
                _buildQuantitySection(),

                // Action Buttons
                _buildActionButtons(product),

                // Product Description
                _buildProductDescription(product),

                // You May Also Like Section
                _buildYouMayAlsoLikeSection(),

                // Bottom padding
                const SizedBox(height: 100),
              ],
            ),
          ),
          const WhatsAppFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildProductImageBanner(ProductEntity product) {
    // Get product images from the API, prioritizing selected variant image
    List<String> productImages = [];

    // If a variant is selected and has an image, show it first
    if (_selectedVariant?.image != null) {
      productImages.add(_selectedVariant!.image!);
      // Add other product images that are not the variant image
      productImages.addAll(
        product.images.where((img) => img != _selectedVariant!.image!).toList(),
      );
    } else {
      // Use all product images
      productImages =
          product.images.isNotEmpty
              ? product.images
              : (product.featuredImage != null ? [product.featuredImage!] : []);
    }

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
        // Main image carousel
        Container(
          height: 300.h,
          width: double.infinity,
          color: Colors.grey[100],
          child: Stack(
            children: [
              // Image carousel with pinch-to-zoom
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
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
                        placeholder:
                            (context, url) => Center(
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
            ],
          ),
        ),

        // Thumbnail gallery
        if (productImages.length > 1)
          Container(
            height: 80.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: productImages.length,
              itemBuilder: (context, index) {
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
                        color:
                            _currentImageIndex == index
                                ? AppPalette.blackColor
                                : Colors.grey[300]!,
                        width: _currentImageIndex == index ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CachedNetworkImage(
                        imageUrl: productImages[index],
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Center(
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
            ),
          ),

        // Pagination indicators
        if (productImages.length > 1)
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                productImages.length,
                (index) => Container(
                  width: 8.w,
                  height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentImageIndex == index
                            ? AppPalette.blackColor
                            : AppPalette.hintColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductDetailsSection(ProductEntity product) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.left,
          ),
          if (!product.availableForSale)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  'OUT OF STOCK',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVariantSelection(ProductEntity product) {
    if (product.variants.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageVariantSelection(product),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildImageVariantSelection(ProductEntity product) {
    // Filter variants to only show those with images
    final variantsWithImages =
        product.variants.where((variant) => variant.image != null).toList();

    // If no variants have images, don't show the variant selection at all
    if (variantsWithImages.isEmpty) {
      return SizedBox.shrink();
    }

    return SizedBox(
      height: 80.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: variantsWithImages.length,
        itemBuilder: (context, index) {
          final variant = variantsWithImages[index];
          final isSelected = _selectedVariant?.id == variant.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedVariant = variant;
                // Reset to first image when variant is selected
                // The _buildProductImageBanner will reorganize images with variant image first
                _currentImageIndex = 0;
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            },
            child: Container(
              width: 70.w,
              height: 70.h,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppPalette.blackColor : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7.r),
                child: Stack(
                  children: [
                    // Variant image (we know it exists since we filtered)
                    CachedNetworkImage(
                      imageUrl: variant.image!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppPalette.blackColor,
                                strokeWidth: 1,
                              ),
                            ),
                          ),
                      errorWidget: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 20.sp,
                          ),
                        );
                      },
                    ),

                    // Selection overlay
                    if (isSelected)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: AppPalette.blackColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),

                    // Variant title at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(7.r),
                            bottomRight: Radius.circular(7.r),
                          ),
                        ),
                        child: Text(
                          variant.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceSection(ProductEntity product) {
    // Use selected variant price if available, otherwise use product min price
    final price = _selectedVariant?.price ?? product.minPrice;
    final comparePrice =
        _selectedVariant?.compareAtPrice ?? product.compareAtPrice;
    final currencyCode = product.currencyCode;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Text(
            '$currencyCode ${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color:
                  product.hasDiscount
                      ? AppPalette.redColor
                      : AppPalette.blackColor,
            ),
          ),
          if (comparePrice != null && comparePrice > price)
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Text(
                '$currencyCode ${comparePrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
          if (product.hasDiscount && product.discountPercentage != null)
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '-${product.discountPercentage!.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Quantity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300] ?? AppPalette.greyColor,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed:
                      _quantity > 1
                          ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                          : null,
                  icon: const Icon(Icons.remove),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                  icon: const Icon(Icons.add),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ProductEntity product) {
    final isAvailable =
        product.availableForSale &&
        (_selectedVariant?.availableForSale ?? true);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          CustomButton(
            onPressed:
                isAvailable
                    ? () {
                      _addToCart(product);
                    }
                    : null,
            text: isAvailable ? 'Add to cart' : 'Out of Stock',
            bgColor: AppPalette.whiteColor,
            textColor: AppPalette.blackColor,
            borderColor: AppPalette.blackColor,
          ),
          ConstantWidgets.hight10(context),
          Builder(
            builder: (BuildContext scaffoldContext) {
              return CustomButton(
                onPressed:
                    isAvailable
                        ? () {
                          _buyNow(scaffoldContext, product);
                        }
                        : null,
                text: isAvailable ? 'Buy it now' : 'Out of Stock',
                bgColor: AppPalette.blackColor,
                textColor: AppPalette.whiteColor,
                borderColor: AppPalette.blackColor,
              );
            },
          ),
          ConstantWidgets.hight10(context),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _makePhoneCall,
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Order By Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _launchWhatsApp,
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
                  label: const Text('WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ConstantWidgets.hight10(context),
        ],
      ),
    );
  }

  Widget _buildProductDescription(ProductEntity product) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Description',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Html(
            data: product.descriptionHtml,
            extensions: const [
              TableHtmlExtension(), // 👈 this enables <table> support
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYouMayAlsoLikeSection() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.products.status != Status.completed) {
          return SizedBox.shrink();
        }

        final relatedProducts =
            state.products.data
                ?.where((p) => p.handle != widget.productHandle)
                .take(5)
                .toList() ??
            [];

        if (relatedProducts.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'You Might Also Like',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(
              height: 260.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: relatedProducts.length,
                itemBuilder: (context, index) {
                  final product = relatedProducts[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/product_details',
                          arguments: {'productHandle': product.handle},
                        );
                      },
                      child: Container(
                        width: 160.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12.r),
                              ),
                              child: CachedNetworkImage(
                                imageUrl:
                                    product.featuredImage ??
                                    product.images.first,
                                height: 140.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
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
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      '${product.currencyCode} ${product.minPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 13.sp,
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
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(ProductEntity product) async {
    try {
      // Get the selected variant or use the first variant
      final variant =
          _selectedVariant ??
          (product.variants.isNotEmpty ? product.variants.first : null);

      if (variant == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a variant'),
            backgroundColor: AppPalette.redColor,
          ),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text('Adding ${product.title} to cart...'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppPalette.blueColor,
        ),
      );

      // Add to cart using the new API-based cart system
      await sl<CartCubit>().addToCart(
        variantId: variant.id,
        quantity: _quantity,
      );

      // Check if the operation was successful
      final cartState = sl<CartCubit>().state;
      if (cartState is CartLoaded || cartState is CartOperationInProgress) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.title} added to cart successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                sl<CartCubit>().openCartDrawer();
              },
            ),
          ),
        );
      } else if (cartState is CartError) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${cartState.message}'),
            backgroundColor: AppPalette.redColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: AppPalette.redColor,
        ),
      );
    }
  }

  void _buyNow(BuildContext scaffoldContext, ProductEntity product) {
    _addToCart(product);
    // Navigate to cart or checkout
    Scaffold.of(scaffoldContext).openEndDrawer();
  }

  Future<void> _makePhoneCall() async {
    final phoneNumber = PhoneConfig.phoneNumber;
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone dialer'),
              backgroundColor: AppPalette.redColor,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppPalette.redColor,
          ),
        );
      }
    }
  }

  Future<void> _launchWhatsApp() async {
    final phoneNumber = PhoneConfig.phoneNumber;
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch WhatsApp'),
              backgroundColor: AppPalette.redColor,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppPalette.redColor,
          ),
        );
      }
    }
  }
}

class CustomAppBarProductDetails extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onBack;

  @override
  final Size preferredSize;

  const CustomAppBarProductDetails({super.key, this.onBack})
    : preferredSize = const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      surfaceTintColor: Colors.white,
      centerTitle: true,
      title: Center(
        child: Image.asset(
          'assets/iconnect_logo.png',
          height: 25,
          fit: BoxFit.contain,
        ),
      ),
      leading: IconButton.filled(
        tooltip: 'Back',
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        style: IconButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
        ),
      ),
      actions: [
        IconButton.filled(
          icon: const Icon(Icons.search, color: AppPalette.blackColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
                fullscreenDialog: true,
              ),
            );
          },
          tooltip: 'Search',
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.black26,
            shape: const CircleBorder(),
          ),
        ),
        ConstantWidgets.width20(context),
        Builder(
          builder: (BuildContext scaffoldContext) {
            return Stack(
              children: [
                IconButton.filled(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppPalette.blackColor,
                  ),
                  onPressed: () {
                    Scaffold.of(scaffoldContext).openEndDrawer();
                  },
                  tooltip: 'Shopping Cart',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.black26,
                    shape: const CircleBorder(),
                  ),
                ),
                BlocBuilder<CartCubit, CartState>(
                  bloc: sl<CartCubit>(),
                  builder: (context, state) {
                    int itemCount = 0;
                    if (state is CartLoaded) {
                      itemCount = state.cart.itemCount;
                    } else if (state is CartOperationInProgress) {
                      itemCount = state.currentCart.itemCount;
                    }

                    if (itemCount > 0) {
                      return Positioned(
                        right: 8,
                        top: 8,
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
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),
        ConstantWidgets.width40(context),
      ],
    );
  }
}
