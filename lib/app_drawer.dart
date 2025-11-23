import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconnect/services/lauch_config.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_button.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/features/menu/domain/entities/menu_entity.dart';
import 'package:iconnect/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:iconnect/features/menu/presentation/cubit/menu_state.dart';
import 'package:iconnect/screens/collection_products_screen.dart';

import 'screens/register_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MenuCubit>()..loadMenu('main-menu'),
      child: Drawer(
        backgroundColor: AppPalette.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
        clipBehavior: Clip.antiAlias,
        width: 310.w,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              ConstantWidgets.hight10(context),
              Expanded(child: _buildCategoriesSection(context)),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.clear, color: AppPalette.blackColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Center(
            child: Image.asset(
              'assets/iconnect_logo.png',
              height: 25.h,
              fit: BoxFit.contain,
            ),
          ),
          ConstantWidgets.width20(context),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return BlocBuilder<MenuCubit, MenuState>(
      builder: (context, state) {
        // Loading state
        if (state.status == MenuStatus.loading) {
          return Center(
            child: CircularProgressIndicator(color: AppPalette.blueColor),
          );
        }

        // Error state
        if (state.status == MenuStatus.error) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    state.errorMessage ?? 'Failed to load menu',
                    style: TextStyle(fontSize: 14.sp, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MenuCubit>().loadMenu('main-menu');
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Loaded state
        final menu = state.menu;
        if (menu == null || menu.items.isEmpty) {
          return Center(
            child: Text(
              'No categories available',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 1.h),
            //   child: Text(
            //     'All Categories',
            //     style: TextStyle(
            //       fontSize: 16.sp,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black,
            //     ),
            //   ),
            // ),

            // Menu items from API
            ...menu.items.map(
              (menuItem) => _buildMenuItemTile(context, menuItem, 0),
            ),

            ExpansionTile(
              childrenPadding: EdgeInsets.zero,
              iconColor: AppPalette.blackColor,
              collapsedIconColor: AppPalette.blackColor,
              textColor: AppPalette.blackColor,
              collapsedTextColor: AppPalette.blackColor,
              backgroundColor: AppPalette.whiteColor,
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: AppPalette.blackColor,
              ),

              title: Text('Settings & Privacy'),
              children: [
                SettingWidget(
                  title: 'About Us',
                  icon: Icons.info_rounded,
                  onTap: () async {
                    launchConfig(
                      context: context,
                      url: 'https://iconnectqatar.com/pages/about-us',
                      message:
                          'We cannnot proceed at that moment, please try again later',
                    );
                  },
                ),
                SettingWidget(
                  title: 'Contact Us',
                  icon: Icons.contact_support,
                  onTap: () async {
                    launchConfig(
                      context: context,
                      url: 'https://iconnectqatar.com/pages/contact',
                      message:
                          'We cannnot proceed at that moment, please try again later',
                    );
                  },
                ),
                SettingWidget(
                  title: 'Terms & Conditions',
                  icon: Icons.description,
                  onTap: () async {
                    launchConfig(
                      context: context,
                      url: 'https://iconnectqatar.com/pages/terms-conditions',
                      message:
                          'We cannnot proceed at that moment, please try again later',
                    );
                  },
                ),
                SettingWidget(
                  title: 'Privacy & Policies',
                  icon: Icons.privacy_tip,
                  onTap: () async {
                    launchConfig(
                      context: context,
                      url: 'https://iconnectqatar.com/pages/privacy-policy',
                      message:
                          'We cannnot proceed at that moment, please try again later',
                    );
                  },
                ),
                SettingWidget(
                  title: 'Service',
                  icon: Icons.help,
                  onTap: () async {
                    launchConfig(
                      context: context,
                      url:
                          'https://iconnectqatar.xn--com%20%20pages%20%20services-3j6qla/',
                      message:
                          'We cannnot proceed at that moment, please try again later',
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              childrenPadding: EdgeInsets.zero,
              iconColor: AppPalette.blackColor,
              collapsedIconColor: AppPalette.blackColor,
              textColor: AppPalette.blackColor,
              collapsedTextColor: AppPalette.blackColor,
              backgroundColor: AppPalette.whiteColor,
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: AppPalette.blackColor,
              ),

              title: Text('Community & Support'),
              children: [
                SettingWidget(
                  title: 'Facebook',
                  icon: FontAwesomeIcons.facebook,
                  color: AppPalette.blueColor,
                  onTap: () async {
                    launchConfig(
                      context: context,
                      url: 'https://www.facebook.com/iconnectqataronline/',
                      message:
                          'We cannnot proceed at that moment, please try again later',
                    );
                  },
                ),
                SettingWidget(
                  title: 'Youtube',
                  icon: FontAwesomeIcons.youtube,
                  color: AppPalette.redColor,
                  onTap: () async {
                    launchConfig(
                      context: context,
                      url: 'https://www.youtube.com/@iconnectqatar',
                      message:
                          'We cannnot proceed at that moment, please try again later',
                    );
                  },
                ),
                SettingWidget(
                  title: 'Pinterest',
                  icon: FontAwesomeIcons.pinterest,
                  color: AppPalette.redColor,
                  onTap: () async {
                    launchConfig(
                      context: context,
                      url:
                          'https://www.pinterest.com/iconnect1034/?invite_code=4e6a6281f7d64e14ae64af0c180313ce&sender=1024358015152962587',
                      message:
                          'We cannnot proceed at that moment, please try again later',
                    );
                  },
                ),
                SettingWidget(
                  title: 'Instagram',
                  icon: FontAwesomeIcons.instagram,
                  color: Colors.pinkAccent,
                  onTap: () async {
                    launchConfig(
                      context: context,
                      url: 'https://www.instagram.com/iconnectqatar/',
                      message:
                          'We cannnot proceed at that moment, please try again later',
                    );
                  },
                ),
                SettingWidget(
                  title: 'Snapchat',
                  icon: FontAwesomeIcons.snapchat,
                  color: Colors.orangeAccent,
                  onTap: () async {
                    launchConfig(
                      context: context,
                      url: 'https://www.snapchat.com/@iconnectqatara',
                      message:
                          'We cannnot proceed at that moment, please try again later',
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItemTile(
    BuildContext context,
    MenuItemEntity menuItem,
    int level,
  ) {
    final hasSubItems = menuItem.items.isNotEmpty;
    final menuCubit = context.read<MenuCubit>();
    final isExpanded = menuCubit.isItemExpanded(menuItem.title);

    return Column(
      children: [
        ListTile(
          dense: true,
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          contentPadding: EdgeInsets.only(
            left: (12.0 + (level * 16.0)).w,
            right: 12.w,
            top: 3,
            bottom: 3,
          ),
          leading: null,
          title: Text(
            menuItem.title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: level == 0 ? FontWeight.w600 : FontWeight.normal,
              color: level == 0 ? Colors.black : Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing:
              hasSubItems
                  ? Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_right,
                    color: Colors.grey,
                  )
                  : null,
          onTap: () {
            if (hasSubItems) {
              menuCubit.toggleItem(menuItem.title);
            } else {
              // Navigate to collection products screen if it's a collection
              if (menuItem.isCollection && menuItem.collectionHandle != null) {
                Navigator.of(context).pop(); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CollectionProductsScreen(
                          collectionHandle: menuItem.collectionHandle!,
                          collectionTitle: menuItem.title,
                        ),
                  ),
                );
              } else {
                // For other URLs, you can handle them differently
                Navigator.of(context).pop();
                // Optionally launch URL in browser
                if (menuItem.url.isNotEmpty) {
                  launchConfig(
                    context: context,
                    url: menuItem.url,
                    message: 'Cannot open this link at the moment',
                  );
                }
              }
            }
          },
        ),

        // Sub-items
        if (isExpanded && hasSubItems)
          ...menuItem.items.map(
            (subItem) => _buildMenuItemTile(context, subItem, level + 1),
          ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Account',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          CustomButton(
            text: 'Log in',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          SizedBox(height: 5.h),
          CustomButton(
            text: 'Register',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            bgColor: AppPalette.whiteColor,
            textColor: AppPalette.blackColor,
            borderColor: AppPalette.blackColor,
          ),

          SizedBox(height: 16.h),

          // Language selector
          Row(
            children: [
              Text(
                'English',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.keyboard_arrow_down, size: 16.sp, color: Colors.grey),
            ],
          ),

          SizedBox(height: 16.h),

          // Version
          Align(
            alignment: Alignment.center,
            child: Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function() onTap;
  final Color? color;
  const SettingWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minLeadingWidth: 0,
      minVerticalPadding: 0,
      visualDensity: const VisualDensity(vertical: -4),
      leading: Icon(icon, color: color ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.normal,
          color: Colors.grey[700],
        ),
      ),
      onTap: onTap,
    );
  }
}
