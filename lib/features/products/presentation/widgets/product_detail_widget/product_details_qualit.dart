

  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app_palette.dart';
import '../../bloc/quantity_cubit.dart';

Widget buildQuantitySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Quantity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          BlocBuilder<QuantityCubit, QuantityState>(
            builder: (context, state) {
              return Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300] ?? AppPalette.greyColor,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: state.isAtMin
                          ? null
                          : () => context.read<QuantityCubit>().decrement(),
                      icon: const Icon(Icons.remove),
                      iconSize: 18,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      splashRadius: 18,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${state.count}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (state.isAtMax) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Maximum ${state.max} per order',
                              ),
                              backgroundColor: AppPalette.redColor,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        context.read<QuantityCubit>().increment();
                      },
                      icon: const Icon(Icons.add),
                      iconSize: 18,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      splashRadius: 18,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
