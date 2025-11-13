import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconnect/common/custom_testfiled.dart';

import '../app_palette.dart';
import '../common/action_button.dart';
import '../common/custom_snackbar.dart';
import '../constant/app_images.dart';
import '../constant/constant.dart';
import '../constant/validator_helper.dart';
import '../cubit/progresser_cubit/progresser_cubit.dart';
import '../routes.dart';
import 'otp_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
        child: LoginScreenBody(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
      ),
    );
  }
}

class LoginScreenBody extends StatelessWidget {
  const LoginScreenBody({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  final double screenWidth;
  final double screenHeight;


  @override
  Widget build(BuildContext context) {
      return _buildMobileLayout(context);
    
  }

  Widget _buildMobileLayout(BuildContext context) {
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
              LoginDetailsWidget(screenWidth: screenWidth),
              LoginPolicyWidget(
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

class LoginPolicyWidget extends StatelessWidget {
  final Function() onRegisterTap;
  final double screenWidth;
  final double screenHeight;
  final String suffixText;
  final String prefixText;

  const LoginPolicyWidget({
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

class LoginDetailsWidget extends StatelessWidget {
  final double screenWidth;

  const LoginDetailsWidget({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppImages.appLogo, width: 150, height: 80),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Sign in',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
       Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Choose how you'd like to sign in",
            style: GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),
        ),
        ConstantWidgets.hight20(context),
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
           ActionButton(
            text: 'Sign in with shop',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.navigation);
            },
          ),

          ConstantWidgets.hight10(context),
          Row(
          children: const [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("Or"),
            ),
            Expanded(child: Divider()),
          ],
        ),

ConstantWidgets.hight10(context),
          TextFormFieldWidget(
            hintText: 'Your answer',
            label: 'Email address *',
            validate: ValidatorHelper.validateEmailId,
            controller: _emailController,
          ),
          ConstantWidgets.hight10(context),
          ActionButton(
            text: 'Continue',
            bgColor:  AppPalette.whiteColor.withAlpha((0.8 * 255).round()),
            textColor: AppPalette.blueColor,
            borderColor: AppPalette.blueColor,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OtpScreen()));
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