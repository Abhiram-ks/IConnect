import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconnect/app_palette.dart';

enum ProductSortFilter {
  featured,
  bestSelling,
  alphabeticallyAZ,
  alphabeticallyZA,
  priceLowToHigh,
  priceHighToLow,
  dateOldToNew,
  dateNewToOld,
}

class SortDropdown extends StatefulWidget {
  final ProductSortFilter initialFilter;
  final Function(ProductSortFilter, Map<String, dynamic>) onFilterChanged;
  final String? label;
  final EdgeInsets? padding;

  const SortDropdown({
    super.key,
    this.initialFilter = ProductSortFilter.alphabeticallyAZ,
    required this.onFilterChanged,
    this.label,
    this.padding,
  });

  @override
  State<SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  late ProductSortFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
  }

  @override
  void didUpdateWidget(SortDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter) {
      _currentFilter = widget.initialFilter;
    }
  }

  Map<String, dynamic> _getSortParamsForFilter(ProductSortFilter filter) {
    switch (filter) {
      case ProductSortFilter.featured:
        return {'sortKey': 'RELEVANCE', 'reverse': false};
      case ProductSortFilter.bestSelling:
        return {'sortKey': 'BEST_SELLING', 'reverse': false};
      case ProductSortFilter.alphabeticallyAZ:
        return {'sortKey': 'TITLE', 'reverse': false};
      case ProductSortFilter.alphabeticallyZA:
        return {'sortKey': 'TITLE', 'reverse': true};
      case ProductSortFilter.priceLowToHigh:
        return {'sortKey': 'PRICE', 'reverse': false};
      case ProductSortFilter.priceHighToLow:
        return {'sortKey': 'PRICE', 'reverse': true};
      case ProductSortFilter.dateOldToNew:
        return {'sortKey': 'CREATED_AT', 'reverse': false};
      case ProductSortFilter.dateNewToOld:
        return {'sortKey': 'CREATED_AT', 'reverse': true};
    }
  }

  String _getFilterDisplayName(ProductSortFilter filter) {
    switch (filter) {
      case ProductSortFilter.featured:
        return 'Featured';
      case ProductSortFilter.bestSelling:
        return 'Best selling';
      case ProductSortFilter.alphabeticallyAZ:
        return 'Alphabetically, A-Z';
      case ProductSortFilter.alphabeticallyZA:
        return 'Alphabetically, Z-A';
      case ProductSortFilter.priceLowToHigh:
        return 'Price, low to high';
      case ProductSortFilter.priceHighToLow:
        return 'Price, high to low';
      case ProductSortFilter.dateOldToNew:
        return 'Date, old to new';
      case ProductSortFilter.dateNewToOld:
        return 'Date, new to old';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          widget.padding ??
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            widget.label ?? 'Sort by:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.blackColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppPalette.greyColor.withValues(alpha: .3),
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ProductSortFilter>(
                  value: _currentFilter,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppPalette.blackColor,
                    size: 20.sp,
                  ),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppPalette.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                  items:
                      ProductSortFilter.values.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(_getFilterDisplayName(filter)),
                        );
                      }).toList(),
                  onChanged: (newFilter) {
                    if (newFilter != null && newFilter != _currentFilter) {
                      setState(() {
                        _currentFilter = newFilter;
                      });
                      final sortParams = _getSortParamsForFilter(newFilter);
                      widget.onFilterChanged(newFilter, sortParams);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper functions for external use
Map<String, dynamic> getSortParamsForFilter(ProductSortFilter filter) {
  switch (filter) {
    case ProductSortFilter.featured:
      return {'sortKey': 'RELEVANCE', 'reverse': false};
    case ProductSortFilter.bestSelling:
      return {'sortKey': 'BEST_SELLING', 'reverse': false};
    case ProductSortFilter.alphabeticallyAZ:
      return {'sortKey': 'TITLE', 'reverse': false};
    case ProductSortFilter.alphabeticallyZA:
      return {'sortKey': 'TITLE', 'reverse': true};
    case ProductSortFilter.priceLowToHigh:
      return {'sortKey': 'PRICE', 'reverse': false};
    case ProductSortFilter.priceHighToLow:
      return {'sortKey': 'PRICE', 'reverse': true};
    case ProductSortFilter.dateOldToNew:
      return {'sortKey': 'CREATED_AT', 'reverse': false};
    case ProductSortFilter.dateNewToOld:
      return {'sortKey': 'CREATED_AT', 'reverse': true};
  }
}

String getFilterDisplayName(ProductSortFilter filter) {
  switch (filter) {
    case ProductSortFilter.featured:
      return 'Featured';
    case ProductSortFilter.bestSelling:
      return 'Best selling';
    case ProductSortFilter.alphabeticallyAZ:
      return 'Alphabetically, A-Z';
    case ProductSortFilter.alphabeticallyZA:
      return 'Alphabetically, Z-A';
    case ProductSortFilter.priceLowToHigh:
      return 'Price, low to high';
    case ProductSortFilter.priceHighToLow:
      return 'Price, high to low';
    case ProductSortFilter.dateOldToNew:
      return 'Date, old to new';
    case ProductSortFilter.dateNewToOld:
      return 'Date, new to old';
  }
}
