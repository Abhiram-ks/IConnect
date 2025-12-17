import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/utils/api_response.dart';
import 'package:iconnect/features/products/domain/entities/product_entity.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/widgets/whatsapp_floating_button.dart';

/// Search Screen with Shopify product search
///
/// Search Implementation Notes:
/// - Uses Shopify's query parameter for product search
/// - Supports title:* prefix for more accurate title-based searches
/// - Multi-word searches use title: prefix to reduce fuzzy matching
/// - Single word searches use regular search across all product fields
/// - Shopify searches across: title, description, tags, product type, vendor
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ProductEntity> _searchResults = [];
  bool _isSearching = false;
  bool _showPopularSearches = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _lastSearchQuery = '';

  // Pagination state
  bool _hasNextPage = false;
  String? _endCursor;
  int _totalCount = 0;
  static const int _pageSize = 20;

  // Popular search suggestions
  // Note: These should match your actual product titles/types in Shopify
  final List<String> _popularSearches = [
    'smartphone',
    'iphone',
    'samsung',
    'airpods',
    'macbook',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Load more when user reaches near the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreResults();
    }
  }

  void _loadMoreResults() {
    if (_isLoadingMore || !_hasNextPage || _endCursor == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    context.read<ProductBloc>().add(
      SearchProductsRequested(
        query: _lastSearchQuery,
        first: _pageSize,
        after: _endCursor,
        loadMore: true,
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _showPopularSearches = true;
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = null;
        _lastSearchQuery = '';
        _hasNextPage = false;
        _endCursor = null;
        _totalCount = 0;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showPopularSearches = false;
      _isLoading = true;
      _isLoadingMore = false;
      _errorMessage = null;
      _lastSearchQuery = query;
      _searchResults = []; // Clear previous results
      _hasNextPage = false;
      _endCursor = null;
      _totalCount = 0;
    });

    // Use Shopify's dedicated search API for better results
    context.read<ProductBloc>().add(
      SearchProductsRequested(query: query, first: _pageSize),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
      _isSearching = false;
      _showPopularSearches = true;
      _isLoading = false;
      _isLoadingMore = false;
      _errorMessage = null;
      _lastSearchQuery = '';
      _hasNextPage = false;
      _endCursor = null;
      _totalCount = 0;
    });
  }

  void _selectPopularSearch(String search) {
    _searchController.text = search;
    _performSearch(search);
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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

  Widget _buildSearchResults() {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        // Only update if we're actively searching
        if (!_isSearching || _lastSearchQuery.isEmpty) return;

        // Handle loading state (only for initial load, not load more)
        if (state.searchResults.status == Status.loading && !_isLoadingMore) {
          if (!_isLoading) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          }
        }
        // Handle completed state
        else if (state.searchResults.status == Status.completed) {
          final products = state.searchResults.data ?? [];
          setState(() {
            _searchResults = products;
            _isLoading = false;
            _isLoadingMore = false;
            _errorMessage = null;
            _hasNextPage = state.searchHasNextPage;
            _endCursor = state.searchEndCursor;
            _totalCount = state.searchTotalCount;
          });
        }
        // Handle error state
        else if (state.searchResults.status == Status.error) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
            _errorMessage = state.searchResults.message ?? 'An error occurred';
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
        // Products header with count
        if (_searchResults.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _totalCount > 0
                      ? 'Products (${_searchResults.length} of $_totalCount)'
                      : 'Products (${_searchResults.length}${_hasNextPage ? '+' : ''})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (_hasNextPage)
                  Text(
                    'Scroll for more',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),

        // Search results list with pagination
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount:
                _searchResults.length +
                (_isLoadingMore || _hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom
              if (index == _searchResults.length) {
                return _buildLoadMoreIndicator();
              }
              final product = _searchResults[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppPalette.blueColor,
            ),
          ),
        ),
      );
    }

    if (_hasNextPage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextButton.icon(
            onPressed: _loadMoreResults,
            icon: const Icon(Icons.expand_more, color: AppPalette.blueColor),
            label: const Text(
              'Load more',
              style: TextStyle(color: AppPalette.blueColor),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProductCard(ProductEntity product) {
    return GestureDetector(
      onTap: () {
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
    _scrollController.dispose();
    super.dispose();
  }
}
