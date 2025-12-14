import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/common/custom_snackbar.dart';
import 'package:iconnect/core/di/service_locator.dart';
import 'package:iconnect/features/orders/domain/entities/order_entity.dart';
import 'package:iconnect/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:iconnect/features/orders/presentation/cubit/orders_state.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrdersCubit>()..loadOrders(refresh: true),
      child: Scaffold(
        backgroundColor: AppPalette.whiteColor,
        appBar: AppBar(
          backgroundColor: AppPalette.whiteColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppPalette.blackColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'My Orders',
            style: GoogleFonts.poppins(
              color: AppPalette.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocConsumer<OrdersCubit, OrdersState>(
          listener: (context, state) {
            if (state is OrdersError) {
              CustomSnackBar.show(
                context,
                message: state.message,
                textAlign: TextAlign.center,
                backgroundColor: AppPalette.redColor,
              );
            }
          },
          builder: (context, state) {
            if (state is OrdersLoading && (state.orders.isEmpty)) {
              return const Center(
                child: CircularProgressIndicator(color: AppPalette.blueColor),
              );
            }

            if (state is OrdersError && (state.orders.isEmpty)) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppPalette.redColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: GoogleFonts.poppins(color: AppPalette.redColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => context.read<OrdersCubit>().loadOrders(
                            refresh: true,
                          ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            List<OrderEntity> orders = [];
            bool isLoading = false;

            if (state is OrdersLoaded) {
              orders = state.orders;
            } else if (state is OrdersLoading) {
              orders = state.orders;
              isLoading = true;
            } else if (state is OrdersError) {
              orders = state.orders;
            }

            if (orders.isEmpty && !isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: AppPalette.hintColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders yet',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your orders will appear here',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppPalette.hintColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrdersCubit>().loadOrders(refresh: true);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == orders.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          color: AppPalette.blueColor,
                        ),
                      ),
                    );
                  }

                  final order = orders[index];
                  return _buildOrderCard(context, order);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.hintColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppPalette.blackColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.blackColor,
                      ),
                    ),
                    if (order.processedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.processedAt!),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppPalette.hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                order.totalPrice.formattedAmount,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.blueColor,
                ),
              ),
            ],
          ),
          if (order.lineItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...order.lineItems
                .take(3)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        if (item.variant?.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              item.variant!.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const SizedBox(width: 50, height: 50),
                            ),
                          )
                        else
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppPalette.hintColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppPalette.blackColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qty: ${item.quantity}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppPalette.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item.originalTotalPrice.formattedAmount,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            if (order.lineItems.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${order.lineItems.length - 3} more item(s)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppPalette.blueColor,
                  ),
                ),
              ),
          ],
          if (order.fulfillmentStatus != null ||
              order.financialStatus != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (order.fulfillmentStatus != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.blueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.fulfillmentStatus!,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppPalette.blueColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (order.fulfillmentStatus != null &&
                    order.financialStatus != null)
                  const SizedBox(width: 8),
                if (order.financialStatus != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.financialStatus!,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppPalette.greenColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
