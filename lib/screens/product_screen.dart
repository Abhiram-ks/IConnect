import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import '../cubit/product_screen_cubit/product_screen_cubit.dart';
// ✅ Import real Shopify data
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // Array of 4 grid images
  final List<String> gridImages = [
    'https://iconnectqatar.com/cdn/shop/files/iphone_17_5.webp?v=1762517648&width=533',
    'https://iconnectqatar.com/cdn/shop/files/ipad_new.webp?v=1762517649&width=533',
    'https://iconnectqatar.com/cdn/shop/files/Page05_4.webp?v=1762517649&width=533',
    'https://iconnectqatar.com/cdn/shop/files/iMac_4.webp?v=1762517649&width=533',
  ];

    final List<String> gridImages2 = [
    'https://iconnectqatar.com/cdn/shop/files/fold_and_flip_1.webp?v=1762518226&width=360',
    'https://iconnectqatar.com/cdn/shop/files/Page6.webp?v=1762518226&width=360',
    'https://iconnectqatar.com/cdn/shop/files/hONOR.webp?v=1762518226&width=533',
    'https://iconnectqatar.com/cdn/shop/files/Page10.webp?v=1762518226&width=533',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Load real products from Shopify on init
    context.read<ProductBloc>().add(LoadProductsRequested(first: 20));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductScreenCubit(),
      child: Scaffold(
        backgroundColor: AppPalette.whiteColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image with Error Handling
              _buildBannerImage(context, 'https://iconnectqatar.com/cdn/shop/files/main_page_updated_5.webp?v=1762517648&width=940'),
              
              ConstantWidgets.hight10(context),

              // Horizontal Scrolling Images
              SizedBox(
                height: 300.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: gridImages.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                        width: 250.w,
                        child: _buildGridImage(gridImages[index], index),
                      
                    );
                  },
                ),
              ),
              ConstantWidgets.hight50(context),
               _buildBannerImage(context, 'https://iconnectqatar.com/cdn/shop/files/ipad_new.webp?v=1762517649&width=360'),
              
              ConstantWidgets.hight10(context),

              // Horizontal Scrolling Images
              SizedBox(
                height: 300.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: gridImages.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                        width: 250.w,
                        child: _buildGridImage(gridImages2[index], index),
                      
                    );
                  },
                ),
              ),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridImage(String imageUrl, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30.w,
                  height: 30.h,
                  child: CircularProgressIndicator(
                    color: AppPalette.blueColor,
                    backgroundColor: AppPalette.hintColor,
                    strokeWidth: 2.5,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppPalette.greyColor,
                  ),
                ),
              ],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  size: 40.sp,
                  color: AppPalette.greyColor,
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'Failed to load',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppPalette.greyColor,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 20.sp,
                    color: AppPalette.blueColor,
                  ),
                  onPressed: () {
                    setState(() {});
                  },
                  tooltip: 'Retry',
                  padding: EdgeInsets.all(4.r),
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerImage(BuildContext context, String url) {
    String bannerUrl = url;
  
    return Container(
      width: double.infinity,
      height: 500.h,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Image.network(
        bannerUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          return Container(
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppPalette.blueColor,
                    backgroundColor: AppPalette.hintColor,
                    strokeWidth: 3,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Loading banner...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppPalette.greyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (loadingProgress.expectedTotalBytes != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        '${((loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)) * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppPalette.greyColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 60.sp,
                  color: AppPalette.greyColor,
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    'Failed to Load Banner',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.blackColor,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                   'Unable to load the banner image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppPalette.greyColor,
                    ),
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }

}


//   void _showSortBottomSheet(BuildContext context) {
//     final cubit = context.read<ProductScreenCubit>();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppPalette.whiteColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(1)),
//       ),
//       builder:
//           (context) => BlocProvider.value(
//             value: cubit,
//             child: SortBottomSheet(
//               currentSort: cubit.state.selectedSort,
//               sortOptions: sortOptions,
//               onSortSelected: (sort) {
//                 cubit.updateSort(sort);
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//     );
//   }

//   bool _hasActiveFilters(ProductScreenState state) {
//     return state.priceRange.start != 0 ||
//         state.priceRange.end != 14999 ||
//         state.selectedBrands.isNotEmpty ||
//         state.availabilityFilters.isNotEmpty;
//   }

//   List<Widget> _buildFilterChips(
//     BuildContext context,
//     ProductScreenState state,
//   ) {
//     List<Widget> chips = [];

//     // Price range filter
//     if (state.priceRange.start != 0 || state.priceRange.end != 14999) {
//       chips.add(
//         Chip(
//           label: Text(
//             'QAR ${state.priceRange.start.round()} - QAR ${state.priceRange.end.round()}',
//             style: TextStyle(fontSize: 12.sp),
//           ),
//           onDeleted: () {
//             context.read<ProductScreenCubit>().updateFilters(
//               priceRange: const RangeValues(0, 14999),
//             );
//           },
//           deleteIcon: Icon(Icons.close, size: 16.sp),
//         ),
//       );
//     }

//     // Brand filters
//     for (String brand in state.selectedBrands) {
//       chips.add(
//         Chip(
//           label: Text(brand, style: TextStyle(fontSize: 12.sp)),
//           onDeleted: () {
//             final newBrands = Set<String>.from(state.selectedBrands);
//             newBrands.remove(brand);
//             context.read<ProductScreenCubit>().updateFilters(
//               selectedBrands: newBrands,
//             );
//           },
//           deleteIcon: Icon(Icons.close, size: 16.sp),
//         ),
//       );
//     }

//     // Availability filters
//     for (String availability in state.availabilityFilters) {
//       chips.add(
//         Chip(
//           label: Text(availability, style: TextStyle(fontSize: 12.sp)),
//           onDeleted: () {
//             final newAvailability = Set<String>.from(state.availabilityFilters);
//             newAvailability.remove(availability);
//             context.read<ProductScreenCubit>().updateFilters(
//               availabilityFilters: newAvailability,
//             );
//           },
//           deleteIcon: Icon(Icons.close, size: 16.sp),
//         ),
//       );
//     }

//     return chips;
//   }

// class FilterDrawer extends StatefulWidget {
//   final RangeValues priceRange;
//   final Set<String> selectedBrands;
//   final Set<String> availabilityFilters;
//   final Function(RangeValues, Set<String>, Set<String>) onApplyFilters;
//   final List<String> brands;

//   const FilterDrawer({
//     super.key,
//     required this.priceRange,
//     required this.selectedBrands,
//     required this.availabilityFilters,
//     required this.onApplyFilters,
//     required this.brands,
//   });

//   @override
//   State<FilterDrawer> createState() => _FilterDrawerState();
// }

// class _FilterDrawerState extends State<FilterDrawer> {
//   late RangeValues _priceRange;
//   late Set<String> _selectedBrands;
//   late Set<String> _availabilityFilters;

//   @override
//   void initState() {
//     super.initState();
//     _priceRange = widget.priceRange;
//     _selectedBrands = Set.from(widget.selectedBrands);
//     _availabilityFilters = Set.from(widget.availabilityFilters);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: AppPalette.whiteColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Filters',
//                   style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(Icons.close, size: 20.sp),
//                 ),
//               ],
//             ),
//           ),
//           // Content
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSection(
//                     title: 'Availability',
//                     child: Column(
//                       children: [
//                         _buildCheckboxTile(
//                           'In stock',
//                           _availabilityFilters.contains('In stock'),
//                           (value) {
//                             setState(() {
//                               if (value!) {
//                                 _availabilityFilters.add('In stock');
//                               } else {
//                                 _availabilityFilters.remove('In stock');
//                               }
//                             });
//                           },
//                         ),
//                         _buildCheckboxTile(
//                           'Out of stock',
//                           _availabilityFilters.contains('Out of stock'),
//                           (value) {
//                             setState(() {
//                               if (value!) {
//                                 _availabilityFilters.add('Out of stock');
//                               } else {
//                                 _availabilityFilters.remove('Out of stock');
//                               }
//                             });
//                           },
//                         ),
//                       ],
//                       ),
//                     ),
//                    SizedBox(height: 10.h),
//                     // Price Section
//                     _buildSection(
//                     title: 'Price',
//                     child: Column(
//                       children: [
//                         RangeSlider(
//                           values: _priceRange,

//                           activeColor: AppPalette.blackColor,
//                           inactiveColor: AppPalette.hintColor,
//                           padding: EdgeInsets.zero,
//                           min: 0,
//                           max: 14999,
//                           divisions: 100,
//                           onChanged: (values) {
//                             setState(() {
//                               _priceRange = values;
//                             });
//                             },
//                           ),
//                          SizedBox(height: 8.h),
//                           Row(
//                             children: [
//                             Expanded(
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 12.w,
//                                   vertical: 8.h,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey[300]!),
//                                   borderRadius: BorderRadius.circular(8.r),
//                                 ),
//                                 child: Text('ر.ق ${_priceRange.start.round()}'),
//                               ),
//                             ),
//                             SizedBox(width: 16.w),
//                             const Text('To'),
//                             SizedBox(width: 16.w),
//                             Expanded(
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 12.w,
//                                   vertical: 8.h,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey[300]!),
//                                   borderRadius: BorderRadius.circular(8.r),
//                                 ),
//                                 child: Text('ر.ق ${_priceRange.end.round()}'),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                  SizedBox(height: 10.h),
//                   _buildSection(
//                     title: 'By Brands',
//                     child: Column(
//                       children:
//                           widget.brands.map((brand) {
//                             return _buildCheckboxTile(
//                               brand,
//                               _selectedBrands.contains(brand),
//                               (value) {
//                                 setState(() {
//                                   if (value!) {
//                                     _selectedBrands.add(brand);
//                                   } else {
//                                     _selectedBrands.remove(brand);
//                                   }
//                                 });
//                               },
//                             );
//                           }).toList(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Bottom Actions
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 4.r,
//                   offset: Offset(0, -2.h),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {
//                       setState(() {
//                         _priceRange = const RangeValues(0, 14999);
//                         _selectedBrands.clear();
//                         _availabilityFilters.clear();
//                       });
//                     },
//                     child: Text('Clear All', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppPalette.blackColor))
//                   ),
//                 ),
//                 SizedBox(width: 16.w),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       widget.onApplyFilters(
//                         _priceRange,
//                         _selectedBrands,
//                         _availabilityFilters,
//                       );
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppPalette.blackColor,
//                     ),
//                     child: Text('Apply Filters', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppPalette.whiteColor)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSection({required String title, required Widget child}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               title,
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//             ),
//             const Spacer(),
//             const Icon(Icons.keyboard_arrow_up),
//           ],
//         ),
//         SizedBox(height: 8.h),
//         child,
//       ],
//     );
//   }

//   Widget _buildCheckboxTile(
//     String title,
//     bool value,
//     Function(bool?) onChanged,
//   ) {
//     return CheckboxListTile(
//       title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
//       value: value,
//       onChanged: onChanged,
//       activeColor: AppPalette.blackColor,
//       controlAffinity: ListTileControlAffinity.leading,
//       contentPadding: EdgeInsets.zero,
//       visualDensity: VisualDensity.compact,
//       dense: true,
//     );
//   }
// }

// class SortBottomSheet extends StatelessWidget {
//   final String currentSort;
//   final List<String> sortOptions;
//   final Function(String) onSortSelected;

//   const SortBottomSheet({
//     super.key,
//     required this.currentSort,
//     required this.sortOptions,
//     required this.onSortSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.77,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Header
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Sort by',
//                   style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(CupertinoIcons.xmark_circle_fill, size: 25.sp, color: AppPalette.greyColor),
//                 ),
//               ],
//             ),
//           ),
//           // Options List
//           Flexible(
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: sortOptions.length,
//               itemBuilder: (context, index) {
//                 final option = sortOptions[index];
//                 return ListTile(
//                   contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
//                   visualDensity: VisualDensity.compact,
//                   dense: true,
//                   title: Text(option, style: TextStyle(fontSize: 16.sp,)),
//                   trailing:
//                       currentSort == option
//                           ? const Icon(
//                             Icons.check,
//                             color: AppPalette.blackColor,
//                           )
//                           : null,
//                   onTap: () => onSortSelected(option),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
