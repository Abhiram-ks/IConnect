import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/common/custom_snackbar.dart';
import 'package:iconnect/common/custom_testfiled.dart';
import '../../../../../app_palette.dart';
import '../../../../../common/custom_button.dart';
import '../../../../../constant/constant.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../screens/nav_screen.dart';
import '../cubit/checkout_cubit.dart';
import 'checkout_webview_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _addresses = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _whatsAppNumber = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = sl<CheckoutCubit>().state;
    if (state is CheckoutLoaded) {
      _contact.text = state.email;
      _firstName.text = state.firstName;
      _lastName.text = state.lastName;
      _addresses.text = state.address;
      _city.text = state.city;
      _whatsAppNumber.text = state.whatsappNumber;
    }
  }

  void _updateCubit() {
    sl<CheckoutCubit>().updateUserDetails(
      email: _contact.text,
      firstName: _firstName.text,
      lastName: _lastName.text,
      address: _addresses.text,
      city: _city.text,
      whatsappNumber: _whatsAppNumber.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarDashbord(onBack: () => Navigator.pop(context)),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        bloc: sl<CheckoutCubit>(),
        listener: (context, state) {
          // efficient state sync if needed
        },
        builder: (context, state) {
          if (state is! CheckoutLoaded) {
            return const Center(child: Text("No checkout data found."));
          }

          final items = state.items;
          if (items.isNotEmpty) {
            debugPrint(
              'UserDetailsScreen Rebuilding. Item 1: ${items.first.productTitle} - ${items.first.imageUrl}',
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ConstantWidgets.hight10(context),
                    TextFormFieldWidget(
                      hintText: 'Email or mobile phone number',
                      controller: _contact,
                      validate: ValidateHelper.validateFunction,
                      onChanged: (_) => _updateCubit(),
                    ),
                    Text(
                      'Delivery',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ConstantWidgets.hight10(context),
                    TextFormFieldWidget(
                      hintText: 'First Name',
                      controller: _firstName,
                      validate: ValidateHelper.validateFunction,
                      onChanged: (_) => _updateCubit(),
                    ),
                    TextFormFieldWidget(
                      hintText: 'Last Name',
                      controller: _lastName,
                      validate: ValidateHelper.validateFunction,
                      onChanged: (_) => _updateCubit(),
                    ),
                    TextFormFieldWidget(
                      hintText: 'Address',
                      maxLines: 3,
                      minLines: 3,
                      controller: _addresses,
                      validate: ValidateHelper.validateFunction,
                      onChanged: (_) => _updateCubit(),
                    ),
                    TextFormFieldWidget(
                      hintText: 'City',
                      controller: _city,
                      validate: ValidateHelper.validateFunction,
                      onChanged: (_) => _updateCubit(),
                    ),
                    TextFormFieldWidget(
                      hintText: 'WhatsApp Number',
                      suffixIconData: Icons.help_outline_outlined,
                      suffixIconColor: AppPalette.hintColor,
                      controller: _whatsAppNumber,
                      validate: ValidateHelper.validateFunction,
                      onChanged: (_) => _updateCubit(),
                      suffixIconAction: () {
                        CustomSnackBar.show(
                          context,
                          message:
                              'In case we need to contact you about your order',
                          textAlign: TextAlign.center,
                        );
                      },
                    ),

                    ConstantWidgets.hight30(context),
                    const Divider(),
                    ConstantWidgets.hight20(context),

                    // Order Summary Section
                    Text(
                      'Order summary (${items.length} items)',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ConstantWidgets.hight10(context),

                    // Items List
                    ...items.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 16.w),
                        child: Row(
                          children: [
                            Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child:
                                  item.imageUrl != null
                                      ? Image.network(
                                        key: ValueKey(
                                          item.imageUrl,
                                        ), // Force rebuild if URL changes
                                        item.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      )
                                      : const Icon(Icons.shopping_bag),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productTitle?.isNotEmpty == true
                                        ? item.productTitle!
                                        : item.title,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.title != item.productTitle &&
                                      item.title != 'Default Title')
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  Text(
                                    "${item.currencyCode} ${item.price} x ${item.quantity}",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${item.currencyCode} ${item.totalPrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(),
                    ConstantWidgets.hight10(context),

                    // Total Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${items.isNotEmpty ? items.first.currencyCode : 'QAR'} ${items.fold<double>(0, (sum, item) => sum + item.totalPrice).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.blackColor,
                          ),
                        ),
                      ],
                    ),

                    ConstantWidgets.hight20(context),
                    BlocBuilder<CheckoutCubit, CheckoutState>(
                      bloc: sl<CheckoutCubit>(),
                      builder: (context, checkoutState) {
                        final isCreatingCheckout =
                            checkoutState is CheckoutCreating;

                        return CustomButton(
                          onPressed:
                              isCreatingCheckout
                                  ? null
                                  : () async {
                                    if (_formkey.currentState!.validate()) {
                                      _updateCubit(); // Ensure latest data is saved

                                      // Create Shopify checkout
                                      await sl<CheckoutCubit>().createShopifyCheckout(
                                        email: _contact.text,
                                      );

                                      // Check the result and navigate
                                      if (context.mounted) {
                                        final state = sl<CheckoutCubit>().state;
                                        if (state is CheckoutCreated) {
                                          // Navigate to WebView with checkout URL
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => CheckoutWebViewScreen(
                                                    checkoutUrl: state.webUrl,
                                                    customerAccessToken: state.customerAccessToken,
                                                  ),
                                            ),
                                          );
                                        } else if (state is CheckoutError) {
                                          CustomSnackBar.show(
                                            context,
                                            message: state.message,
                                            textAlign: TextAlign.center,
                                            backgroundColor: AppPalette.redColor,
                                          );
                                        }
                                      }
                                    } else {
                                      CustomSnackBar.show(
                                        context,
                                        message:
                                            "Please complete the form before proceeding",
                                        textAlign: TextAlign.center,
                                        backgroundColor: AppPalette.redColor,
                                      );
                                    }
                                  },
                          text:
                              isCreatingCheckout
                                  ? 'Creating Checkout...'
                                  : 'Proceed to Checkout',
                          bgColor: AppPalette.blackColor,
                          textColor: AppPalette.whiteColor,
                          borderColor: AppPalette.blackColor,
                        );
                      },
                    ),
                    ConstantWidgets.hight20(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ValidateHelper {
  static String? validateFunction(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please Enter your answer';
    } else if (val.startsWith(' ')) {
      return 'Invalid entery, Can not start with space';
    }
    return null;
  }
}
