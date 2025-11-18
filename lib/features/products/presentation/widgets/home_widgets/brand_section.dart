import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/widgets/home_widgets/brand_card.dart';



class BrandSection extends StatefulWidget {
  const BrandSection({super.key});

  @override
  State<BrandSection> createState() => _BrandSectionState();
}

class _BrandSectionState extends State<BrandSection> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  double _itemExtent = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    context.read<ProductBloc>().add(LoadBrandsRequested(first: 250));
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final max = position.maxScrollExtent;
      final current = _scrollController.offset;
      final step = _itemExtent == 0 ? 108.w : _itemExtent;
      final next = current + step;
      if (next >= max) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _scrollController.animateTo(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _itemExtent = 108.w;
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _resumeAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final max = position.maxScrollExtent;
      final current = _scrollController.offset;
      final step = _itemExtent == 0 ? 108.w : _itemExtent;
      final next = current + step;
      if (next >= max) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _scrollController.animateTo(
          next,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.brands.status == Status.loading) {
          return  Center(
          child: SizedBox(
              height: 10.h,
              width: 10.w,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppPalette.blueColor,
                  strokeWidth: 2,
                ),
              ),
            ),
        );
        }
        if (state.brands.status == Status.error) {
          return SizedBox(
            height: 20.h,
            child: Center(
              child: Text(
                state.brands.message ?? 'Failed to load brands',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        if (state.brands.status == Status.completed) {
          final brands = state.brands.data ?? [];
          final brandsWithLogos =
              brands
                  .where((b) => b.imageUrl != null && b.imageUrl!.isNotEmpty)
                  .toList();

          if (brandsWithLogos.isEmpty) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            height: 30.h,
            child: GestureDetector(
              onPanDown: (_) => _stopAutoScroll(),
              onPanEnd: (_) => _resumeAutoScroll(),
              onPanCancel: () => _resumeAutoScroll(),
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: brandsWithLogos.length,
                itemBuilder: (context, index) {
                  final brand = brandsWithLogos[index];
                  return SizedBox(
                    width: 108.w,
                    child: BrandCard(
                      imageUrl: brand.imageUrl ?? '',
                      name: brand.name,
                      onTap: () {
                        _stopAutoScroll();
                        Navigator.pushNamed(
                          context,
                          '/brand_details',
                          arguments: {
                            'brandId': brand.id.hashCode,
                            'brandName': brand.name,
                            'brandVendor': brand.vendor,
                            'brandImageUrl': brand.imageUrl!,
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        }

        return Center(
          child: Center(
            child: Text('We have trouble processing your request',textAlign: TextAlign.center,style: TextStyle(fontSize: 11.sp, color: AppPalette.greyColor),),
          )
        );
      },
    );
  }
}
