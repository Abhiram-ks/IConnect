import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:iconnect/features/menu/presentation/cubit/menu_state.dart';
import 'package:iconnect/features/menu/domain/entities/menu_entity.dart';
import 'package:iconnect/features/products/domain/entities/collection_entity.dart';
import 'package:iconnect/features/products/presentation/widgets/category_card.dart';
import 'package:iconnect/screens/collection_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<ProductBloc>()),
        BlocProvider(
          create: (context) => sl<MenuCubit>()..loadMenu('main-menu'),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppPalette.whiteColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppPalette.whiteColor,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: .3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Categories',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Categories List with Sections
              Expanded(
                child: BlocBuilder<MenuCubit, MenuState>(
                  builder: (context, menuState) {
                    return BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, productState) {
                        // Load categories if not already loaded
                        if (productState.allCategories.status ==
                            Status.initial) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            context.read<ProductBloc>().add(
                              LoadAllCategoriesRequested(first: 250),
                            );
                          });
                        }

                        // Loading state
                        if (menuState.status == MenuStatus.loading ||
                            productState.allCategories.status ==
                                Status.loading) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: AppPalette.blueColor,
                                  strokeWidth: 2,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Loading categories...',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Error state
                        if (menuState.status == MenuStatus.error) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  menuState.errorMessage ??
                                      'Failed to load menu',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                TextButton(
                                  onPressed: () {
                                    context.read<MenuCubit>().loadMenu(
                                      'main-menu',
                                    );
                                  },
                                  child: Text(
                                    'Retry',
                                    style: TextStyle(
                                      color: AppPalette.blueColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Loaded state
                        final menu = menuState.menu;
                        final collections =
                            productState.allCategories.data ?? [];

                        // Create a map of collection handle to collection for quick lookup
                        final collectionMap = <String, CollectionEntity>{
                          for (var collection in collections)
                            collection.handle: collection,
                        };

                        if (menu == null || menu.items.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 48.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No categories available',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            ...menu.items.map(
                              (menuItem) => _buildMenuItemSection(
                                context,
                                menuItem,
                                collectionMap,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemSection(
    BuildContext context,
    MenuItemEntity menuItem,
    Map<String, CollectionEntity> collectionMap,
  ) {
    // Get all sub-items that are collections
    final subItems = menuItem.items.where((item) => item.isCollection).toList();

    // If no sub-items, skip this section
    if (subItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
          child: Text(
            menuItem.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.blackColor,
            ),
          ),
        ),
        // Grid of sub-items
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio:
                  0.65, // Reduced to allow more height for 2-line titles
            ),
            itemCount: subItems.length,
            itemBuilder: (context, index) {
              final subItem = subItems[index];
              // Get collection image
              String? imageUrl;
              if (subItem.collectionHandle != null) {
                final collection = collectionMap[subItem.collectionHandle];
                if (collection != null) {
                  imageUrl = collection.imageUrl;
                }
              }

              return CategoryCard(
                imageUrl: imageUrl ?? '',
                title: subItem.title,
                onTap: () {
                  if (subItem.isCollection &&
                      subItem.collectionHandle != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CollectionProductsScreen(
                              collectionHandle: subItem.collectionHandle!,
                              collectionTitle: subItem.title,
                            ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
