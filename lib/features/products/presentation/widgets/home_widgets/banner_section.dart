import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/features/products/presentation/widgets/image_scrolling_widget.dart';
import 'package:iconnect/features/products/data/models/banner_data.dart';
import 'package:iconnect/cubit/image_slider_cubit/image_slider_cubit.dart';
import 'package:iconnect/screens/collection_products_screen.dart';
import 'package:iconnect/screens/search_screen.dart';
import 'package:iconnect/services/lauch_config.dart';

class BannerSection extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  const BannerSection({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  /// Navigate based on banner link/URL
  void _navigateFromBannerLink(BuildContext context, String? link) {
    if (link == null || link.trim().isEmpty) {
      return;
    }

    // Remove leading slash if present
    final cleanLink = link.startsWith('/') ? link.substring(1) : link;

    // Handle different URL types
    if (cleanLink.startsWith('products/')) {
      // Extract product handle from URL (e.g., "products/sony-playstation-ps5-digital-825gb-with-ea-sports-fc-26-bundle")
      final productHandle = cleanLink.replaceFirst('products/', '');
      Navigator.pushNamed(
        context,
        '/product_details',
        arguments: {'productHandle': productHandle},
      );
    } else if (cleanLink.startsWith('collections/')) {
      // Extract collection handle from URL (e.g., "collections/one-plus-15-price-in-qatar")
      final parts = cleanLink.replaceFirst('collections/', '').split('?');
      final collectionHandle = parts[0];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CollectionProductsScreen(
                collectionHandle: collectionHandle,
                collectionTitle: '', // Title can be fetched if needed
              ),
        ),
      );
    } else if (cleanLink.startsWith('pages/')) {
      // Handle pages - open in browser as pages might be web-only content
      launchConfig(
        context: context,
        url: link.startsWith('http') ? link : 'https://iconnectqatar.com/$link',
        message: 'Cannot open this page at the moment',
      );
    } else if (cleanLink.startsWith('search')) {
      // Handle search URLs (e.g., "search?q=motorola+edge+70" or "search?options[...]&q=motorola+edge+70")
      final uri = Uri.parse(
        link.startsWith('http') ? link : 'https://iconnectqatar.com/$link',
      );
      final queryParams = uri.queryParameters;
      // Extract search query - handle both 'q' and URL-encoded query parameters
      var searchQuery = queryParams['q'] ?? queryParams['query'] ?? '';

      // Decode URL-encoded query (e.g., "motorola+edge+70" -> "motorola edge 70")
      if (searchQuery.isNotEmpty) {
        searchQuery = Uri.decodeComponent(searchQuery);
      }

      // Navigate to search screen
      // Note: SearchScreen would need to accept an initial query parameter
      // For now, just open the search screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    } else {
      // For other URLs or external links, open in browser
      final fullUrl =
          link.startsWith('http') ? link : 'https://iconnectqatar.com/$link';
      launchConfig(
        context: context,
        url: fullUrl,
        message: 'Cannot open this link at the moment',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use static banner data from BannerDataSource instead of API
    final bannerDataList = BannerDataSource.getBanners();

    if (bannerDataList.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get image URLs (use mobile images on smaller screens)
    final bannerImages =
        bannerDataList.map((banner) {
          // Use mobile images if screen width is less than 768px (mobile breakpoint)
          if (screenWidth < 768 && banner.mobileImageUrl != null) {
            return banner.mobileImageUrl!;
          }
          return banner.imageUrl;
        }).toList();

    return BlocProvider(
      create: (context) => ImageSliderCubit(imageList: bannerImages),
      child: Builder(
        builder: (context) {
          return BlocBuilder<ImageSliderCubit, int>(
            builder: (context, currentIndex) {
              return GestureDetector(
                onTap: () {
                  if (currentIndex < bannerDataList.length) {
                    final currentBanner = bannerDataList[currentIndex];
                    _navigateFromBannerLink(context, currentBanner.link);
                  }
                },
                child: ImageScrollingWidget(
                  imageList: bannerImages,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  show: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
