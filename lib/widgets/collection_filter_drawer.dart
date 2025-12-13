import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/collection_filter.dart';

class CollectionFilterDrawer extends StatefulWidget {
  final List<CollectionFilter> availableFilters;
  final List<ActiveFilter> activeFilters;
  final Function(List<ActiveFilter>) onFiltersApplied;
  final VoidCallback onClearAll;

  const CollectionFilterDrawer({
    super.key,
    required this.availableFilters,
    required this.activeFilters,
    required this.onFiltersApplied,
    required this.onClearAll,
  });

  @override
  State<CollectionFilterDrawer> createState() => _CollectionFilterDrawerState();
}

class _CollectionFilterDrawerState extends State<CollectionFilterDrawer> {
  late List<ActiveFilter> _tempActiveFilters;

  // Price range state
  RangeValues? _currentPriceRange;
  double? _minPrice;
  double? _maxPrice;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _tempActiveFilters = List.from(widget.activeFilters);

    // Initialize price bounds from API first
    _initializePriceBounds();

    // Then check for active price filter
    _initializePriceRange();

    _minPriceController = TextEditingController(
      text: (_currentPriceRange?.start ?? _minPrice ?? 0).toStringAsFixed(0),
    );
    _maxPriceController = TextEditingController(
      text: (_currentPriceRange?.end ?? _maxPrice ?? 0).toStringAsFixed(0),
    );
  }

  void _initializePriceBounds() {
    // Find the price filter from available filters
    final priceFilter = widget.availableFilters.firstWhere(
      (f) => f.type == 'PRICE_RANGE',
      orElse: () => CollectionFilter(id: '', label: '', type: '', values: []),
    );

    if (priceFilter.id.isNotEmpty && priceFilter.values.isNotEmpty) {
      try {
        final firstValue = priceFilter.values.first;
        final inputStr = firstValue.input.replaceAll(r'\', '');
        final inputJson = inputStr.substring(inputStr.indexOf('{'));

        final minMatch = RegExp(r'"min":([\d.]+)').firstMatch(inputJson);
        final maxMatch = RegExp(r'"max":([\d.]+)').firstMatch(inputJson);

        if (minMatch != null) {
          _minPrice = double.tryParse(minMatch.group(1) ?? '0') ?? 0;
        }
        if (maxMatch != null) {
          _maxPrice = double.tryParse(maxMatch.group(1) ?? '10000') ?? 10000;
        }

        // Set initial range to full range
        _currentPriceRange = RangeValues(_minPrice ?? 0, _maxPrice ?? 10000);
      } catch (e) {
        print('Error parsing price bounds: $e');
      }
    }
  }

  void _initializePriceRange() {
    // Check if there's an active price filter to restore user's selection
    final activePriceFilter = widget.activeFilters.firstWhere(
      (f) => f.filterId == 'filter.v.price',
      orElse:
          () => ActiveFilter(
            filterId: '',
            filterLabel: '',
            valueId: '',
            valueLabel: '',
            input: '',
          ),
    );

    if (activePriceFilter.filterId.isNotEmpty) {
      // Parse the active price range and restore it
      try {
        final priceMatch = RegExp(
          r'"min":([\d.]+).*"max":([\d.]+)',
        ).firstMatch(activePriceFilter.input);
        if (priceMatch != null) {
          final minPrice = double.tryParse(priceMatch.group(1) ?? '0') ?? 0;
          final maxPrice =
              double.tryParse(
                priceMatch.group(2) ?? (_maxPrice?.toString() ?? '10000'),
              ) ??
              (_maxPrice ?? 10000);
          _currentPriceRange = RangeValues(minPrice, maxPrice);
        }
      } catch (e) {
        print('Error parsing active price filter: $e');
      }
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  bool _isFilterActive(String filterId, String valueId) {
    return _tempActiveFilters.any(
      (f) => f.filterId == filterId && f.valueId == valueId,
    );
  }

  void _toggleFilter(CollectionFilter filter, FilterValue value) {
    setState(() {
      final existingFilter = _tempActiveFilters.firstWhere(
        (f) => f.filterId == filter.id && f.valueId == value.id,
        orElse:
            () => ActiveFilter(
              filterId: '',
              filterLabel: '',
              valueId: '',
              valueLabel: '',
              input: '',
            ),
      );

      if (existingFilter.filterId.isNotEmpty) {
        // Remove filter
        _tempActiveFilters.removeWhere(
          (f) => f.filterId == filter.id && f.valueId == value.id,
        );
      } else {
        // Add filter
        _tempActiveFilters.add(
          ActiveFilter(
            filterId: filter.id,
            filterLabel: filter.label,
            valueId: value.id,
            valueLabel: value.label,
            input: value.input,
          ),
        );
      }
    });
  }

  void _clearAll() {
    setState(() {
      _tempActiveFilters.clear();
      // Reset price range to default (full range)
      if (_minPrice != null && _maxPrice != null) {
        _currentPriceRange = RangeValues(_minPrice!, _maxPrice!);
        _minPriceController.text = _minPrice!.toStringAsFixed(0);
        _maxPriceController.text = _maxPrice!.toStringAsFixed(0);
      }
    });
  }

  void _applyFilters() {
    // Add price range filter if it's different from the default range
    final priceFilter = widget.availableFilters.firstWhere(
      (f) => f.type == 'PRICE_RANGE',
      orElse: () => CollectionFilter(id: '', label: '', type: '', values: []),
    );

    if (priceFilter.id.isNotEmpty && priceFilter.values.isNotEmpty) {
      // Remove any existing price filter
      _tempActiveFilters.removeWhere((f) => f.filterId == priceFilter.id);

      // Check if price range has been modified
      if (_currentPriceRange!.start != _minPrice ||
          _currentPriceRange!.end != _maxPrice) {
        // Add the price filter with the selected range
        final priceInput =
            '{"price":{"min":${_currentPriceRange!.start},"max":${_currentPriceRange!.end}}}';
        _tempActiveFilters.add(
          ActiveFilter(
            filterId: priceFilter.id,
            filterLabel: priceFilter.label,
            valueId: priceFilter.values.first.id,
            valueLabel:
                'QAR ${_currentPriceRange!.start.toStringAsFixed(0)} - QAR ${_currentPriceRange!.end.toStringAsFixed(0)}',
            input: priceInput,
          ),
        );
      }
    }

    widget.onFiltersApplied(_tempActiveFilters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 24.sp),
                  ),
                ],
              ),
            ),

            // Active filters count
            if (_tempActiveFilters.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_tempActiveFilters.length} filter(s) selected',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: _clearAll,
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Divider(height: 1.h),

            // Filter options
            Expanded(
              child:
                  widget.availableFilters.isEmpty
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_list_off,
                                size: 64.sp,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No filters available',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        itemCount: widget.availableFilters.length,
                        itemBuilder: (context, index) {
                          final filter = widget.availableFilters[index];
                          return _buildFilterSection(filter);
                        },
                      ),
            ),

            // Apply button
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(CollectionFilter filter) {
    // Special handling for price range filter
    if (filter.type == 'PRICE_RANGE' && filter.values.isNotEmpty) {
      return _buildPriceRangeFilter(filter);
    }

    // Regular list filters (checkboxes)
    return ExpansionTile(
      title: Text(
        filter.label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          color: Colors.black,
        ),
      ),
      tilePadding: EdgeInsets.zero,
      initiallyExpanded: true,
      shape: Border.all(color: Colors.transparent),
      children:
          filter.values.map((value) {
            final isActive = _isFilterActive(filter.id, value.id);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Expanded(
                    child: Text(value.label, style: TextStyle(fontSize: 14.sp)),
                  ),
                  if (value.count > 0)
                    Text(
                      '(${value.count})',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              value: isActive,
              activeColor: Colors.black,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? checked) {
                _toggleFilter(filter, value);
              },
            );
          }).toList(),
    );
  }

  Widget _buildPriceRangeFilter(CollectionFilter filter) {
    // Ensure price range is initialized
    if (_minPrice == null || _maxPrice == null || _currentPriceRange == null) {
      return const SizedBox.shrink();
    }

    return ExpansionTile(
      title: Text(
        filter.label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          color: Colors.black,
        ),
      ),
      tilePadding: EdgeInsets.zero,
      initiallyExpanded: true,
      shape: Border.all(color: Colors.transparent),
      children: [
        RangeSlider(
          values: _currentPriceRange!,
          min: _minPrice!,
          max: _maxPrice!,
          activeColor: Colors.black,
          inactiveColor: Colors.grey.shade300,
          onChanged: (RangeValues values) {
            setState(() {
              _currentPriceRange = values;
              _minPriceController.text = values.start.toStringAsFixed(0);
              _maxPriceController.text = values.end.toStringAsFixed(0);
            });
          },
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  children: [
                    Text('QAR ', style: TextStyle(fontSize: 14.sp)),
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textAlign: TextAlign.right,
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              _minPrice != null &&
                              _currentPriceRange != null) {
                            double val = double.tryParse(value) ?? _minPrice!;
                            if (val >= _minPrice! &&
                                val <= _currentPriceRange!.end) {
                              setState(() {
                                _currentPriceRange = RangeValues(
                                  val,
                                  _currentPriceRange!.end,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text('To', style: TextStyle(fontSize: 14.sp)),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  children: [
                    Text('QAR ', style: TextStyle(fontSize: 14.sp)),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textAlign: TextAlign.right,
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              _maxPrice != null &&
                              _currentPriceRange != null) {
                            double val = double.tryParse(value) ?? _maxPrice!;
                            if (val <= _maxPrice! &&
                                val >= _currentPriceRange!.start) {
                              setState(() {
                                _currentPriceRange = RangeValues(
                                  _currentPriceRange!.start,
                                  val,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
