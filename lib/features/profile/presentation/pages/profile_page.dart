import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_button.dart';
import 'package:iconnect/common/custom_snackbar.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/core/storage/local_storage_service.dart';
import 'package:iconnect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:iconnect/features/auth/presentation/cubit/auth_state.dart';
import 'package:iconnect/routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: AppPalette.whiteColor,
        appBar: AppBar(
          backgroundColor: AppPalette.whiteColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppPalette.blackColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'My Profile',
            style: GoogleFonts.poppins(
              color: AppPalette.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              CustomSnackBar.show(
                context,
                message: state.message,
                textAlign: TextAlign.center,
                backgroundColor: AppPalette.redColor,
              );
            }
            // Navigate back to login after logout
            if (state is AuthInitial) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            // Read user data directly from local storage.
            final email = LocalStorageService.email ?? '';
            final displayName = LocalStorageService.displayName;
            final isLoggedIn = LocalStorageService.isLoggedIn;

            if (!isLoggedIn || (state is! AuthLoginSuccess && state is! AuthSignupSuccess)) {
              return const SizedBox.shrink();
            }

            {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppPalette.blueColor,
                            child: Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : (email.isNotEmpty ? email[0].toUpperCase() : '?'),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.whiteColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppPalette.blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Email
                    if (email.isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.email,
                        label: 'Email',
                        value: email,
                      ),
                    if (email.isNotEmpty) const SizedBox(height: 16),

                    // Action Buttons Section
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'My Orders',
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.orders);
                      },
                    ),
                    SizedBox(height: 12.h),
                    CustomButton(
                      text: isLoading ? 'Logging out...' : 'Log out',
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                await context.read<AuthCubit>().logout();
                              },
                      bgColor: AppPalette.whiteColor,
                      textColor: AppPalette.blackColor,
                      borderColor: AppPalette.blackColor,
                    ),
                    SizedBox(height: 12.h),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          final authCubit = context.read<AuthCubit>();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return BlocProvider.value(
                                value: authCubit,
                                child: BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    final isDeleting = state is AuthLoading;
                                    return AlertDialog(
                                      backgroundColor: AppPalette.whiteColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: Text(
                                        'Delete Account',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18.sp,
                                          color: AppPalette.blackColor,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to delete your account?\nYour account will be permanently deleted within 30 days. If you log in again during this period, your account will be restored.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          height: 1.5,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.poppins(
                                              color: AppPalette.greyColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed:
                                              isDeleting
                                                  ? null
                                                  : () async{
                                                    context
                                                        .read<AuthCubit>()
                                                        .logout();

                                                        await Future.delayed(const Duration(seconds: 2));
                                                       if(context.mounted && Navigator.canPop(context)){
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                       }
                                                  },
                                          child:
                                              isDeleting
                                                  ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color:
                                                              AppPalette
                                                                  .redColor,
                                                        ),
                                                  )
                                                  : Text(
                                                    'Delete',
                                                    style: GoogleFonts.poppins(
                                                      color:
                                                          AppPalette.redColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Do you want to ',
                            style: GoogleFonts.poppins(
                              color: AppPalette.blackColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: 'delete account?',
                                style: GoogleFonts.poppins(
                                  color: AppPalette.redColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.hintColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppPalette.blueColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppPalette.hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.blackColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
