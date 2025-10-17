import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../constant/app_images.dart';
import '../cubit/image_slider_cubit/image_slider_cubit.dart';
import '../cubit/brand_scroll_cubit/brand_scroll_cubit.dart';
import '../widgets/brand_card.dart';
import '../widgets/product_tab_bar.dart';
import '../widgets/new_arrivals_section.dart';
import '../data/brand_data.dart';

// Reusable Category Card Widget
class CategoryCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppPalette.blueColor.withValues(alpha: 0.1),
                  AppPalette.greenColor.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppPalette.blueColor,
                      strokeWidth: 2,
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    CupertinoIcons.photo,
                    color: AppPalette.greyColor,
                    size: 30,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Categories map with 6 items
  static const List<Map<String, String>> categories = [
    {
      'title': 'iMac',
      'imageUrl':
          'https://images.unsplash.com/photo-1527864550417-7f91a4d4d85d?w=150&h=150&fit=crop&crop=center',
    },
    {
      'title': 'Games',
      'imageUrl':
          'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=150&h=150&fit=crop&crop=center',
    },
    {
      'title': 'Headphones',
      'imageUrl':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=150&h=150&fit=crop&crop=center',
    },
    {
      'title': 'Speaker',
      'imageUrl':
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=150&h=150&fit=crop&crop=center',
    },
    {
      'title': 'Airpods',
      'imageUrl':
          'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=150&h=150&fit=crop&crop=center',
    },
    {
      'title': 'Laptop',
      'imageUrl':
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=150&h=150&fit=crop&crop=center',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        return Scaffold(
          backgroundColor: AppPalette.whiteColor,
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                ImageScolingWidget(
                  imageList: [
                    'https://static.vecteezy.com/system/resources/previews/020/737/706/non_2x/web-banner-or-horizontal-template-design-with-special-offer-on-mobile-phones-for-advertising-concept-vector.jpg',
                    'https://tse4.mm.bing.net/th/id/OIP.yVGDg2ygsSNXfoA1pLwVNAHaEK?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3',
                    'https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/77f7c336776659.5728f30441a89.jpg',
                  ],
                  screenHeight: height,
                  screenWidth: width,
                  show: true,
                ),

                ConstantWidgets.hight10(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: CategoryCard(
                                imageUrl: categories[index]['imageUrl']!,
                                title: categories[index]['title']!,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${categories[index]['title']} tapped!',
                                      ),
                                      backgroundColor: AppPalette.blackColor,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      BlocProvider(
                        create:
                            (context) =>
                                BrandScrollCubit(brandList: BrandData.brands),
                        child: SizedBox(
                          height: 30,
                          child: BlocBuilder<BrandScrollCubit, int>(
                            builder: (context, state) {
                              final cubit = context.read<BrandScrollCubit>();
                              return NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if (notification
                                      is ScrollUpdateNotification) {
                                    cubit.updateScrollPosition(
                                      notification.metrics.pixels,
                                    );
                                  }
                                  return false;
                                },
                                child: ListView.builder(
                                  controller: cubit.scrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: BrandData.brands.length,
                                  itemBuilder: (context, index) {
                                    final brand = BrandData.brands[index];
                                    return BrandCard(
                                      imageUrl: brand['imageUrl'],
                                      onTap: () {},
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Product Tab Section
                      ConstantWidgets.hight10(context),
                      ProductTabBar(
                        categories: ProductCategoryData.getCategories(),
                        height: 300,
                      ),

                      // New Arrivals Section
                      ConstantWidgets.hight10(context),
                      NewArrivalsSection(
                        title: 'New Arrivals',
                        products: NewArrivalsData.getNewArrivalsProducts(),
                        onViewAll: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Viewing all new arrivals!'),
                              backgroundColor: AppPalette.blueColor,
                            ),
                          );
                        },
                      ),

                      // Service Banners Section
                      ConstantWidgets.hight10(context),
                      ServiceBanner(
                        title: 'SMARTPHONES DISPLAY REPAIR',
                        imageUrl:
                            'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&h=120&fit=crop&crop=center',
                        buttonText: 'View All Services',
                        isMainBanner: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening repair services!'),
                              backgroundColor: AppPalette.greenColor,
                            ),
                          );
                        },
                      ),

                      ServiceBanner(
                        title: 'Repair Services',
                        subtitle: 'Professional Electronic Repair',
                        imageUrl:
                            'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&h=120&fit=crop&crop=center',
                        buttonText: 'View All Services',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening all services!'),
                              backgroundColor: AppPalette.blueColor,
                            ),
                          );
                        },
                      ),
                      NewArrivalsSection(
                        title: 'Fold and Flip Phones',
                        products: NewArrivalsData.getNewArrivalsProducts(),
                        onViewAll: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Viewing all new arrivals!'),
                              backgroundColor: AppPalette.blueColor,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 64),
                    ],
                  ),
                ), // Brands Section with Cubit Management
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: AppPalette.greenColor,
            child: Icon(
              FontAwesomeIcons.whatsapp,
              color: Colors.white,
              size: 30,
            ),
          ),
        );
      },
    );
  }
}

class ImageScolingWidget extends StatelessWidget {
  const ImageScolingWidget({
    super.key,
    required this.imageList,
    required this.screenHeight,
    required this.screenWidth,
    required this.show,
  });

  final List<String> imageList;
  final double screenHeight;
  final double screenWidth;
  final bool show;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImageSliderCubit(imageList: imageList),
      child: Builder(
        builder: (context) {
          final cubit = context.read<ImageSliderCubit>();
          return SizedBox(
            height: screenHeight * 0.3,
            width: screenWidth,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: cubit.pageController,
                  itemCount: imageList.length,
                  onPageChanged: cubit.updatePage,
                  itemBuilder: (context, index) {
                    return (imageList[index].startsWith('http'))
                        ? imageshow(
                          imageUrl: imageList[index],
                          imageAsset: imageList[index],
                        )
                        : Image.asset(
                          AppImages.demmyImage,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        );
                  },
                ),
                Positioned(
                  bottom: 8,
                  child: BlocBuilder<ImageSliderCubit, int>(
                    builder: (context, state) {
                      return SmoothPageIndicator(
                        controller: cubit.pageController,
                        count: imageList.length,
                        effect: const ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: AppPalette.whiteColor,
                          dotColor: AppPalette.greyColor,
                        ),
                      );
                    },
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

Image imageshow({required String imageUrl, required String imageAsset}) {
  return Image.network(
    imageUrl,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          color: AppPalette.blueColor,
          backgroundColor: AppPalette.hintColor,
          value:
              loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return Image.asset(imageAsset, fit: BoxFit.cover);
    },
  );
}
