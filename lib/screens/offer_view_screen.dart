import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/domain/entities/offer_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart'
    as products;
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/routes.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';
import 'package:iconnect/widgets/shopify_product_grid_section.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class OfferViewScreen extends StatefulWidget {
  const OfferViewScreen({super.key});

  @override
  State<OfferViewScreen> createState() => _OfferViewScreenState();
}

class _OfferViewScreenState extends State<OfferViewScreen> {
  final Map<String, PdfViewerController> _pdfControllers = {};
  final Map<String, int> _currentPages = {};
  final Map<String, int> _totalPages = {};
  final Map<String, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    context.read<products.ProductBloc>().add(LoadOfferBlocksRequested());
  }

  @override
  void dispose() {
    for (var controller in _pdfControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  PdfViewerController _getController(String offerId) {
    if (!_pdfControllers.containsKey(offerId)) {
      _pdfControllers[offerId] = PdfViewerController();
      _currentPages[offerId] = 1;
      _totalPages[offerId] = 0;
      _loadingStates[offerId] = true;
    }
    return _pdfControllers[offerId]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          BlocBuilder<products.ProductBloc, products.ProductState>(
            builder: (context, state) {
              if (state.offerBlocks.status == Status.loading) {
                return Center(
                  child: CircularProgressIndicator(color: AppPalette.blueColor),
                );
              }

              if (state.offerBlocks.status == Status.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppPalette.redColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error loading offers',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        state.offerBlocks.message ?? 'Unknown error',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<products.ProductBloc>().add(
                            LoadOfferBlocksRequested(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.blueColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state.offerBlocks.status == Status.completed) {
                final offerBlocks = state.offerBlocks.data ?? [];

                if (offerBlocks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No offers available',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Check back later for new offers',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: offerBlocks.length,
                  itemBuilder: (context, index) {
                    final offerBlock = offerBlocks[index];
                    return _KeepAliveOfferBlock(
                      key: ValueKey(offerBlock.id),
                      offerBlock: offerBlock,
                      buildOfferBlock: _buildOfferBlock,
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
          const WhatsAppFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildOfferBlock(OfferBlockEntity offerBlock) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<products.ProductBloc>().state;

      if (offerBlock.featuredCollectionHandle != null &&
          offerBlock.featuredCollectionHandle!.isNotEmpty) {
        final categoryKey = 'offer_featured_${offerBlock.id}';
        final categoryData = state.categoryProducts[categoryKey];
        if (categoryData == null ||
            categoryData.products.status == Status.initial) {
          context.read<products.ProductBloc>().add(
            LoadCategoryProductsRequested(
              categoryName: categoryKey,
              collectionHandle: offerBlock.featuredCollectionHandle!,
              first: 10,
            ),
          );
        }
      }

      if (offerBlock.clearanceCollectionHandle != null &&
          offerBlock.clearanceCollectionHandle!.isNotEmpty) {
        final categoryKey = 'offer_clearance_${offerBlock.id}';
        final categoryData = state.categoryProducts[categoryKey];
        if (categoryData == null ||
            categoryData.products.status == Status.initial) {
          context.read<products.ProductBloc>().add(
            LoadCategoryProductsRequested(
              categoryName: categoryKey,
              collectionHandle: offerBlock.clearanceCollectionHandle!,
              first: 10,
            ),
          );
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (offerBlock.pdfUrl != null && offerBlock.pdfUrl!.isNotEmpty)
          _buildPdfViewer(offerBlock.id, offerBlock.pdfUrl!),

        // if (offerBlock.title != null && offerBlock.title!.isNotEmpty)
        //   Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        //     child: Text(
        //       offerBlock.title!,
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //         fontSize: 18.sp,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.black87,
        //       ),
        //     ),
        //   ),
        if (offerBlock.clearanceCollectionHandle != null &&
            offerBlock.clearanceCollectionHandle!.isNotEmpty)
          _buildClearanceSection(offerBlock),

        if (offerBlock.featuredCollectionHandle != null &&
            offerBlock.featuredCollectionHandle!.isNotEmpty)
          _buildFeaturedCollectionSection(offerBlock),

        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildPdfViewer(String offerId, String pdfUrl) {
    final controller = _getController(offerId);
    final currentPage = _currentPages[offerId] ?? 1;
    final totalPages = _totalPages[offerId] ?? 0;
    final isLoading = _loadingStates[offerId] ?? true;

    return Container(
      height: 500.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20.r,
            spreadRadius: 0,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: SfPdfViewer.network(
                pdfUrl,
                controller: controller,
                pageLayoutMode: PdfPageLayoutMode.single,
                scrollDirection: PdfScrollDirection.horizontal,
                enableDoubleTapZooming: true,
                canShowScrollHead: false,
                canShowScrollStatus: false,
                canShowPaginationDialog: false,
                pageSpacing: 0,
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  if (mounted) {
                    setState(() {
                      _totalPages[offerId] = details.document.pages.count;
                      _currentPages[offerId] = 1;
                      _loadingStates[offerId] = false;
                    });
                  }
                },
                onPageChanged: (PdfPageChangedDetails details) {
                  if (mounted) {
                    setState(() {
                      _currentPages[offerId] = details.newPageNumber;
                    });
                  }
                },
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  if (mounted) {
                    setState(() {
                      _loadingStates[offerId] = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load PDF'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppPalette.blackColor,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading PDF...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (totalPages > 1 && !isLoading) ...[
              Positioned(
                left: 16.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildNavButton(
                    icon: Icons.chevron_left,
                    enabled: currentPage > 1,
                    onPressed: () => controller.previousPage(),
                  ),
                ),
              ),
              Positioned(
                right: 16.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildNavButton(
                    icon: Icons.chevron_right,
                    enabled: currentPage < totalPages,
                    onPressed: () => controller.nextPage(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            enabled
                ? AppPalette.blackColor.withValues(alpha: 0.6)
                : Colors.grey.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        boxShadow:
            enabled
                ? [
                  BoxShadow(
                    color: AppPalette.blackColor.withValues(alpha: 0.4),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
                : [],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24.sp),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }

  Widget _buildClearanceSection(OfferBlockEntity offerBlock) {
    final categoryKey = 'offer_clearance_${offerBlock.id}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (offerBlock.clearanceCollectionTitle != null &&
            offerBlock.clearanceCollectionTitle!.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              offerBlock.clearanceCollectionTitle!,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        SizedBox(
          height: 250.h,
          child: BlocBuilder<products.ProductBloc, products.ProductState>(
            builder: (context, state) {
              final categoryData = state.categoryProducts[categoryKey];

              if (categoryData == null ||
                  categoryData.products.status == Status.initial ||
                  categoryData.products.status == Status.loading) {
                return Center(
                  child: CircularProgressIndicator(color: AppPalette.blueColor),
                );
              }

              if (categoryData.products.status == Status.error) {
                return Center(
                  child: Text(
                    'Failed to load products',
                    style: TextStyle(fontSize: 14.sp, color: Colors.red),
                  ),
                );
              }

              if (categoryData.products.status == Status.completed) {
                final products = categoryData.products.data ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No products available',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: SizedBox(
                        width: 160.w,
                        child: ShopifyGridProductCard(product: product),
                      ),
                    );
                  },
                );
              }

              return SizedBox.shrink();
            },
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        //   child: Center(
        //     child: ElevatedButton(
        //       onPressed: () {
        //         Navigator.pushNamed(
        //           context,
        //           AppRoutes.collectionProducts,
        //           arguments: {
        //             'collectionHandle': offerBlock.clearanceCollectionHandle!,
        //             'collectionTitle':
        //                 offerBlock.clearanceCollectionTitle ?? 'Shop More',
        //           },
        //         );
        //       },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: AppPalette.blackColor,

        //         padding: EdgeInsets.symmetric(
        //           horizontal: 32.w,
        //           vertical: 14.h,
        //         ),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(16.r),
        //         ),
        //       ),
        //       child: Text(
        //         'Shop More',
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontSize: 16.sp,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildFeaturedCollectionSection(OfferBlockEntity offerBlock) {
    final categoryKey = 'offer_featured_${offerBlock.id}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (offerBlock.featuredCollectionTitle != null &&
            offerBlock.featuredCollectionTitle!.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              offerBlock.featuredCollectionTitle!,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        SizedBox(
          height: 250.h,
          child: BlocBuilder<products.ProductBloc, products.ProductState>(
            builder: (context, state) {
              final categoryData = state.categoryProducts[categoryKey];

              if (categoryData == null ||
                  categoryData.products.status == Status.initial ||
                  categoryData.products.status == Status.loading) {
                return Center(
                  child: CircularProgressIndicator(color: AppPalette.blueColor),
                );
              }

              if (categoryData.products.status == Status.error) {
                return Center(
                  child: Text(
                    'Failed to load products',
                    style: TextStyle(fontSize: 14.sp, color: Colors.red),
                  ),
                );
              }

              if (categoryData.products.status == Status.completed) {
                final products = categoryData.products.data ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No products available',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: SizedBox(
                        width: 160.w,
                        child: ShopifyGridProductCard(product: product),
                      ),
                    );
                  },
                );
              }

              return SizedBox.shrink();
            },
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.collectionProducts,
                  arguments: {
                    'collectionHandle': offerBlock.featuredCollectionHandle!,
                    'collectionTitle':
                        offerBlock.featuredCollectionTitle ?? 'Shop More',
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.blackColor,
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Shop More',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Wraps each offer block so it stays alive when scrolled off-screen.
/// This prevents the second (and later) PDFs from reloading every time
/// the user scrolls back to them.
class _KeepAliveOfferBlock extends StatefulWidget {
  final OfferBlockEntity offerBlock;
  final Widget Function(OfferBlockEntity) buildOfferBlock;

  const _KeepAliveOfferBlock({
    super.key,
    required this.offerBlock,
    required this.buildOfferBlock,
  });

  @override
  State<_KeepAliveOfferBlock> createState() => _KeepAliveOfferBlockState();
}

class _KeepAliveOfferBlockState extends State<_KeepAliveOfferBlock>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.buildOfferBlock(widget.offerBlock);
  }
}
