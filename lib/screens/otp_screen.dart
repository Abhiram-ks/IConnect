import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_snackbar.dart';
import 'package:iconnect/constant/validator_helper.dart';
import 'package:iconnect/cubit/progresser_cubit/progresser_cubit.dart';
import 'package:iconnect/routes.dart';

import '../common/action_button.dart';
import '../common/custom_testfiled.dart';
import '../constant/app_images.dart';
import '../constant/constant.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProgresserCubit()),
      ],
      child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;
            
            return ColoredBox(
              color:  AppPalette.buttonColor,
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: AppPalette.whiteColor,
                  resizeToAvoidBottomInset: false,
                  body: LoginBodyWidget(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ),
              ),
            );
          },
        ),
    );
  }
}

class LoginBodyWidget extends StatelessWidget {
  const LoginBodyWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: OtpScreenBody(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
      ),
    );
  }
}

class OtpScreenBody extends StatelessWidget {
  const OtpScreenBody({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  final double screenWidth;
  final double screenHeight;


  @override
  Widget build(BuildContext context) {
      return _buildOtpLayout(context);
    
  }

  Widget _buildOtpLayout(BuildContext context) {
    return Center(
      child: Container(
        width: screenWidth * 0.87,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AppPalette.whiteColor.withAlpha((0.8 * 255).round()),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppPalette.blackColor.withAlpha((0.1 * 255).round()),
              blurRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OtpDetailsWidget(screenWidth: screenWidth),
              OtpPolicyWidget(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                onRegisterTap: () {
                  
                },
                suffixText: "Don't have an account? ",
                prefixText: "Register",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpPolicyWidget extends StatelessWidget {
  final Function() onRegisterTap;
  final double screenWidth;
  final double screenHeight;
  final String suffixText;
  final String prefixText;

  const OtpPolicyWidget({
    super.key,
    required this.onRegisterTap,
    required this.screenWidth,
    required this.screenHeight,
    required this.suffixText,
    required this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sign in with a different email',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13, 
                color: AppPalette.blueColor, 
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline,
                
              ),
            ),
          ),
        ),
        ConstantWidgets.hight10(context),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text:
                  "By creating or logging into an account you are agreeing with our ",
              style: const TextStyle(fontSize: 12, color: Colors.black54),

              children: [
                TextSpan(
                  text: "Terms and Conditions",
                  style: TextStyle(color: Colors.blue[700]),
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy Policy",
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ),
        ConstantWidgets.hight10(context),
      ],
    );
  }
}

class OtpDetailsWidget extends StatelessWidget {
  final double screenWidth;

  const OtpDetailsWidget({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppImages.appLogo, width: 150, height: 80),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Enter code',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
       Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Sent to code given email address",
            style: GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),
        ),
        LoginCredential(),

        ConstantWidgets.hight10(context),
      ],
    );
  }
}



class LoginCredential extends StatefulWidget {
  const LoginCredential({super.key});

  @override
  State<LoginCredential> createState() => _LoginCredentialState();
}

class _LoginCredentialState extends State<LoginCredential> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [

          ConstantWidgets.hight10(context),

ConstantWidgets.hight10(context),
          TextFormFieldWidget(
            hintText: '6 - Digit Code',
            label: 'Email OTP *',
            validate: ValidatorHelper.validateOtp,
            controller: _emailController,
          ),
          ConstantWidgets.hight10(context),
          ActionButton(
            text: 'Submit',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                 Navigator.pushNamed(context, AppRoutes.navigation);
              } else {
                CustomSnackBar.show(
                  context,
                  message: "All fields are required.",
                  textAlign: TextAlign.center,
                  backgroundColor: AppPalette.redColor,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}