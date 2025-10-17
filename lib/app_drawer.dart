
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/cubit/category_cubit/category_cubit.dart';
import 'package:iconnect/models/category.dart';

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
        width: 270,
        child: SafeArea(
          child: Column(
            children: [
              // Header with logo and close button
              _buildHeader(context),
              ConstantWidgets.hight20(context),
              
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
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'All Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            
            // Categories list
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
          contentPadding: EdgeInsets.only(
            left: 16.0 + (level * 20.0),
            right: 16.0,
            top: 4.0,
            bottom: 4.0,
          ),
          leading: null,
          title: Text(
            category.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: level == 0 ? FontWeight.w600 : FontWeight.normal,
              color: level == 0 ? Colors.black : Colors.grey[700],
            ),
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
              // Navigate to category products
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // My Account section
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          // Login and Register buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to login screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Log in'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to register screen
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Language selector
          Row(
            children: [
              const Text(
                'English',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Version
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
