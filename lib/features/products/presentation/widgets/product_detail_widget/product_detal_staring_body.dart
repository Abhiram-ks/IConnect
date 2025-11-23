  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/presentation/widgets/product_detail_widget/product_detail_function.dart' show buildActionButtons;
import 'package:iconnect/features/products/presentation/widgets/product_detail_widget/product_details_qualit.dart';

import '../../../../../app_palette.dart';
import '../../../../../constant/constant.dart';
import '../../../../../widgets/whatsapp_floating_button.dart';
import '../../bloc/quantity_cubit.dart';
import 'product_detail_description.dart';
import 'product_detail_image_banner.dart';
import 'product_details_alsolike.dart';
import 'product_details_price_widget.dart';

Widget buildProductDetails(ProductEntity product, BuildContext context, ProductVariantEntity? selectedVariant) {
    // Choose a reasonable default max per order
    final int maxPerOrder = 10;

    return BlocProvider(
      create: (_) => QuantityCubit(initial: 1, min: 1, max: maxPerOrder),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildProductImageBanner(product),
                buildProductDetailsSection(product),
                buildPriceSection(product, selectedVariant: selectedVariant),
                product.availableForSale ?
                buildQuantitySection() : Center(child: Text('Currently Unavailable For Sale', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: AppPalette.blackColor), textAlign: TextAlign.center, )),
                buildActionButtons(product, context, selectedVariant),
                buildProductDescription(product),
                buildYouMayAlsoLikeSection(context, product.id),
                ConstantWidgets.hight10(context),
              ],
            ),
          ),
          const WhatsAppFloatingButton(),
        ],
      ),
    );
  }