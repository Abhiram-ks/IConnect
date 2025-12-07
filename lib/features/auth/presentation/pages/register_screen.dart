import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconnect/common/custom_testfiled.dart';

import '../../../../app_palette.dart';
import '../../../../common/action_button.dart';
import '../../../../common/custom_snackbar.dart';
import '../../../../constant/app_images.dart';
import '../../../../constant/constant.dart';
import '../../../../constant/validator_helper.dart';
import '../../../../cubit/progresser_cubit/progresser_cubit.dart';
import '../../../../routes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../core/di/service_locator.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProgresserCubit()),
        BlocProvider.value(value: sl<AuthCubit>()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return ColoredBox(
            color: AppPalette.buttonColor,
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
                  Navigator.pushNamed(context, AppRoutes.signup);
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
        Center(
          child: RichText(
            text: TextSpan(
              text: suffixText,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              children: [
                TextSpan(
                  text: prefixText,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onRegisterTap,
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
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: Text(
        //     "Choose how you'd like to sign in",
        //     style: GoogleFonts.poppins(fontSize: 13),
        //   ),
        // ),
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
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.navigation,
            (route) => false,
          );
        } else if (state is AuthError) {
          CustomSnackBar.show(
            context,
            message: state.message,
            textAlign: TextAlign.center,
            backgroundColor: AppPalette.redColor,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // ActionButton(
              //   text: 'Sign in with shop',
              //   onPressed: () {
              //     Navigator.pushNamed(context, AppRoutes.navigation);
              //   },
              // ),
              // ConstantWidgets.hight10(context),
              // Row(
              //   children: const [
              //     Expanded(child: Divider()),
              //     Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 8.0),
              //       child: Text("Or"),
              //     ),
              //     Expanded(child: Divider()),
              //   ],
              // ),
              ConstantWidgets.hight10(context),
              TextFormFieldWidget(
                hintText: 'Enter your email',
                label: 'Email address *',
                validate: ValidatorHelper.validateEmail,
                controller: _emailController,
              ),
              ConstantWidgets.hight10(context),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                    child: Text(
                      'Password *',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    validator: ValidatorHelper.validatePassword,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 16),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: AppPalette.hintColor),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppPalette.hintColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppPalette.hintColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppPalette.blueColor,
                          width: 1,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppPalette.redColor,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppPalette.redColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  ConstantWidgets.hight10(context),
                ],
              ),
              ActionButton(
                text: isLoading ? 'Signing in...' : 'Continue',
                bgColor: AppPalette.whiteColor.withAlpha((0.8 * 255).round()),
                textColor: AppPalette.blueColor,
                borderColor: AppPalette.blueColor,
                onPressed:
                    isLoading
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
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
      },
    );
  }
}
