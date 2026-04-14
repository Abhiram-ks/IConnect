import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconnect/constant/constant.dart';

class WhatsAppFloatingButton extends StatelessWidget {
  const WhatsAppFloatingButton({super.key});

  Future<void> _openWhatsApp(BuildContext context) async {
    const phoneNumber = WhatsAppConfig.phoneNumber;
    const message = WhatsAppConfig.defaultMessage;
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final encodedMessage = Uri.encodeComponent(message);

    final appUrl = Uri.parse(
      'whatsapp://send?phone=$normalizedPhone&text=$encodedMessage',
    );
    final webUrl = Uri.parse(
      'https://wa.me/$normalizedPhone?text=$encodedMessage',
    );

    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening WhatsApp: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Could not open WhatsApp. Please make sure it is installed.',
          textAlign: TextAlign.center,
          backgroundColor: AppPalette.redColor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20.h,
      right: 20.w,
      child: GestureDetector(
        onTap: () => _openWhatsApp(context),
        child: Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: const Color(0xFF25D366), // WhatsApp green color
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Icon(
            FontAwesomeIcons.whatsapp,
            color: Colors.white,
            size: 32.sp,
          ),
        ),
      ),
    );
  }
}
