import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_button.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/data/product_data.dart';
import 'package:iconnect/models/cart_item.dart';
import 'package:iconnect/widgets/product_card.dart';
import 'package:iconnect/widgets/product_preview_modal.dart';
import 'package:iconnect/screens/search_screen.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  late Map<String, dynamic> product;
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    product = ProductData.getProductById(widget.productId) ?? {};
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (product.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Not Found')),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title:  Center(
        child: Image.asset(
          'assets/iconnect_logo.png',
          height: 25.h,
          fit: BoxFit.contain,
        ),
      ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Banner
                _buildProductImageBanner(),

                // Product Details Section
                _buildProductDetails(),

                // Price Section
                _buildPriceSection(),

                // Quantity Section
                _buildQuantitySection(),

                // Action Buttons
                _buildActionButtons(),

                // Product Description
                _buildProductDescription(),

                // You May Also Like Section
                _buildYouMayAlsoLikeSection(),

                // Bottom padding
                const SizedBox(height: 100),
              ],
            ),
          ),
          const WhatsAppFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildProductImageBanner() {
    // Get product images from the product data
    final List<String> productImages =
        product['images'] != null
            ? List<String>.from(product['images'])
            : [
              product['imageUrl'],
            ]; // Fallback to single image if images array doesn't exist

    return Column(
      children: [
        // Main image carousel
        Container(
          height: 300,
          width: double.infinity,
          color: Colors.grey[100],
          child: Stack(
            children: [
              // Image carousel with pinch-to-zoom
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: productImages.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,  
                    maxScale: 4.0,
                    panEnabled: true,
                    scaleEnabled: true,
                    child: Center(
                      child: Image.network(
                        productImages[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppPalette.blueColor,
                              strokeWidth: 2,
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 100,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

   

        // Thumbnail gallery
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: productImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          _currentImageIndex == index
                              ? AppPalette.blackColor
                              : Colors.grey[300]!,
                      width: _currentImageIndex == index ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Image.network(
                      productImages[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppPalette.blackColor,
                            strokeWidth: 1,
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),

             // Pagination indicators
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              productImages.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentImageIndex == index
                          ? AppPalette.blackColor
                          : AppPalette.hintColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand name
          Text(
              'Apple', // You can make this dynamic based on product data
              style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            product['productName'] ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          maxLines: 7,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'QAR ${product['discountedPrice']?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppPalette.redColor,
            ),
          ),
          if (product['originalPrice'] != null &&
              product['originalPrice'] != product['discountedPrice'])
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'QAR ${product['originalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  fontSize: 16,
                  color: AppPalette.blackColor,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Quantity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300] ?? AppPalette.greyColor),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed:
                      _quantity > 1
                          ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                          : null,
                  icon: const Icon(Icons.remove),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                  icon: const Icon(Icons.add),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomButton(
            onPressed: () {
              _addToCart();
            },
            text: 'Add to cart',
            bgColor: AppPalette.whiteColor,
            textColor: AppPalette.blackColor,
            borderColor: AppPalette.blackColor,

          ),
        ConstantWidgets.hight10(context),
          Builder(
            builder: (BuildContext scaffoldContext) {
              return  CustomButton(
                onPressed: () {
                  _buyNow(scaffoldContext);
                },
                text: 'Buy it now',
                bgColor: AppPalette.blackColor,
                textColor: AppPalette.whiteColor,
                borderColor: AppPalette.blackColor,
              );
            },
          ),
          ConstantWidgets.hight10(context),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _makePhoneCall,
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Order By Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _launchWhatsApp,
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
                  label: const Text('WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ConstantWidgets.hight10(context),
        ],
      ),
    );
  }

  Widget _buildProductDescription() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Product specifications
          _buildSpecificationItem('Network Technology', '5G'),
          _buildSpecificationItem('Dimensions', '156.2 x 74.7 x 5.64 mm'),
          _buildSpecificationItem('Weight', '5.82 ounces (165 grams)'),
          _buildSpecificationItem('SIM', 'Dual eSIM (two active eSIMs)'),
          _buildSpecificationItem(
            'Charging',
            'Up to 50% Charge in 30 Minutes with 20W Adapter or Higher Paired with USB-C Charging Cable, or 30W Adapter or Higher Paired with MagSafe Charger',
          ),

          const SizedBox(height: 16),

          // Product description text
          Text(
            product['description'] ?? 'No description available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouMayAlsoLikeSection() {
    final relatedProducts =
        ProductData.getProducts()
            .where((p) => p['id'] != widget.productId)
            .take(5)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'You Might Also Like',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: relatedProducts.length,
            itemBuilder: (context, index) {
              final product = relatedProducts[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) {
                    final isInCart = cartState.items.any((item) => item.id == product['id']);
                    return ProductCard(
                      imageUrl: product['imageUrl'],
                      productName: product['productName'],
                      description: product['description'],
                      originalPrice: product['originalPrice'].toDouble(),
                      discountedPrice: product['discountedPrice'].toDouble(),
                      productId: product['id'],
                      offerText: product['offerText'],
                      isInCart: isInCart,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product_details',
                          arguments: {'productId': product['id']},
                        );
                      },
                      onAddToCart: () {
                        final cartItem = CartItem(
                          id: product['id'],
                          imageUrl: product['imageUrl'],
                          productName: product['productName'],
                          description: product['description'],
                          originalPrice: product['originalPrice'].toDouble(),
                          discountedPrice: product['discountedPrice'].toDouble(),
                          offerText: product['offerText'],
                        );
                        context.read<CartCubit>().addToCart(cartItem);
                        
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product['productName']} added to cart'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppPalette.blueColor,
                          ),
                        );
                      },
                      onView: () {
                        showDialog(
                          context: context,
                          builder: (context) => ProductPreviewModal(
                            product: product,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addToCart() {
    try {
      final cartItem = CartItem(
        id: product['id'],
        imageUrl: product['imageUrl'],
        productName: product['productName'],
        description: product['description'],
        originalPrice: product['originalPrice'].toDouble(),
        discountedPrice: product['discountedPrice'].toDouble(),
        offerText: product['offerText'],
        quantity: _quantity,
      );

      context.read<CartCubit>().addToCart(cartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product['productName']} added to cart'),
          backgroundColor: AppPalette.blueColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: AppPalette.redColor,
        ),
      );
    }
  }

  void _buyNow(BuildContext scaffoldContext) {
    _addToCart();
    // Navigate to cart or checkout
    Scaffold.of(scaffoldContext).openEndDrawer();
  }

  Future<void> _makePhoneCall() async {
    final phoneNumber = PhoneConfig.phoneNumber;
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone dialer'),
              backgroundColor: AppPalette.redColor,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppPalette.redColor,
          ),
        );
      }
    }
  }

  Future<void> _launchWhatsApp() async {
    final phoneNumber = PhoneConfig.phoneNumber;
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch WhatsApp'),
              backgroundColor: AppPalette.redColor,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppPalette.redColor,
          ),
        );
      }
    }
  }
}

class CustomAppBarProductDetails extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onBack;

  @override
  final Size preferredSize;

  const CustomAppBarProductDetails({super.key, this.onBack})
    : preferredSize = const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      surfaceTintColor: Colors.white,
      centerTitle: true,
      title: Center(
        child: Image.asset(
          'assets/iconnect_logo.png',
          height: 25,
          fit: BoxFit.contain,
        ),
      ),
      leading: IconButton.filled(
        tooltip: 'Back',
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        style: IconButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
        ),
      ),
      actions: [
        IconButton.filled(
          icon: const Icon(Icons.search, color: AppPalette.blackColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
                fullscreenDialog: true,
              ),
            );
          },
          tooltip: 'Search',
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.black26,
            shape: const CircleBorder(),
          ),
        ),
        ConstantWidgets.width20(context),
        Builder(
          builder: (BuildContext scaffoldContext) {
            return Stack(
              children: [
                IconButton.filled(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppPalette.blackColor,
                  ),
                  onPressed: () {
                    Scaffold.of(scaffoldContext).openEndDrawer();
                  },
                  tooltip: 'Shopping Cart',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.black26,
                    shape: const CircleBorder(),
                  ),
                ),
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    if (state.itemCount > 0) {
                      return Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppPalette.redColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${state.itemCount}',
                            style: const TextStyle(
                              color: AppPalette.whiteColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),
        ConstantWidgets.width40(context),
      ],
    );
  }
}
