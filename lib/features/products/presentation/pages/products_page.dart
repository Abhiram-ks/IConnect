import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_bloc.dart';
import 'package:iconnect/features/products/presentation/bloc/product_event.dart';
import 'package:iconnect/features/products/presentation/bloc/product_state.dart';
import 'package:iconnect/features/products/presentation/widgets/product_grid_widget.dart';

/// Products Page - Example of how to use ProductBloc
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load products when page initializes
    context.read<ProductBloc>().add(LoadProductsRequested());

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<ProductBloc>().state;
      if (state is ProductsLoaded && state.hasNextPage) {
        context.read<ProductBloc>().add(
              LoadProductsRequested(
                after: state.endCursor,
                loadMore: true,
              ),
            );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductBloc>().add(RefreshProductsRequested());
        },
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductBloc>().add(LoadProductsRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ProductsLoaded || state is ProductLoadingMore) {
              final products = state is ProductsLoaded
                  ? state.products
                  : (state as ProductLoadingMore).currentProducts;

              if (products.isEmpty) {
                return const Center(
                  child: Text('No products found'),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ProductGridWidget(
                      products: products,
                      scrollController: _scrollController,
                    ),
                  ),
                  if (state is ProductLoadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              );
            }

            return const Center(
              child: Text('No products loaded'),
            );
          },
        ),
      ),
    );
  }
}

