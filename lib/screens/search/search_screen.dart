import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/product_provider.dart';
import '../../data/models/product_model.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/product/product_card.dart';
import '../product/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      context.read<ProductProvider>().clearSearch();
      return;
    }
    context.read<ProductProvider>().searchProducts(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearch,
          onSubmitted: _onSearch,
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textHint),
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                context.read<ProductProvider>().clearSearch();
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (_searchController.text.isEmpty) {
            return _buildSuggestions(context, provider);
          }

          if (provider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (provider.searchResults.isEmpty) {
            return EmptyState(
              icon: Icons.search_off,
              title: 'No Results Found',
              subtitle: 'Try a different search term',
            );
          }

          return _buildResults(provider.searchResults);
        },
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, ProductProvider provider) {
    final recentProducts = provider.products.take(5).toList();

    if (recentProducts.isEmpty) {
      return const Center(
        child: Text('Start typing to search products...'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Text(
          'Popular Products',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSizes.md),
        ...recentProducts.map((product) => ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: Image.network(
                  product.images.isNotEmpty ? product.images.first : '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    color: AppColors.border,
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              title: Text(product.name),
              subtitle: Text(product.category ?? 'Uncategorized'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
            )),
      ],
    );
  }

  Widget _buildResults(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppSizes.sm,
        mainAxisSpacing: AppSizes.sm,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }
}
