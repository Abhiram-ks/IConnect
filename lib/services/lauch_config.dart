import 'package:flutter/material.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

void launchConfig({required BuildContext context, required String url, required String message}) async {
  try {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
     CustomSnackBar.show(context, message: message, backgroundColor: AppPalette.redColor, textAlign: TextAlign.center);
    }
  } catch (e) {
    // ignore: use_build_context_synchronously
    CustomSnackBar.show(context, message: message, backgroundColor: AppPalette.redColor, textAlign: TextAlign.center);
  }
}
