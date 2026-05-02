import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconnect/app_palette.dart';
import 'package:url_launcher/url_launcher.dart';

/// Native Service screen. The Shopify page body for `/pages/services` is
/// theme-rendered (booking form + services grid are sections), so the
/// Storefront API returns nothing. We render this content natively from
/// on-store data (verified against https://iconnectqatar.com/pages/services).
class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  static const String _bookingPhone = '+97430707585';
  static const String _whatsappPhone = '97430707585';

  static const List<_Service> _services = [
    _Service(icon: Icons.phone_iphone, title: 'Display Repair'),
    _Service(icon: Icons.camera_alt_outlined, title: 'Camera Repair'),
    _Service(icon: Icons.handyman_outlined, title: 'Body Repair'),
    _Service(icon: Icons.battery_charging_full, title: 'Battery Repair'),
    _Service(icon: Icons.power_outlined, title: 'Charging Port'),
    _Service(icon: Icons.mic_none_outlined, title: 'Mic / Speaker'),
    _Service(icon: Icons.network_check, title: 'Network Issues'),
    _Service(icon: Icons.wifi, title: 'Wi-Fi Issues'),
    _Service(icon: Icons.system_update_alt, title: 'Software Issues'),
    _Service(icon: Icons.face_outlined, title: 'iPhone Face ID'),
    _Service(icon: Icons.music_note_outlined, title: 'iTunes Issues'),
    _Service(icon: Icons.sd_storage_outlined, title: 'Memory Upgrade'),
  ];

  Future<void> _launch(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.whiteColor,
      appBar: AppBar(
        title: const Text(
          'Service',
          style: TextStyle(
            color: AppPalette.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppPalette.whiteColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppPalette.blackColor),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        children: [
          _buildHero(),
          SizedBox(height: 20.h),
          _buildBookingButtons(),
          SizedBox(height: 28.h),
          Text(
            'Our Services',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: AppPalette.blackColor,
            ),
          ),
          SizedBox(height: 12.h),
          _buildServiceGrid(),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPalette.blueColor.withValues(alpha: 0.95),
            AppPalette.blueColor.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.build_circle_outlined,
            color: AppPalette.whiteColor,
            size: 32.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            'Get Your Phone Fixed',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppPalette.whiteColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Fast & reliable repair service for screen, battery, '
            'camera and more. Book a slot in seconds.',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppPalette.whiteColor.withValues(alpha: 0.92),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButtons() {
    return Row(
      children: [
        Expanded(
          child: _BookingButton(
            icon: FontAwesomeIcons.whatsapp,
            label: 'Book on WhatsApp',
            background: AppPalette.greenColor,
            foreground: AppPalette.whiteColor,
            onTap: () => _launch(Uri.parse('https://wa.me/$_whatsappPhone')),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _BookingButton(
            icon: Icons.call,
            label: 'Book by Call',
            background: AppPalette.blueColor,
            foreground: AppPalette.whiteColor,
            onTap: () => _launch(Uri.parse('tel:$_bookingPhone')),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final s = _services[index];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppPalette.whiteColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppPalette.blueColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(s.icon, color: AppPalette.blueColor, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  s.title,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.blackColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Service {
  final IconData icon;
  final String title;
  const _Service({required this.icon, required this.title});
}

class _BookingButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _BookingButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 18.sp),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
