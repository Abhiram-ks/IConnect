
  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app_palette.dart';
import '../../../../../common/custom_snackbar.dart';
import '../../../../../constant/constant.dart';
import '../../../domain/entities/product_entity.dart';
import '../../bloc/quantity_cubit.dart';

String composeWhatsAppMessage(BuildContext context, ProductEntity product, {ProductVariantEntity? selectedVariant}) {
    final int qty = context.read<QuantityCubit>().state.count;
    final String title = product.title;
    final String id = product.id;
    final String handle = product.handle;
    final ProductVariantEntity? variant = selectedVariant ?? (product.variants.isNotEmpty ? product.variants.first : null);
    final String? variantTitle = variant?.title;
    final double unitPrice = variant?.price ?? product.minPrice;
    final String currency = variant?.currencyCode ?? product.currencyCode;
    final double subtotal = unitPrice * qty;
    final String productUrl = WebsiteConfig.productUrl(handle);

    final StringBuffer sb = StringBuffer();
    sb.writeln('Hello! I would like to buy the following:');
    sb.writeln('- Product: $title');
    sb.writeln('- ID: $id');
    if (variantTitle != null && variantTitle.isNotEmpty) {
      sb.writeln('- Variant: $variantTitle');
    }
    sb.writeln('- Unit Price: $currency ${unitPrice.toStringAsFixed(2)}');
    sb.writeln('- Quantity: $qty');
    sb.writeln('- Subtotal: $currency ${subtotal.toStringAsFixed(2)}');
    if (productUrl.isNotEmpty) {
      sb.writeln('- Link: $productUrl');
    } else {
      sb.writeln('- Handle: $handle');
    }
    return sb.toString();
  }

  Future<void> launchWhatsAppWithMessage(BuildContext context, String message) async {
    final phoneNumber = WhatsAppConfig.phoneNumber;
    final Uri waUri = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    try {
      await launchUrl(waUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // ignore: use_build_context_synchronously
      CustomSnackBar.show(context, message: 'Error launching WhatsApp: $e', textAlign: TextAlign.center, backgroundColor: AppPalette.redColor);
    }
  }
