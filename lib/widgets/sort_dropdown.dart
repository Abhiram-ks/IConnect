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
    this.initialFilter = ProductSortFilter.featured,
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

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: 20.h,
              left: 16.w,
              right: 16.w,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort by',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 24.sp),
                    ),
                  ],
                ),
                ...ProductSortFilter.values.map((filter) {
                  final isSelected = filter == _currentFilter;
                  return InkWell(
                    onTap: () {
                      if (filter != _currentFilter) {
                        setState(() {
                          _currentFilter = filter;
                        });
                        final sortParams = _getSortParamsForFilter(filter);
                        widget.onFilterChanged(filter, sortParams);
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getFilterDisplayName(filter),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color:
                                  isSelected
                                      ? AppPalette.blueColor
                                      : Colors.black87,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: AppPalette.blueColor,
                              size: 20.sp,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showSortBottomSheet,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              _getFilterDisplayName(_currentFilter),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down_sharp, size: 24.sp),
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
