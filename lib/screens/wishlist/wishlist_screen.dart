import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/product/product_card.dart';
import '../product/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlist, child) {
              if (wishlist.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showClearConfirmation(context),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear Wishlist',
              );
            },
          ),
        ],
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          if (wishlist.items.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_outline,
              title: 'Your Wishlist is Empty',
              subtitle: 'Add items you love to your wishlist',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: AppSizes.sm,
              mainAxisSpacing: AppSizes.sm,
            ),
            itemCount: wishlist.items.length,
            itemBuilder: (context, index) {
              final product = wishlist.items[index];
              return Stack(
                children: [
                  ProductCard(
                    product: product,
                    isFavorite: true,
                    onFavorite: () {
                      wishlist.removeFromWishlist(product.id);
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: GestureDetector(
                      onTap: () => _addToCartAndRemove(context, product),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _addToCartAndRemove(BuildContext context, dynamic product) async {
    final cartProvider = context.read<CartProvider>();
    final wishlistProvider = context.read<WishlistProvider>();

    await cartProvider.addToCart(product);
    await wishlistProvider.removeFromWishlist(product.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              cartProvider.removeFromCart(product.id);
              wishlistProvider.addToWishlist(product.id);
            },
          ),
        ),
      );
    }
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text(
            'Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WishlistProvider>().clearWishlist();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
