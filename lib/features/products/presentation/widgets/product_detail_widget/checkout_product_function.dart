import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app_palette.dart';
import '../../../../../common/custom_snackbar.dart';
import '../../../../../constant/constant.dart';
import '../../../../cart/domain/entities/cart_item_entity.dart';

String composeWhatsAppMessage(
  BuildContext context, {
  required List<CartItemEntity> items,
  String? contact,
  String? firstName,
  String? lastName,
  String? address,
  String? city,
  String? userWhatsAppNumber,
}) {
  final StringBuffer sb = StringBuffer();
  sb.writeln('Hello! I would like to buy the following:');

  double totalAmount = 0;

  for (final item in items) {
    sb.writeln(
      '\n- Product: ${item.productTitle?.isNotEmpty == true ? item.productTitle : item.title}',
    );
    // Display variant title if it's different from product title and not "Default Title" (common in Shopify)
    if (item.title != item.productTitle && item.title != 'Default Title') {
      sb.writeln('  Variant: ${item.title}');
    }
    sb.writeln(
      '  Price: ${item.currencyCode} ${item.price.toStringAsFixed(2)}',
    );
    sb.writeln('  Quantity: ${item.quantity}');
    sb.writeln(
      '  Subtotal: ${item.currencyCode} ${item.totalPrice.toStringAsFixed(2)}',
    );
    totalAmount += item.totalPrice;
  }

  sb.writeln('\n--------------------------------');
  sb.writeln(
    'Total Amount: ${items.isNotEmpty ? items.first.currencyCode : ""} ${totalAmount.toStringAsFixed(2)}',
  );
  sb.writeln('--------------------------------');

  sb.writeln('\nCustomer Details:');
  if (contact != null && contact.isNotEmpty) sb.writeln('- Contact: $contact');
  if (firstName != null && firstName.isNotEmpty)
    sb.writeln('- First Name: $firstName');
  if (lastName != null && lastName.isNotEmpty)
    sb.writeln('- Last Name: $lastName');
  if (address != null && address.isNotEmpty) sb.writeln('- Address: $address');
  if (city != null && city.isNotEmpty) sb.writeln('- City: $city');
  if (userWhatsAppNumber != null && userWhatsAppNumber.isNotEmpty) {
    sb.writeln('- WhatsApp: $userWhatsAppNumber');
  }

  return sb.toString();
}

Future<void> launchWhatsAppWithMessage(
  BuildContext context,
  String message,
) async {
  final phoneNumber = WhatsAppConfig.phoneNumber;
  final Uri waUri = Uri.parse(
    'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
  );
  try {
    await launchUrl(waUri, mode: LaunchMode.externalApplication);
  } catch (e) {
    // ignore: use_build_context_synchronously
    CustomSnackBar.show(
      context,
      message: 'Error launching WhatsApp: $e',
      textAlign: TextAlign.center,
      backgroundColor: AppPalette.redColor,
    );
  }
}
