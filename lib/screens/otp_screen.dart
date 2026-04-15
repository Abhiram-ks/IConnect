import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_snackbar.dart';
import 'package:iconnect/common/policy_bottom_sheet.dart';
import 'package:iconnect/cubit/progresser_cubit/progresser_cubit.dart';
import 'package:iconnect/routes.dart';
import 'package:iconnect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:iconnect/features/auth/presentation/cubit/auth_state.dart';

import '../common/action_button.dart';
import '../constant/app_images.dart';
import '../constant/constant.dart';

class OtpScreen extends StatelessWidget {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  const OtpScreen({
    super.key,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

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
            color: AppPalette.buttonColor,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: AppPalette.whiteColor,
                resizeToAvoidBottomInset: false,
                body: OtpBodyWidget(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  email: email,
                  password: password,
                  firstName: firstName,
                  lastName: lastName,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OtpBodyWidget extends StatelessWidget {
  const OtpBodyWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  final double screenWidth;
  final double screenHeight;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: OtpScreenBody(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
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
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  final double screenWidth;
  final double screenHeight;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

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
              OtpDetailsWidget(
                screenWidth: screenWidth,
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName,
              ),
              OtpPolicyWidget(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpPolicyWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const OtpPolicyWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
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
              'Sign up with a different email',
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
                  style: TextStyle(
                    color: Colors.blue[700],
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      PolicyBottomSheet.showTermsAndConditions(context);
                    },
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy Policy",
                  style: TextStyle(
                    color: Colors.blue[700],
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      PolicyBottomSheet.showPrivacyPolicy(context);
                    },
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
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  const OtpDetailsWidget({
    super.key,
    required this.screenWidth,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppImages.appLogo, width: 150, height: 80),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Verify Your Email',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ConstantWidgets.hight10(context),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "We've sent a verification link to:",
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            email,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppPalette.blueColor,
            ),
          ),
        ),
        ConstantWidgets.hight10(context),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppPalette.blueColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppPalette.blueColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppPalette.blueColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Next Steps:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.blueColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '1. Check your email inbox or spam folder\n'
                '2. Click the verification link\n'
                '3. Return here and click "I\'ve Verified"',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        ConstantWidgets.hight10(context),
        OtpCredential(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        ),
        ConstantWidgets.hight10(context),
      ],
    );
  }
}

class OtpCredential extends StatefulWidget {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  const OtpCredential({
    super.key,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  @override
  State<OtpCredential> createState() => _OtpCredentialState();
}

class _OtpCredentialState extends State<OtpCredential> {
  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _handleResendEmail(BuildContext context) {
    if (_canResend) {
      context.read<AuthCubit>().resendVerificationEmail(
            widget.email,
            widget.password,
          );
      _startResendTimer();
    }
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
          if (state.message.contains('resent successfully') ||
              state.message.contains('already verified')) {
            CustomSnackBar.show(
              context,
              message: state.message,
              textAlign: TextAlign.center,
              backgroundColor: AppPalette.greenColor,
            );
          } else {
            CustomSnackBar.show(
              context,
              message: state.message,
              textAlign: TextAlign.center,
              backgroundColor: AppPalette.redColor,
            );
          }
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AuthLoading || state is AuthOtpVerificationLoading;

        return Column(
          children: [
            ActionButton(
              text: isLoading ? 'Verifying...' : "I've Verified My Email",
              bgColor: AppPalette.blueColor,
              textColor: AppPalette.whiteColor,
              borderColor: AppPalette.blueColor,
              onPressed: isLoading
                  ? null
                  : () {
                      context.read<AuthCubit>().verifyEmailAndSignup(
                            email: widget.email,
                            password: widget.password,
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                          );
                    },
            ),
            ConstantWidgets.hight10(context),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: _canResend
                      ? "Didn't receive the email? "
                      : "Resend email in $_resendCountdown seconds",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  children: _canResend
                      ? [
                          TextSpan(
                            text: "Resend",
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _handleResendEmail(context),
                          ),
                        ]
                      : [],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
