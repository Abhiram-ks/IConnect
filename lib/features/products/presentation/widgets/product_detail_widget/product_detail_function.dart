import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconnect/features/cart/domain/entities/cart_item_entity.dart';
import 'package:iconnect/features/cart/presentation/cubit/cart_cubit.dart';
import '../../../../checkout/presentation/cubit/checkout_cubit.dart';
import 'package:iconnect/features/checkout/presentation/pages/checkout_webview_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app_palette.dart';
import '../../../../../common/custom_button.dart';
import '../../../../../common/custom_snackbar.dart';
import '../../../../../constant/constant.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../domain/entities/product_entity.dart';
import '../../bloc/quantity_cubit.dart';

Widget buildActionButtons(
  ProductEntity product,
  BuildContext context,
  ProductVariantEntity? selectedVariant,
) {
  return _ActionButtonsWidget(
    product: product,
    selectedVariant: selectedVariant,
  );
}

class _ActionButtonsWidget extends StatefulWidget {
  final ProductEntity product;
  final ProductVariantEntity? selectedVariant;

  const _ActionButtonsWidget({required this.product, this.selectedVariant});

  @override
  State<_ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<_ActionButtonsWidget> {
  bool _isCreatingCheckout = false;

  Future<void> _handleBuyNow(BuildContext localContext) async {
    setState(() {
      _isCreatingCheckout = true;
    });

    try {
      await buyNow(
        localContext,
        widget.product,
        context,
        widget.selectedVariant,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingCheckout = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (builderContext) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              if (widget.product.availableForSale)
                CustomButton(
                  onPressed:
                      () => _addToCart(
                        builderContext,
                        widget.product,
                        widget.selectedVariant,
                      ),
                  text: 'Add to cart',
                  bgColor: AppPalette.whiteColor,
                  textColor: AppPalette.blackColor,
                  borderColor: AppPalette.blackColor,
                ),
              ConstantWidgets.hight10(context),
              if (widget.product.availableForSale)
                CustomButton(
                  onPressed:
                      _isCreatingCheckout
                          ? null
                          : () => _handleBuyNow(builderContext),
                  text:
                      _isCreatingCheckout
                          ? 'Creating checkout...'
                          : 'Buy it now',
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
                      onPressed:
                          _isCreatingCheckout
                              ? null
                              : () => _handleBuyNow(builderContext),
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
}

void _addToCart(
  BuildContext localContext,
  ProductEntity product,
  ProductVariantEntity? selectedVariant,
) async {
  try {
    final variant =
        selectedVariant ??
        (product.variants.isNotEmpty ? product.variants.first : null);

    if (variant == null) {
      CustomSnackBar.show(
        localContext,
        message: 'No variant available for this product.',
        textAlign: TextAlign.center,
        backgroundColor: AppPalette.redColor,
      );
      return;
    }

    CustomSnackBar.show(
      localContext,
      message: 'Adding ${product.title} to cart...',
      textAlign: TextAlign.center,
      backgroundColor: AppPalette.blueColor,
    );
    await sl<CartCubit>().addToCart(
      variantId: variant.id,
      quantity: localContext.read<QuantityCubit>().state.count,
    );

    final cartState = sl<CartCubit>().state;
    if (cartState is CartLoaded || cartState is CartOperationInProgress) {
      CustomSnackBar.show(
        // ignore: use_build_context_synchronously
        localContext,
        message: '${product.title} added to cart successfully!',
        textAlign: TextAlign.center,
        backgroundColor: AppPalette.greenColor,
      );
    } else if (cartState is CartError) {
      CustomSnackBar.show(
        // ignore: use_build_context_synchronously
        localContext,
        message: 'Error: ${cartState.message}',
        textAlign: TextAlign.center,
        backgroundColor: AppPalette.redColor,
      );
    }
  } catch (e) {
    CustomSnackBar.show(
      // ignore: use_build_context_synchronously
      localContext,
      message: 'Error adding to cart: $e',
      textAlign: TextAlign.center,
      backgroundColor: AppPalette.redColor,
    );
  }
}

Future<void> buyNow(
  BuildContext localContext,
  ProductEntity product,
  BuildContext context,
  ProductVariantEntity? selectedVariant,
) async {
  // Determine the variant
  final variant =
      selectedVariant ??
      (product.variants.isNotEmpty ? product.variants.first : null);

  if (variant == null) {
    CustomSnackBar.show(
      localContext,
      message: 'No variant available for this product.',
      textAlign: TextAlign.center,
      backgroundColor: AppPalette.redColor,
    );
    return;
  }

  // Determine the image to display
  String imageUrl = '';

  // 1. Check selected variant image
  if (selectedVariant != null &&
      selectedVariant.image != null &&
      selectedVariant.image!.isNotEmpty) {
    imageUrl = selectedVariant.image!;
  }
  // 2. Check product featured image
  else if (product.featuredImage != null && product.featuredImage!.isNotEmpty) {
    imageUrl = product.featuredImage!;
  }
  // 3. Fallback to first image in product images list
  else if (product.images.isNotEmpty) {
    imageUrl = product.images.first;
  }

  // Get quantity
  final int qty = localContext.read<QuantityCubit>().state.count;
  final double price = variant.price;
  final String currency = variant.currencyCode;

  // Create CartItemEntity for the single item
  final item = CartItemEntity(
    id:
        DateTime.now().millisecondsSinceEpoch
            .toString(), // Temporary ID for buy now
    variantId: variant.id,
    productId: product.id,
    title: variant.title,
    productTitle: product.title,
    quantity: qty,
    price: price,
    currencyCode: currency,
    imageUrl: imageUrl,
  );

  try {
    // Clear any previous checkout state
    sl<CheckoutCubit>().clearCheckoutData();

    // Set single item checkout (Buy Now mode)
    sl<CheckoutCubit>().setSingleItemCheckout(item: item);

    // Create Shopify checkout directly
    await sl<CheckoutCubit>().createShopifyCheckout();

    // Get checkout state
    final checkoutState = sl<CheckoutCubit>().state;

    if (checkoutState is CheckoutCreated) {
      // Navigate to WebView with checkout URL
      if (context.mounted) {
        debugPrint(
          'BuyNow: Navigating to CheckoutWebViewScreen with showExitConfirmation: false',
        );
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CheckoutWebViewScreen(
                  checkoutUrl: checkoutState.webUrl,
                  showExitConfirmation: false, // No confirmation for Buy Now
                  customerAccessToken: checkoutState.customerAccessToken,
                ),
          ),
        );
      }
    } else if (checkoutState is CheckoutError) {
      // Show error message
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: checkoutState.message,
          textAlign: TextAlign.center,
          backgroundColor: AppPalette.redColor,
        );
      }
    }
  } catch (e) {
    // Show error message
    if (context.mounted) {
      CustomSnackBar.show(
        context,
        message: 'Error creating checkout: $e',
        textAlign: TextAlign.center,
        backgroundColor: AppPalette.redColor,
      );
    }
  }
}

Future<void> _makePhoneCall(BuildContext context) async {
  final phoneNumber = PhoneConfig.phoneNumber;
  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

  try {
    await launchUrl(phoneUri);
  } catch (e) {
    debugPrint('Error making phone call: $e');
    // ignore: use_build_context_synchronously
    CustomSnackBar.show(
      context,
      message: 'Error: $e',
      textAlign: TextAlign.center,
      backgroundColor: AppPalette.redColor,
    );
  }
}
