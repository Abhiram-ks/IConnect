import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_drawer.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/cart/presentation/widgets/cart_drawer_widget.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart'
    as products;
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/widgets/brands_widgets/brands_widget_hero.dart';
import 'package:iconnect/features/products/presentation/widgets/brands_widgets/brands_widget_product.dart';
import 'package:iconnect/screens/nav_screen.dart';
import 'package:iconnect/widgets/navbar_widgets.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';

import '../../../../constant/constant.dart';

/// Brand Details Page - Shows brand categories and products
class BrandDetailsPage extends StatefulWidget {
  final int brandId;
  final String brandName;
  final String brandVendor;
  final String brandImageUrl;

  const BrandDetailsPage({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.brandVendor,
    required this.brandImageUrl,
  });

  @override
  State<BrandDetailsPage> createState() => _BrandDetailsPageState();
}

class _BrandDetailsPageState extends State<BrandDetailsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load products filtered by vendor (brand) using separate state
    context.read<products.ProductBloc>().add(
      LoadBrandProductsRequested(vendor: widget.brandVendor, first: 20),
    );
    // Load collections (categories)
    context.read<products.ProductBloc>().add(
      LoadCollectionsRequested(first: 20, forBanners: false),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<products.ProductBloc>().state;
      if (state.brandProducts.status == Status.completed &&
          state.brandProductsHasNextPage) {
        context.read<products.ProductBloc>().add(
          LoadBrandProductsRequested(
            vendor: widget.brandVendor,
            after: state.brandProductsEndCursor,
            loadMore: true,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      endDrawer: const CartDrawerWidget(),
      appBar: CustomAppBarDashbord(),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildBrandHero(context, widget),
                buildBrandProductsSection(context, widget),
                ConstantWidgets.hight10(context),
              ],
            ),
          ),
          const WhatsAppFloatingButton(),
        ],
      ),
      bottomNavigationBar: BottomNavWidget(),
    );
  }
}
