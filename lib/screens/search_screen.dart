import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductEntity> _searchResults = [];
  bool _isSearching = false;
  bool _showPopularSearches = true;
  bool _isLoading = false;
  String? _errorMessage;
  String _lastSearchQuery = '';

  // Popular search suggestions
  final List<String> _popularSearches = [
    'Smartphones',
    'headphones',
    'iphone',
    'samsung',
  ];

  // Search suggestions based on input
  final List<String> _searchSuggestions = [
    'i phone 17 pro max',
    'i phone 17',
    'i phone 16 pro',
    'i phone 16 pro 256gb',
    'i phone 17 pro',
  ];

  @override
  void initState() {
    super.initState();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _showPopularSearches = true;
        _isLoading = false;
        _errorMessage = null;
        _lastSearchQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showPopularSearches = false;
      _isLoading = true;
      _errorMessage = null;
      _lastSearchQuery = query;
    });

    // Trigger search using ProductBloc with query parameter
    context.read<ProductBloc>().add(
      LoadProductsRequested(first: 50, query: query),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
      _isSearching = false;
      _showPopularSearches = true;
      _isLoading = false;
      _errorMessage = null;
      _lastSearchQuery = '';
    });
  }

  void _selectPopularSearch(String search) {
    _searchController.text = search;
    _performSearch(search);
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.whiteColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Search our store',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black87,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _performSearch,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search products',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? GestureDetector(
                                onTap: _clearSearch,
                                child: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppPalette.blueColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Content Area
                Expanded(
                  child:
                      _showPopularSearches && !_isSearching
                          ? _buildPopularSearchesView()
                          : _searchController.text.isNotEmpty &&
                              _searchController.text.length < 3
                          ? _buildSearchSuggestions()
                          : _buildSearchResults(),
                ),
              ],
            ),
          ),
          const WhatsAppFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildPopularSearchesView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Searches:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _popularSearches.map((search) {
                  return GestureDetector(
                    onTap: () => _selectPopularSearch(search),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        search,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    // Show iPhone-related suggestions when user types "i ph"
    if (_searchController.text.toLowerCase().contains('i ph')) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Suggestions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ..._searchSuggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => _selectSuggestion(suggestion),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSearchResults() {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        // Only update if we're actively searching
        if (!_isSearching || _lastSearchQuery.isEmpty) return;

        // Handle loading state
        if (state.products.status == Status.loading) {
          if (!_isLoading) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          }
        }
        // Handle completed state
        else if (state.products.status == Status.completed) {
          final products = state.products.data ?? [];
          setState(() {
            _searchResults = products;
            _isLoading = false;
            _errorMessage = null;
          });
        }
        // Handle error state
        else if (state.products.status == Status.error) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.products.message ?? 'An error occurred';
          });
        }
      },
      child: _buildSearchResultsContent(),
    );
  }

  Widget _buildSearchResultsContent() {
    // Show loading state
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppPalette.blueColor),
            SizedBox(height: 16),
            Text(
              'Searching products...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show error state
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.blueColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show no results message
    if (_searchResults.isEmpty && _isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show search results
    return Column(
      children: [
        // Products header
        if (_searchResults.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Text(
              'Products (${_searchResults.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

        // Search results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return GestureDetector(
      onTap: () {
        print(
          '🔍 Navigating to product details with handle: ${product.handle}',
        );
        print('🔍 Product title: ${product.title}');
        print('🔍 Product ID: ${product.id}');
        Navigator.pushNamed(
          context,
          '/product_details',
          arguments: {'productHandle': product.handle},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.featuredImage ?? product.images.first,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppPalette.blueColor,
                          ),
                        ),
                      ),
                  errorWidget: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${product.currencyCode} ${product.minPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (product.hasDiscount &&
                          product.compareAtPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${product.currencyCode} ${product.compareAtPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      if (product.hasDiscount &&
                          product.discountPercentage != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product.discountPercentage!.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
