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

  static String? validatePassword(String? password){
    if(password == null || password.isEmpty){
      return 'Please enter password';
    }
    if(password.length < 6){
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateEmail(String? email){
    if(email == null || email.isEmpty){
      return 'Please enter email';
    }
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if(!emailRegex.hasMatch(email)){
      return 'Please enter a valid email address';
    }
    return null;
  }

}