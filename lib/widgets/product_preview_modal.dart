import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_button.dart';
import 'package:iconnect/constant/constant.dart';
import 'package:iconnect/cubit/cart_cubit/cart_cubit.dart';
import 'package:iconnect/models/cart_item.dart';

class ProductPreviewModal extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductPreviewModal({super.key, required this.product});

  @override
  State<ProductPreviewModal> createState() => _ProductPreviewModalState();
}

class _ProductPreviewModalState extends State<ProductPreviewModal> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    // Try to get the existing CartCubit, if not available create a new one
    CartCubit cartCubit;
    try {
      cartCubit = context.read<CartCubit>();
    } catch (e) {
      cartCubit = CartCubit();
    }

    return BlocProvider.value(value: cartCubit, child: _buildModalContent());
  }

  Widget _buildModalContent() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.98,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          decoration: BoxDecoration(color: AppPalette.whiteColor),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.grey[100]),
                          child: Image.network(
                            widget.product['imageUrl'],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppPalette.blueColor,
                                  strokeWidth: 2,
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              (loadingProgress
                                                      .expectedTotalBytes ??
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
                                  size: 50,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      Positioned(
                        top: 10,
                        right: 10,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppPalette.whiteColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.xmark,
                              color: AppPalette.blackColor,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Product details section
                Flexible(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 10,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product title
                          Text(
                            ' ${widget.product['productName']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Price
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'QAR ${widget.product['discountedPrice'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppPalette.redColor,
                                ),
                              ),
                              ConstantWidgets.width20(context),
                              Text(
                                'QAR ${widget.product['discountedPrice'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppPalette.greyColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                          ConstantWidgets.hight10(context),

                          // Description
                          Text(
                            widget.product['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          ConstantWidgets.hight10(context),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              // Navigate to full product details
                              Navigator.pushNamed(
                                context,
                                '/product_details',
                                arguments: {'productId': widget.product['id']},
                              );
                            },
                            child: const Text(
                              'View details',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppPalette.blackColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          ConstantWidgets.hight20(context),

                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: AppPalette.greenColor,
                                size: 10,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '9 In stock',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          ConstantWidgets.hight20(context),
                          Row(
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              ConstantWidgets.width20(context),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Minus button
                                    GestureDetector(
                                      onTap: () {
                                        if (_quantity > 1) {
                                          setState(() {
                                            _quantity--;
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                              color:
                                                  Colors.grey[300] ??
                                                  AppPalette.hintColor,
                                            ),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.black87,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text(
                                        _quantity.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _quantity++;
                                        });
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color:
                                                  Colors.grey[300] ??
                                                  AppPalette.hintColor,
                                            ),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.black87,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          ConstantWidgets.hight20(context),

                          // Action buttons
                          Column(
                            children: [
                              CustomButton(
                                text: 'Add to cart',
                                onPressed: () {
                                  final cartItem = CartItem(
                                    id: widget.product['id'],
                                    imageUrl: widget.product['imageUrl'],
                                    productName: widget.product['productName'],
                                    description: widget.product['description'],
                                    originalPrice:
                                        widget.product['originalPrice'],
                                    discountedPrice:
                                        widget.product['discountedPrice'],
                                    offerText: widget.product['offerText'],
                                    quantity: _quantity,
                                  );
                                  context.read<CartCubit>().addToCart(cartItem);

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${widget.product['productName']} added to cart',
                                      ),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: AppPalette.blueColor,
                                    ),
                                  );

                                  // Close modal
                                  Navigator.of(context).pop();
                                },
                                borderColor: AppPalette.blackColor,
                                textColor: AppPalette.blackColor,
                                bgColor: AppPalette.whiteColor,
                              ),
                              ConstantWidgets.hight10(context),
                              CustomButton(
                                text: 'Buy it now',
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // TODO: Implement buy now functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Buy now functionality coming soon!',
                                      ),
                                      backgroundColor: AppPalette.blueColor,
                                    ),
                                  );
                                },
                              ),
                              ConstantWidgets.hight20(context),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
