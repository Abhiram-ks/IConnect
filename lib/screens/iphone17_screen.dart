import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/models/series_model.dart';
import 'package:iconnect/widgets/shopify_product_grid_section.dart';

class IPhone17Screen extends StatefulWidget {
  const IPhone17Screen({super.key});

  @override
  State<IPhone17Screen> createState() => _IPhone17ScreenState();
}

class _IPhone17ScreenState extends State<IPhone17Screen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Define iPhone 17 model sections with different spec queries
  final List<Map<String, String>> _iphone17Sections = [
    {'title': 'iPhone 17', 'query': 'iPhone 17'},
    {'title': 'iPhone 17 Pro', 'query': 'iPhone 17 Pro'},
    {'title': 'iPhone 17 Pro Max', 'query': 'iPhone 17 Pro Max'},
    {'title': 'iPhone 17 Plus', 'query': 'iPhone 17 Plus'},
  ];

  @override
  void initState() {
    super.initState();
    // Load all iPhone 17 products with a general query
    context.read<ProductBloc>().add(
      LoadSeriesProduct(model: ModelName.iPhone17, first: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppPalette.whiteColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Text(
                'iPhone 17 Series',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.blackColor,
                ),
              ),
            ),

            // Sections for each iPhone 17 model
            ..._iphone17Sections.map(
              (section) =>
                  _buildIPhoneSection(section['title']!, section['query']!),
            ),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildIPhoneSection(String title, String query) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Only use products if the model matches iPhone 17
        final seriesData = state.seriesProducts?[ModelName.iPhone17];
        if (seriesData == null) {
          return const SizedBox.shrink();
        }
        // Filter products by query - match products that contain the query string
        final filteredProducts =
            seriesData.products.where((product) {
              final productTitle = product.title.toLowerCase();
              final queryLower = query.toLowerCase();

              // More precise matching to avoid overlaps
              if (queryLower == 'iphone 17 pro max') {
                // Only match exact "iPhone 17 Pro Max"
                return productTitle.contains('iphone 17 pro max');
              } else if (queryLower == 'iphone 17 pro') {
                // Match "iPhone 17 Pro" but not "Pro Max"
                return productTitle.contains('iphone 17 pro') &&
                    !productTitle.contains('iphone 17 pro max');
              } else if (queryLower == 'iphone 17 plus') {
                // Match "iPhone 17 Plus"
                return productTitle.contains('iphone 17 plus');
              } else if (queryLower == 'iphone 17') {
                // Match "iPhone 17" but not "Pro" or "Plus"
                return productTitle.contains('iphone 17') &&
                    !productTitle.contains('iphone 17 pro') &&
                    !productTitle.contains('iphone 17 plus');
              }

              // Fallback to simple contains
              return productTitle.contains(queryLower);
            }).toList();

        if (filteredProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.blackColor,
                ),
              ),
            ),

            // Horizontal Scrollable Products
            SizedBox(
              height: 280.h,
              child: _buildProductList(state, filteredProducts),
            ),

            SizedBox(height: 24.h),
          ],
        );
      },
    );
  }

  Widget _buildProductList(
    ProductState state,
    List<ProductEntity> filteredProducts,
  ) {
    final seriesData = state.seriesProducts?[ModelName.iPhone17];
    if (seriesData == null || seriesData.loading == true) {
      return Center(
        child: CircularProgressIndicator(color: AppPalette.blueColor),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Container(
            width: 180.w,
            color: Colors.white,
            child: ShopifyGridProductCard(product: product),
          ),
        );
      },
    );
  }
}
