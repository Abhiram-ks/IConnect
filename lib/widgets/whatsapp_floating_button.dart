import 'package:flutter/material.dart';
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
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: _openWhatsApp,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF25D366), // WhatsApp green color
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            FontAwesomeIcons.whatsapp,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
