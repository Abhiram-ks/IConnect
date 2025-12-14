import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_button.dart';
import 'package:iconnect/common/custom_snackbar.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:iconnect/features/auth/presentation/cubit/auth_state.dart';
import 'package:iconnect/features/profile/domain/entities/profile_entity.dart';
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
            // Load profile if not already loaded
            if (state is AuthLoginSuccess && state.profile == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<AuthCubit>().loadProfile();
              });
            } else if (state is AuthSignupSuccess && state.profile == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<AuthCubit>().loadProfile();
              });
            }

            if (state is AuthProfileLoading ||
                (state is AuthLoginSuccess && state.profile == null) ||
                (state is AuthSignupSuccess && state.profile == null)) {
              return const Center(
                child: CircularProgressIndicator(color: AppPalette.blueColor),
              );
            }

            if (state is AuthError) {
              final authState = state;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppPalette.redColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authState.message,
                      style: GoogleFonts.poppins(color: AppPalette.redColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<AuthCubit>().loadProfile(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            ProfileEntity? profile;
            if (state is AuthLoginSuccess) {
              profile = state.profile;
            } else if (state is AuthSignupSuccess) {
              profile = state.profile;
            }

            if (profile != null) {
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
                              profile.fullName.isNotEmpty
                                  ? profile.fullName[0].toUpperCase()
                                  : profile.email[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.whiteColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile.fullName,
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
                    _buildInfoCard(
                      icon: Icons.email,
                      label: 'Email',
                      value: profile.email,
                    ),
                    const SizedBox(height: 16),
                    // Phone
                    if (profile.phone != null && profile.phone!.isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: profile.phone!,
                      ),
                    if (profile.phone != null && profile.phone!.isNotEmpty)
                      const SizedBox(height: 16),
                    // Default Address
                    if (profile.defaultAddress != null)
                      _buildAddressCard(
                        label: 'Default Address',
                        address: profile.defaultAddress!,
                      ),
                    if (profile.defaultAddress != null)
                      const SizedBox(height: 32),
                    
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
                      onPressed: isLoading
                          ? null
                          : () async {
                              await context.read<AuthCubit>().logout();
                            },
                      bgColor: AppPalette.whiteColor,
                      textColor: AppPalette.blackColor,
                      borderColor: AppPalette.blackColor,
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

  Widget _buildAddressCard({
    required String label,
    required AddressEntity address,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.hintColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppPalette.blueColor),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppPalette.hintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address.fullAddress,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppPalette.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
