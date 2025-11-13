
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
  static const String phoneNumber = '97470489798';
  
  // Default message when opening WhatsApp
  static const String defaultMessage = 'Hello, I need help with my order';
}

class PhoneConfig {
  // Phone number for direct calls
  static const String phoneNumber = '7592979193';
}