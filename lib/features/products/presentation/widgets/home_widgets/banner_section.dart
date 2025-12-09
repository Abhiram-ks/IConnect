import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/features/products/presentation/widgets/image_scrolling_widget.dart';
import 'package:iconnect/cubit/image_slider_cubit/image_slider_cubit.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/screens/collection_products_screen.dart';
import 'package:iconnect/core/utils/api_response.dart' show Status;

class BannerSection extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  const BannerSection({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  /// Navigate to collection using banner handle and title
  void _navigateToCollection(
    BuildContext context,
    String handle,
    String? title,
  ) {
    if (handle.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CollectionProductsScreen(
              collectionHandle: handle,
              collectionTitle: title ?? '',
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Load banners if not already loaded
        if (state.homeBanners.status == Status.initial) {
          context.read<ProductBloc>().add(LoadHomeBannersRequested(first: 10));
        }

        // Show loading state
        if (state.homeBanners.status == Status.loading) {
          return SizedBox(
            height: screenHeight * 0.3,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Show error state
        if (state.homeBanners.status == Status.error) {
          return const SizedBox.shrink();
        }

        // Get banners from state
        final banners = state.homeBanners.data ?? [];

        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }

        // Get image URLs from banners
        final bannerImages =
            banners
                .where((banner) => banner.imageUrl != null)
                .map((banner) => banner.imageUrl!)
                .toList();

        if (bannerImages.isEmpty) {
          return const SizedBox.shrink();
        }

        return BlocProvider(
          create: (context) => ImageSliderCubit(imageList: bannerImages),
          child: Builder(
            builder: (context) {
              return BlocBuilder<ImageSliderCubit, int>(
                builder: (context, currentIndex) {
                  return GestureDetector(
                    onTap: () {
                      if (currentIndex < banners.length) {
                        final currentBanner = banners[currentIndex];
                        _navigateToCollection(
                          context,
                          currentBanner.handle,
                          currentBanner.title,
                        );
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
      },
    );
  }
}
