import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/screens/nav_screen.dart';
import 'package:iconnect/widgets/navbar_widgets.dart';

import '../features/products/presentation/widgets/product_detail_widget/product_detal_staring_body.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productHandle;

  const ProductDetailsScreen({super.key, required this.productHandle});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late PageController _pageController;
  ProductVariantEntity? _selectedVariant;
  ApiResponse<ProductEntity> _localProductDetail = ApiResponse.initial();
  StreamSubscription<ProductState>? _blocSubscription;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadProduct();
  }

  void _loadProduct() {
    setState(() {
      _localProductDetail = ApiResponse.loading();
    });

    // Cancel previous subscription if any
    _blocSubscription?.cancel();

    // Load product using the BLoC
    final bloc = context.read<ProductBloc>();

    // Subscribe to bloc updates and capture the result locally
    _blocSubscription = bloc.stream.listen((state) {
      if (state.productDetail.status != Status.loading && mounted) {
        // Only update if the product handle matches
        if (state.productDetail.data?.handle == widget.productHandle) {
          setState(() {
            _localProductDetail = state.productDetail;
          });
          _blocSubscription?.cancel();
        }
      }
    });

    // Trigger the load
    bloc.add(LoadProductByHandleRequested(handle: widget.productHandle));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _blocSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarDashbord(onBack: () => Navigator.pop(context)),
      body: _buildBody(),
      bottomNavigationBar: BottomNavWidget(),
    );
  }

  Widget _buildBody() {
    if (_localProductDetail.status == Status.loading) {
      return Center(
        child: SizedBox(
          height: 15.h,
          width: 15.w,
          child: CircularProgressIndicator(
            color: AppPalette.greyColor,
            backgroundColor: AppPalette.blueColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_localProductDetail.status == Status.completed) {
      final product = _localProductDetail.data;

      if (product == null) {
        return const Center(child: Text('Product not found'));
      }

      // Fix: Check if selected variant belongs to current product
      // If the screen/state is reused for a different product, this prevents using a stale variant from previous product
      if (_selectedVariant != null &&
          !product.variants.contains(_selectedVariant)) {
        _selectedVariant = null;
      }

      if (_selectedVariant == null && product.variants.isNotEmpty) {
        _selectedVariant = product.variants.first;
      }

      return buildProductDetails(product, context, _selectedVariant);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/iconnect_logo.png',
            height: 25.h,
            fit: BoxFit.contain,
          ),
          Text(
            'We have trouble to process your request.',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppPalette.blackColor,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            ' Please try again later.',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppPalette.greyColor,
            ),
            textAlign: TextAlign.center,
          ),
          IconButton(
            onPressed: _loadProduct,
            icon: Icon(Icons.refresh, size: 24.sp),
          ),
        ],
      ),
    );
  }
}
