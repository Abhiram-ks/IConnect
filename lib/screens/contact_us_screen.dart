import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_button.dart';
import 'package:iconnect/common/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Native Contact Us screen. The Shopify page body for `/pages/contact` is
/// theme-rendered (sections, not the page editor body), so the Storefront API
/// returns nothing. We render this content natively from on-store data
/// (verified against https://iconnectqatar.com/pages/contact).
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  static const String _supportEmail = 'support@iconnectqatar.com';
  static const String _supportPhone = '+97470489798';
  static const String _whatsappPhone = '97470489798';

  // Image + map URLs verified against the live storefront at
  // https://iconnectqatar.com/pages/contact. Short maps.app.goo.gl links and
  // full Google Maps coordinate URLs both work cross-platform: iOS opens the
  // Google Maps app if installed, otherwise Safari (which can hand off to
  // Apple Maps); Android opens Google Maps directly.
  static const String _cdnBase = 'https://iconnectqatar.com/cdn/shop/files';
  static const String _mapsApi = 'https://www.google.com/maps/search/?api=1&query=';
  static const List<_StoreLocation> _stores = [
    _StoreLocation(
      name: 'Abu Sidra Mall',
      address: 'iConnect Abu Sidra Mall, PB. 9763, Ar-Rayyan, Qatar',
      phone: '+97471508601',
      phoneDisplay: '7150 8601',
      imageUrl: '$_cdnBase/Abu_sidra_iconnect_shop.webp',
      mapUrl: 'https://maps.app.goo.gl/Z99n4fVKJtzj7v5E8',
    ),
    _StoreLocation(
      name: 'Mall of Qatar',
      address:
          'iConnect Mall of Qatar, Rawdat Al Jahhaniya, Al Rayyan, Qatar',
      phone: '+97471508602',
      phoneDisplay: '7150 8602',
      imageUrl: '$_cdnBase/iconnect_Mall_of_Qatar_shop.webp',
      mapUrl: 'https://maps.app.goo.gl/FtsY4XdV9XLTSYZe8',
    ),
    _StoreLocation(
      name: 'Barwa Madinatna',
      address: 'iConnect Madinatna Barwa, Doha, Qatar',
      phone: '+97471508603',
      phoneDisplay: '7150 8603',
      imageUrl: '$_cdnBase/iconnect_barwa_shop.webp',
      mapUrl: 'https://maps.app.goo.gl/XuSGn8qHrAM7LZTD8',
    ),
    _StoreLocation(
      name: 'Al Khor Mall',
      address: 'iConnect Al Khor Mall, Al Khor, Qatar',
      phone: '+97471508605',
      phoneDisplay: '7150 8605',
      imageUrl: '$_cdnBase/Lulu_Alkhor_01.webp',
      mapUrl: '${_mapsApi}25.6753973,51.5020596',
    ),
    _StoreLocation(
      name: 'Lulu Center',
      address: 'iConnect Lulu Center, Ground Floor, Doha, Qatar',
      phone: '+97471508606',
      phoneDisplay: '7150 8606',
      imageUrl: '$_cdnBase/Lulu-center-qatar.webp',
      mapUrl: '${_mapsApi}25.2910245,51.5019643',
    ),
    _StoreLocation(
      name: 'Lulu D-Ring',
      address: 'iConnect Lulu D-Ring, D Ring Road, Doha, Qatar',
      phone: '+97471508607',
      phoneDisplay: '7150 8607',
      imageUrl: '$_cdnBase/Lulu-D-ring.webp',
      mapUrl: '${_mapsApi}25.2544791,51.5456046',
    ),
    _StoreLocation(
      name: 'Al Khor Mall Kiosk',
      address: 'iConnect Al Khor Mall Kiosk, Al Khor Mall, Doha, Qatar',
      phone: '+97471508608',
      phoneDisplay: '7150 8608',
      imageUrl: '$_cdnBase/Alkhor_Kiosk.webp',
      mapUrl: '${_mapsApi}25.6749269,51.5020161',
    ),
    _StoreLocation(
      name: 'Al Watan Center',
      address: 'iConnect Al Watan Center, First floor Doha, Qatar',
      phone: '+97471508615',
      phoneDisplay: '7150 8615',
      imageUrl: '$_cdnBase/iconnect_al_watan_shop.webp',
      mapUrl: 'https://maps.app.goo.gl/gfnfuF4e3AiG4dSN9',
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launch(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    // Compose a mailto: so the user's mail app sends the inquiry to support
    // without requiring a backend endpoint. Works on both Android and iOS.
    final subject = 'New inquiry from ${_nameController.text.trim()}';
    final body = StringBuffer()
      ..writeln('Name:  ${_nameController.text.trim()}')
      ..writeln('Email: ${_emailController.text.trim()}')
      ..writeln('Phone: ${_phoneController.text.trim()}')
      ..writeln()
      ..writeln('Message:')
      ..writeln(_messageController.text.trim());

    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: _encodeMailtoQuery({
        'subject': subject,
        'body': body.toString(),
      }),
    );

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (!ok) {
      CustomSnackBar.show(
        context,
        message:
            'Could not open your mail app. Please email us at $_supportEmail.',
        backgroundColor: AppPalette.redColor,
        textAlign: TextAlign.center,
      );
      return;
    }

    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _messageController.clear();

    CustomSnackBar.show(
      context,
      message:
          'Thanks! Your mail app is open with the inquiry — just hit send.',
      backgroundColor: AppPalette.greenColor,
      textAlign: TextAlign.center,
    );
  }

  /// `Uri` percent-encodes spaces as `+` in `query`, which Apple Mail / Gmail
  /// then display literally. Encoding manually avoids that.
  String _encodeMailtoQuery(Map<String, String> params) {
    return params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.whiteColor,
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(
            color: AppPalette.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppPalette.whiteColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppPalette.blackColor),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            _buildHeader(),
            SizedBox(height: 20.h),
            _buildQuickActions(),
            SizedBox(height: 28.h),
            _buildSectionTitle('Our Stores'),
            SizedBox(height: 12.h),
            ..._stores.map(_buildStoreCard),
            SizedBox(height: 24.h),
            _buildSectionTitle('Send us a message'),
            SizedBox(height: 4.h),
            Text(
              'Got a question or want to work with us? Drop a line and our '
              'team will get back to you.',
              style: TextStyle(
                fontSize: 12.5.sp,
                color: AppPalette.greyColor,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            _buildContactForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We\'d love to hear from you',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppPalette.blackColor,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Reach out for product info, support, or anything else — '
          'our team is here to help.',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppPalette.greyColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.call,
            label: 'Call',
            color: AppPalette.blueColor,
            onTap: () => _launch(Uri.parse('tel:$_supportPhone')),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _ActionTile(
            icon: FontAwesomeIcons.whatsapp,
            label: 'WhatsApp',
            color: AppPalette.greenColor,
            onTap: () => _launch(Uri.parse('https://wa.me/$_whatsappPhone')),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _ActionTile(
            icon: Icons.mail_outline,
            label: 'Email',
            color: AppPalette.orengeColor,
            onTap: () => _launch(Uri.parse('mailto:$_supportEmail')),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.bold,
        color: AppPalette.blackColor,
      ),
    );
  }

  Widget _buildStoreCard(_StoreLocation store) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: AppPalette.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStoreImage(store),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.blackColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  store.address,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: AppPalette.greyColor,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _StoreActionChip(
                      icon: Icons.call,
                      label: store.phoneDisplay,
                      color: AppPalette.blueColor,
                      onTap: () =>
                          _launch(Uri.parse('tel:${store.phone}')),
                    ),
                    SizedBox(width: 8.w),
                    _StoreActionChip(
                      icon: Icons.directions_outlined,
                      label: 'Directions',
                      color: AppPalette.greenColor,
                      onTap: () => _launch(Uri.parse(store.mapUrl)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreImage(_StoreLocation store) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: store.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: const Color(0xFFF2F2F2),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppPalette.blueColor,
                  ),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              color: const Color(0xFFF2F2F2),
              child: Center(
                child: Icon(
                  Icons.storefront_outlined,
                  color: AppPalette.greyColor,
                  size: 36.sp,
                ),
              ),
            ),
          ),
          // Tap layer for the image — opens the same map URL as the
          // Directions chip below, mirroring the storefront behaviour.
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _launch(Uri.parse(store.mapUrl)),
              ),
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12.sp,
                    color: AppPalette.whiteColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'View on map',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: AppPalette.whiteColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormField(
            controller: _nameController,
            label: 'Name',
            icon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
          ),
          SizedBox(height: 12.h),
          _FormField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'Please enter your email';
              final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
              return ok ? null : 'Enter a valid email address';
            },
          ),
          SizedBox(height: 12.h),
          _FormField(
            controller: _phoneController,
            label: 'Phone (optional)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 12.h),
          _FormField(
            controller: _messageController,
            label: 'Message',
            icon: Icons.chat_bubble_outline,
            maxLines: 5,
            validator: (v) => (v == null || v.trim().length < 10)
                ? 'Please write at least 10 characters'
                : null,
          ),
          SizedBox(height: 18.h),
          CustomButton(
            text: 'Submit',
            onPressed: _submitting ? null : _submit,
            bgColor: AppPalette.blueColor,
            borderRadius: 12,
          ),
          SizedBox(height: 8.h),
          Text(
            'Submitting opens your mail app addressed to '
            '$_supportEmail with your details pre-filled.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppPalette.greyColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreLocation {
  final String name;
  final String address;
  final String phone;
  final String phoneDisplay;
  final String imageUrl;
  final String mapUrl;

  const _StoreLocation({
    required this.name,
    required this.address,
    required this.phone,
    required this.phoneDisplay,
    required this.imageUrl,
    required this.mapUrl,
  });
}

class _StoreActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StoreActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(fontSize: 14.sp, color: AppPalette.blackColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13.sp,
          color: AppPalette.greyColor,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            left: 12.w,
            right: 8.w,
            top: maxLines > 1 ? 12.h : 0,
          ),
          child: Icon(icon, color: AppPalette.greyColor, size: 20.sp),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 14.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.blueColor, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.redColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.redColor, width: 1.2),
        ),
      ),
    );
  }
}
