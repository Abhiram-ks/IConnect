
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConstantWidgets {
  static Widget hight10(BuildContext context) {
    return SizedBox(height: 10.h);
  }

  static Widget hight20(BuildContext context) {
    return SizedBox(height: 20.h);
  }

  
  static Widget hight30(BuildContext context) {
    return SizedBox(height: 30.h);
  }
  
  static Widget hight50(BuildContext context) {
    return SizedBox(height: 50.h);
  }
  static Widget width20(BuildContext context){
    return SizedBox(width: 20.w);
  }

  static Widget width40(BuildContext context){
    return SizedBox(width: 40.w);
  }

}

class WhatsAppConfig {
  // WhatsApp phone number (with country code, no + sign)
  // Qatar number: +974 7048 9798
  static const String phoneNumber = '+974 7048 9798';
  
  // Default message when opening WhatsApp
  static const String defaultMessage = 'Hello, I need help with my order';
}

class PhoneConfig {
  // Phone number for direct calls
  static const String phoneNumber = '+974 7048 9798';
}

class WebsiteConfig {
  // Base URL for public product pages (used in WhatsApp deep links)
  // Update this to your live site domain. Example:
  // https://iconnect.qa/products/
  static const String productBaseUrl = 'https://iconnect.qa/products/';

  static String productUrl(String handle) {
    if (productBaseUrl.isEmpty) return '';
    return '$productBaseUrl$handle';
  }
}