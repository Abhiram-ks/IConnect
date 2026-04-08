import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconnect/common/custom_testfiled.dart';

import '../../../../app_palette.dart';
import '../../../../common/custom_snackbar.dart';
import '../../../../constant/app_images.dart';
import '../../../../constant/constant.dart';
import '../../../../constant/validator_helper.dart';
import '../../../../cubit/progresser_cubit/progresser_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProgresserCubit()),
        BlocProvider.value(value: sl<AuthCubit>()),
      ],
      child: ColoredBox(
        color: AppPalette.buttonColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: AppPalette.whiteColor,
            resizeToAvoidBottomInset: true,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: const _ForgotPasswordBody(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordBody extends StatelessWidget {
  const _ForgotPasswordBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: constraints.maxWidth * 0.87,
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
              child: const _ForgotPasswordContent(),
            ),
          ),
        );
      },
    );
  }
}

class _ForgotPasswordContent extends StatefulWidget {
  const _ForgotPasswordContent();

  @override
  State<_ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<_ForgotPasswordContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<ProgresserCubit>().startLoading();
      context.read<AuthCubit>().forgotPassword(
        email: _emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthForgotPasswordEmailSent) {
          context.read<ProgresserCubit>().stopLoading();
          _showForgotPasswordInfoDialog(context, state.email);
        } else if (state is AuthError) {
          context.read<ProgresserCubit>().stopLoading();
          CustomSnackBar.show(
            context,
            message: state.message,
            textAlign: TextAlign.center,
            backgroundColor: AppPalette.redColor,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthForgotPasswordLoading;

        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(AppImages.appLogo, width: 150, height: 80),
              ),
              Text(
                'Forgot Password',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ConstantWidgets.hight10(context),
              Text(
                'Enter your email. If an account exists, you will receive a reset link. If not, please sign up.',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
              ),
              ConstantWidgets.hight20(context),
              TextFormFieldWidget(
                hintText: 'Enter your email',
                label: 'Email address *',
                validate: ValidatorHelper.validateEmail,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              ConstantWidgets.hight10(context),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.whiteColor.withAlpha(
                      (0.8 * 255).round(),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                      side: const BorderSide(color: AppPalette.blueColor),
                    ),
                  ),
                  onPressed: isLoading ? null : () => _submit(context),
                  child:
                      isLoading
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppPalette.blueColor,
                                  strokeWidth: 2.5,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Sending...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppPalette.blueColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                          : const Text(
                            'Send Reset Link',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppPalette.blueColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              ConstantWidgets.hight10(context),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Sign in',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppPalette.blueColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showForgotPasswordInfoDialog(BuildContext context, String email) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                color: Colors.blue.shade700,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Next steps',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'If an account is registered for $email, you will receive an email with a link to reset your password. Check your inbox and spam folder.\n\nIf no email arrives, there may be no account for this address — please sign up to create one.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black54,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
