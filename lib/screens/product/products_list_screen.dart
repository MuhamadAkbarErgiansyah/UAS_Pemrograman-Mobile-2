import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../data/models/product_model.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/product/product_card.dart';
import 'product_detail_screen.dart';

class ProductsListScreen extends StatefulWidget {
  final String? title;
  final String?
      categoryId; // This is actually the collection name (Watch, Laptop, etc)

  const ProductsListScreen({
    super.key,
    this.title,
    this.categoryId,
  });

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  bool _isGridView = true;
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (widget.categoryId != null) {
        // Load products from specific collection
        provider.loadProductsByCollection(widget.categoryId!);
      } else {
        provider.loadAllProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Products'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Name')),
              const PopupMenuItem(
                  value: 'price_low', child: Text('Price: Low to High')),
              const PopupMenuItem(
                  value: 'price_high', child: Text('Price: High to Low')),
              const PopupMenuItem(value: 'newest', child: Text('Newest First')),
            ],
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          List<ProductModel> products;
          if (widget.categoryId != null) {
            // Use products loaded from collection
            products = provider.productsByCollection;
          } else {
            products = provider.products;
          }

          if (products.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No Products Found',
              subtitle: 'Check back later for new products',
              actionText: 'Refresh',
              onAction: () {
                if (widget.categoryId != null) {
                  provider.loadProductsByCollection(widget.categoryId!);
                } else {
                  provider.loadAllProducts();
                }
              },
            );
          }

          // Sort products
          products = _sortProducts(products);

          if (_isGridView) {
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
                return Consumer<WishlistProvider>(
                  builder: (context, wishlistProvider, _) {
                    return ProductCard(
                      product: products[index],
                      onTap: () => _navigateToDetail(products[index]),
                      isFavorite:
                          wishlistProvider.isInWishlist(products[index].id),
                      onFavorite: () {
                        wishlistProvider.toggleWishlist(products[index].id);
                      },
                    );
                  },
                );
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _ProductListTile(
                product: products[index],
                onTap: () => _navigateToDetail(products[index]),
              );
            },
          );
        },
      ),
    );
  }

  List<ProductModel> _sortProducts(List<ProductModel> products) {
    final sorted = List<ProductModel>.from(products);
    switch (_sortBy) {
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        sorted.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
        break;
      case 'price_high':
        sorted.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
        break;
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sorted;
  }

  void _navigateToDetail(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductListTile({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          child: Image.network(
            product.images.isNotEmpty ? product.images.first : '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 60,
              height: 60,
              color: AppColors.border,
              child: const Icon(Icons.image),
            ),
          ),
        ),
        title: Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(product.category ?? 'Uncategorized'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rp ${product.finalPrice.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            if (product.hasDiscount && product.originalPrice != null)
              Text(
                'Rp ${product.originalPrice!.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textHint,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
