  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:iconnect/features/products/presentation/widgets/product_detail_widget/checkout_product_function.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app_palette.dart';
import '../../../../../common/custom_button.dart';
import '../../../../../common/custom_snackbar.dart';
import '../../../../../constant/constant.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../domain/entities/product_entity.dart';
import '../../bloc/quantity_cubit.dart';

Widget buildActionButtons(ProductEntity product, BuildContext context, ProductVariantEntity? selectedVariant) {
    return Builder(
      builder: (builderContext) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              if (product.availableForSale)
                CustomButton(
                  onPressed: () => _addToCart(builderContext, product, selectedVariant),
                  text: 'Add to cart',
                  bgColor: AppPalette.whiteColor,
                  textColor: AppPalette.blackColor,
                  borderColor: AppPalette.blackColor,
                ),
              ConstantWidgets.hight10(context),
              if (product.availableForSale)
                CustomButton(
                  onPressed: () => buyNow(builderContext, product, context, selectedVariant),
                  text: 'Buy it now',
                  bgColor: AppPalette.blackColor,
                  textColor: AppPalette.whiteColor,
                  borderColor: AppPalette.blackColor,
                ),
              ConstantWidgets.hight10(context),
              Row(
                
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(context),
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
                      onPressed: () => _launchWhatsApp(context),
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
      },
    );
  }



  
  void _addToCart(BuildContext localContext, ProductEntity product, ProductVariantEntity? selectedVariant) async {
    try {
      final variant = selectedVariant ?? (product.variants.isNotEmpty ? product.variants.first : null);

      if (variant == null) {
        CustomSnackBar.show(localContext, message: 'No variant available for this product.', textAlign: TextAlign.center, backgroundColor: AppPalette.redColor);
        return;
      }

      CustomSnackBar.show(localContext, message: 'Adding ${product.title} to cart...', textAlign: TextAlign.center, backgroundColor: AppPalette.blueColor);
      await sl<CartCubit>().addToCart(
        variantId: variant.id,
        quantity: localContext.read<QuantityCubit>().state.count,
      );

      // Check if the operation was successful
      final cartState = sl<CartCubit>().state;
      if (cartState is CartLoaded || cartState is CartOperationInProgress) {
        // ignore: use_build_context_synchronously
        CustomSnackBar.show(localContext, message: '${product.title} added to cart successfully!', textAlign: TextAlign.center, backgroundColor: AppPalette.greenColor);
      } else if (cartState is CartError) {
        // ignore: use_build_context_synchronously
        CustomSnackBar.show(localContext, message: 'Error: ${cartState.message}', textAlign: TextAlign.center, backgroundColor: AppPalette.redColor);
      }
    } catch (e) { 
      // ignore: use_build_context_synchronously
      CustomSnackBar.show(localContext, message: 'Error adding to cart: $e', textAlign: TextAlign.center, backgroundColor: AppPalette.redColor);
    }
  }

  void buyNow(BuildContext localContext, ProductEntity product, BuildContext context, ProductVariantEntity? selectedVariant) {
    final String message = composeWhatsAppMessage(localContext, product, selectedVariant: selectedVariant);
    launchWhatsAppWithMessage(localContext, message);
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    final phoneNumber = PhoneConfig.phoneNumber;
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
        await launchUrl(phoneUri);
    } catch (e) {
      debugPrint('Error making phone call: $e');
      // ignore: use_build_context_synchronously
      CustomSnackBar.show(context, message: 'Error: $e', textAlign: TextAlign.center, backgroundColor: AppPalette.redColor);
    }
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final phoneNumber = PhoneConfig.phoneNumber;
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');

    try {
       await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      
    } catch (e) {
      // ignore: use_build_context_synchronously
      CustomSnackBar.show(context, message: 'Error launching WhatsApp: $e', textAlign: TextAlign.center, backgroundColor: AppPalette.redColor);
    }
  }