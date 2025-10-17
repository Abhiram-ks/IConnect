import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductScreenState {
  final String selectedSort;
  final bool isGridView;
  final RangeValues priceRange;
  final Set<String> selectedBrands;
  final Set<String> availabilityFilters;

  const ProductScreenState({
    this.selectedSort = 'Alphabetically, A-Z',
    this.isGridView = true,
    this.priceRange = const RangeValues(0, 14999),
    this.selectedBrands = const {},
    this.availabilityFilters = const {},
  });

  ProductScreenState copyWith({
    String? selectedSort,
    bool? isGridView,
    RangeValues? priceRange,
    Set<String>? selectedBrands,
    Set<String>? availabilityFilters,
  }) {
    return ProductScreenState(
      selectedSort: selectedSort ?? this.selectedSort,
      isGridView: isGridView ?? this.isGridView,
      priceRange: priceRange ?? this.priceRange,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      availabilityFilters: availabilityFilters ?? this.availabilityFilters,
    );
  }
}

class ProductScreenCubit extends Cubit<ProductScreenState> {
  ProductScreenCubit() : super(const ProductScreenState());

  void updateSort(String sort) {
    emit(state.copyWith(selectedSort: sort));
  }

  void toggleView() {
    emit(state.copyWith(isGridView: !state.isGridView));
  }

  void updateFilters({
    RangeValues? priceRange,
    Set<String>? selectedBrands,
    Set<String>? availabilityFilters,
  }) {
    emit(state.copyWith(
      priceRange: priceRange,
      selectedBrands: selectedBrands,
      availabilityFilters: availabilityFilters,
    ));
  }

  void clearFilters() {
    emit(state.copyWith(
      priceRange: const RangeValues(0, 14999),
      selectedBrands: const {},
      availabilityFilters: const {},
    ));
  }
}
