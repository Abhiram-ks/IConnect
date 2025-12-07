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
import '../../../../routes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../cubit/progresser_cubit/progresser_cubit.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
                body: SignupBodyWidget(
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

class SignupBodyWidget extends StatelessWidget {
  const SignupBodyWidget({
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
        child: SignupScreenBody(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
      ),
    );
  }
}

class SignupScreenBody extends StatelessWidget {
  const SignupScreenBody({
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
              SignupDetailsWidget(screenWidth: screenWidth),
              SignupPolicyWidget(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                onLoginTap: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                suffixText: "Already have an account? ",
                prefixText: "Sign in",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupPolicyWidget extends StatelessWidget {
  final Function() onLoginTap;
  final double screenWidth;
  final double screenHeight;
  final String suffixText;
  final String prefixText;

  const SignupPolicyWidget({
    super.key,
    required this.onLoginTap,
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
                  recognizer: TapGestureRecognizer()..onTap = onLoginTap,
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

class SignupDetailsWidget extends StatelessWidget {
  final double screenWidth;

  const SignupDetailsWidget({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppImages.appLogo, width: 150, height: 80),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Sign up to get started",
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
        ConstantWidgets.hight20(context),
        SignupCredential(),
        ConstantWidgets.hight10(context),
      ],
    );
  }
}

class SignupCredential extends StatefulWidget {
  const SignupCredential({super.key});

  @override
  State<SignupCredential> createState() => _SignupCredentialState();
}

class _SignupCredentialState extends State<SignupCredential> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSignupSuccess || state is AuthLoginSuccess) {
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
              TextFormFieldWidget(
                hintText: 'Enter your first name',
                label: 'First Name',
                controller: _firstNameController,
              ),
              ConstantWidgets.hight10(context),
              TextFormFieldWidget(
                hintText: 'Enter your last name',
                label: 'Last Name',
                controller: _lastNameController,
              ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                    child: Text(
                      'Confirm Password *',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    validator: _validateConfirmPassword,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(fontSize: 16),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      hintText: 'Confirm your password',
                      hintStyle: TextStyle(color: AppPalette.hintColor),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        child: Icon(
                          _obscureConfirmPassword
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
                text: isLoading ? 'Creating account...' : 'Sign Up',
                bgColor: AppPalette.whiteColor.withAlpha((0.8 * 255).round()),
                textColor: AppPalette.blueColor,
                borderColor: AppPalette.blueColor,
                onPressed:
                    isLoading
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().signup(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              firstName:
                                  _firstNameController.text.trim().isEmpty
                                      ? null
                                      : _firstNameController.text.trim(),
                              lastName:
                                  _lastNameController.text.trim().isEmpty
                                      ? null
                                      : _lastNameController.text.trim(),
                            );
                          } else {
                            CustomSnackBar.show(
                              context,
                              message: "Please fill all required fields.",
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
