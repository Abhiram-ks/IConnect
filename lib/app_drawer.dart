
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_button.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/cubit/category_cubit/category_cubit.dart';
import 'package:iconnect/models/category.dart';

import 'screens/register_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryCubit(),
      child: Drawer(
        backgroundColor: AppPalette.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
        clipBehavior: Clip.antiAlias,
        width: 270.w,
        child: SafeArea(
          child: Column(
            children: [
              // Header with logo and close button
              _buildHeader(context),
              ConstantWidgets.hight10(context),
              
              // Categories section
              Expanded(
                child: _buildCategoriesSection(context),
              ),

              // Footer with logout and version
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
            icon:  Icon(CupertinoIcons.clear, color: AppPalette.blackColor),
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
    return BlocBuilder<CategoryCubit, List<Category>>(
      builder: (context, categories) {
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // All Categories header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 1.h),
              child: Text(
                'All Categories',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            
            ...categories.map((category) => _buildCategoryTile(context, category, 0)),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category, int level) {
    final hasSubcategories = category.subcategories != null && category.subcategories!.isNotEmpty;
    
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
            category.name,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: level == 0 ? FontWeight.w600 : FontWeight.normal,
              color: level == 0 ? Colors.black : Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: hasSubcategories
            ? Icon(
                category.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right,
                color: Colors.grey,
              )
            : null,
          onTap: () {
            if (hasSubcategories) {
              context.read<CategoryCubit>().toggleCategory(category.id);
            } else {
              Navigator.of(context).pop();
              // TODO: Navigate to category products screen
            }
          },
        ),
        
        // Subcategories
        if (category.isExpanded && hasSubcategories)
          ...category.subcategories!.map((subcategory) => 
            _buildCategoryTile(context, subcategory, level + 1)
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
          ),     CustomButton(text: 'Log in', onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              }),
              SizedBox(height:5.h),
             CustomButton(text: 'Register', onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              }, bgColor: AppPalette.whiteColor, textColor: AppPalette.blackColor,borderColor: AppPalette.blackColor),
          
          SizedBox(height: 16.h),
          
          // Language selector
          Row(
            children: [
              Text(
                'English',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16.sp,
                color: Colors.grey,
              ),
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
