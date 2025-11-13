class ValidatorHelper {

  static String? serching(String? text){
    return null;
  }

  static String? validateEmailId(String? email){
    if(email == null || email.isEmpty){
       return 'Please enter email';
    }

    return null;
  }
  static String? validateLocation(String? text){
    if (text == null || text.isEmpty) {
      return 'Plase fill the field';
    }else{
       if(text.startsWith(' ')){
       return "Cannot start with a space.";
     }
    }
    return null;
  }

  static String? validateOtp(String? otp){
    if(otp == null || otp.isEmpty){
      return 'Please enter OTP';
    }
    if(otp.length != 6){
      return 'OTP must be 6 digits';
    }
    return null;
    
  }

}