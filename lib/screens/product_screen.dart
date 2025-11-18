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
