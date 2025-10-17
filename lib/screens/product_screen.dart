import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';
import '../widgets/product_card.dart';
import '../widgets/product_preview_modal.dart';
import '../data/product_data.dart';
import '../cubit/product_screen_cubit/product_screen_cubit.dart';
import '../cubit/cart_cubit/cart_cubit.dart';
import '../models/cart_item.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  final List<String> sortOptions = const [
    'Featured',
    'Best selling',
    'Alphabetically, A-Z',
    'Alphabetically, Z-A',
    'Price, low to high',
    'Price, high to low',
    'Date, old to new',
    'Date, new to old',
  ];

  final List<String> brands = const [
    'Anker',
    'Electronic Arts',
    'HDD',
    'iConnect Qatar',
    'Apple',
    'Aukey',
    'Cellularline',
    'CMF',
    'Corsair',
    'Cougar',
    'ENET',
  ];

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductScreenCubit(),
      child: BlocBuilder<ProductScreenCubit, ProductScreenState>(
        builder: (context, state) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.grey[50],
            drawer: BlocProvider.value(
              value: context.read<ProductScreenCubit>(),
              child: FilterDrawer(
                priceRange: state.priceRange,
                selectedBrands: state.selectedBrands,
                availabilityFilters: state.availabilityFilters,
                brands: brands,
                onApplyFilters: (newPriceRange, newBrands, newAvailability) {
                  context.read<ProductScreenCubit>().updateFilters(
                    priceRange: newPriceRange,
                    selectedBrands: newBrands,
                    availabilityFilters: newAvailability,
                  );
                },
              ),
            ),
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'PRODUCTS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      ConstantWidgets.hight20(context),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.filter_list, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Filter'),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Sort Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showSortBottomSheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(state.selectedSort),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Selected Filters Display
                if (_hasActiveFilters(state))
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _buildFilterChips(context, state),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<ProductScreenCubit>().clearFilters();
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Products Grid/List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child:
                        state.isGridView
                            ? GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              itemCount: ProductData.products.length,
                              itemBuilder: (context, index) {
                                final product = ProductData.products[index];
                                return BlocBuilder<CartCubit, CartState>(
                                  builder: (context, cartState) {
                                    final isInCart = cartState.items.any((item) => item.id == product['id']);
                                    return ProductCard(
                                      imageUrl: product['imageUrl'],
                                      productName: product['productName'],
                                      description: product['description'],
                                      originalPrice: product['originalPrice'],
                                      discountedPrice: product['discountedPrice'],
                                      productId: product['id'],
                                      offerText: product['offerText'],
                                      isInCart: isInCart,
                                      onTap: () {},
                                      onAddToCart: () {
                                        final cartItem = CartItem(
                                          id: product['id'],
                                          imageUrl: product['imageUrl'],
                                          productName: product['productName'],
                                          description: product['description'],
                                          originalPrice: product['originalPrice'],
                                          discountedPrice: product['discountedPrice'],
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
                                );
                              },
                            )
                            : ListView.builder(
                              itemCount: ProductData.products.length,
                              itemBuilder: (context, index) {
                                final product = ProductData.products[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Image.network(
                                      product['imageUrl'],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(product['productName']),
                                    subtitle: Text(product['description']),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          product['discountedPrice'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppPalette.greenColor,
                                          ),
                                        ),
                                        if (product['originalPrice'] !=
                                            product['discountedPrice'])
                                          Text(
                                            product['originalPrice'],
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    final cubit = context.read<ProductScreenCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(1)),
      ),
      builder:
          (context) => BlocProvider.value(
            value: cubit,
            child: SortBottomSheet(
              currentSort: cubit.state.selectedSort,
              sortOptions: sortOptions,
              onSortSelected: (sort) {
                cubit.updateSort(sort);
                Navigator.pop(context);
              },
            ),
          ),
    );
  }

  bool _hasActiveFilters(ProductScreenState state) {
    return state.priceRange.start != 0 ||
        state.priceRange.end != 14999 ||
        state.selectedBrands.isNotEmpty ||
        state.availabilityFilters.isNotEmpty;
  }

  List<Widget> _buildFilterChips(
    BuildContext context,
    ProductScreenState state,
  ) {
    List<Widget> chips = [];

    // Price range filter
    if (state.priceRange.start != 0 || state.priceRange.end != 14999) {
      chips.add(
        Chip(
          label: Text(
            'QAR ${state.priceRange.start.round()} - QAR ${state.priceRange.end.round()}',
            style: const TextStyle(fontSize: 12),
          ),
          onDeleted: () {
            context.read<ProductScreenCubit>().updateFilters(
              priceRange: const RangeValues(0, 14999),
            );
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    // Brand filters
    for (String brand in state.selectedBrands) {
      chips.add(
        Chip(
          label: Text(brand, style: const TextStyle(fontSize: 12)),
          onDeleted: () {
            final newBrands = Set<String>.from(state.selectedBrands);
            newBrands.remove(brand);
            context.read<ProductScreenCubit>().updateFilters(
              selectedBrands: newBrands,
            );
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    // Availability filters
    for (String availability in state.availabilityFilters) {
      chips.add(
        Chip(
          label: Text(availability, style: const TextStyle(fontSize: 12)),
          onDeleted: () {
            final newAvailability = Set<String>.from(state.availabilityFilters);
            newAvailability.remove(availability);
            context.read<ProductScreenCubit>().updateFilters(
              availabilityFilters: newAvailability,
            );
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    return chips;
  }
}

class FilterDrawer extends StatefulWidget {
  final RangeValues priceRange;
  final Set<String> selectedBrands;
  final Set<String> availabilityFilters;
  final Function(RangeValues, Set<String>, Set<String>) onApplyFilters;
  final List<String> brands;

  const FilterDrawer({
    super.key,
    required this.priceRange,
    required this.selectedBrands,
    required this.availabilityFilters,
    required this.onApplyFilters,
    required this.brands,
  });

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late RangeValues _priceRange;
  late Set<String> _selectedBrands;
  late Set<String> _availabilityFilters;

  @override
  void initState() {
    super.initState();
    _priceRange = widget.priceRange;
    _selectedBrands = Set.from(widget.selectedBrands);
    _availabilityFilters = Set.from(widget.availabilityFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppPalette.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                const Text(
                  'Filters',
                  style: TextStyle( fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Availability',
                    child: Column(
                      children: [
                        _buildCheckboxTile(
                          'In stock',
                          _availabilityFilters.contains('In stock'),
                          (value) {
                            setState(() {
                              if (value!) {
                                _availabilityFilters.add('In stock');
                              } else {
                                _availabilityFilters.remove('In stock');
                              }
                            });
                          },
                        ),
                        _buildCheckboxTile(
                          'Out of stock',
                          _availabilityFilters.contains('Out of stock'),
                          (value) {
                            setState(() {
                              if (value!) {
                                _availabilityFilters.add('Out of stock');
                              } else {
                                _availabilityFilters.remove('Out of stock');
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Price Section
                  _buildSection(
                    title: 'Price',
                    child: Column(
                      children: [
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 14999,
                          divisions: 100,
                          onChanged: (values) {
                            setState(() {
                              _priceRange = values;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('ر.ق ${_priceRange.start.round()}'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text('To'),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('ر.ق ${_priceRange.end.round()}'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Brands Section
                  _buildSection(
                    title: 'By Brands',
                    child: Column(
                      children:
                          widget.brands.map((brand) {
                            return _buildCheckboxTile(
                              brand,
                              _selectedBrands.contains(brand),
                              (value) {
                                setState(() {
                                  if (value!) {
                                    _selectedBrands.add(brand);
                                  } else {
                                    _selectedBrands.remove(brand);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _priceRange = const RangeValues(0, 14999);
                        _selectedBrands.clear();
                        _availabilityFilters.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters(
                        _priceRange,
                        _selectedBrands,
                        _availabilityFilters,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.greenColor,
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_up),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildCheckboxTile(
    String title,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class SortBottomSheet extends StatelessWidget {
  final String currentSort;
  final List<String> sortOptions;
  final Function(String) onSortSelected;

  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.sortOptions,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Text(
                  'Sort by',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Options List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sortOptions.length,
              itemBuilder: (context, index) {
                final option = sortOptions[index];
                return ListTile(
                  title: Text(option),
                  trailing:
                      currentSort == option
                          ? const Icon(
                            Icons.check,
                            color: AppPalette.greenColor,
                          )
                          : null,
                  onTap: () => onSortSelected(option),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
