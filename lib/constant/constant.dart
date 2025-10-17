
import 'package:flutter/material.dart';
import 'media_quary_helper.dart';

class ConstantWidgets {
  static Widget hight10(BuildContext context) {
    return SizedBox(height: MeidaQuaryHelper.height(context) * 0.01);
  }

  static Widget hight20(BuildContext context) {
    return SizedBox(height: MeidaQuaryHelper.height(context) * 0.02);
  }

  
  static Widget hight30(BuildContext context) {
    return SizedBox(height: MeidaQuaryHelper.height(context) * 0.03);
  }
  
  static Widget hight50(BuildContext context) {
    return SizedBox(height: MeidaQuaryHelper.height(context) * 0.05);
  }
  static Widget width20(BuildContext context){
    return SizedBox(width: MeidaQuaryHelper.width(context) * 0.02);
  }

  static Widget width40(BuildContext context){
    return SizedBox(width: MeidaQuaryHelper.width(context) * 0.04);
  }

}

class WhatsAppConfig {
  // WhatsApp phone number (with country code, no + sign)
  // Qatar number: +974 7048 9798
  static const String phoneNumber = '97470489798';
  
  // Default message when opening WhatsApp
  static const String defaultMessage = 'Hello, I need help with my order';
}

class PhoneConfig {
  // Phone number for direct calls
  static const String phoneNumber = '7592979193';
}