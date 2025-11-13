import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconnect/constant/constant.dart';

class WhatsAppFloatingButton extends StatelessWidget {
  const WhatsAppFloatingButton({super.key});

  Future<void> _openWhatsApp() async {
    const phoneNumber = WhatsAppConfig.phoneNumber;
    const message = WhatsAppConfig.defaultMessage;

    final url = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error opening WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20.h,
      right: 20.w,
      child: GestureDetector(
        onTap: _openWhatsApp,
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
