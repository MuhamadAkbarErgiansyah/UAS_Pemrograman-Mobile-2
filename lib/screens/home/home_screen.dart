import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/product/product_card.dart';
import '../../data/models/product_model.dart';
import '../product/product_detail_screen.dart';
import '../product/products_list_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userModel = authProvider.userModel;
    final firebaseUser = authProvider.currentUser;

    // Priority: userModel displayName > Firebase user displayName > Guest
    final displayName =
        userModel?.displayName ?? firebaseUser?.displayName ?? 'Guest';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<ProductProvider>().loadAllProducts();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.hello,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SearchScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.search),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Notifications
                        },
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.textHint),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            AppStrings.searchProducts,
                            style: TextStyle(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Banner Carousel
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSizes.lg),
                  child: _BannerCarousel(),
                ),
              ),
              // Categories
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.categories,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _CategoriesSection(),
                    ],
                  ),
                ),
              ),
              // Featured Products
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: _SectionHeader(
                    title: AppStrings.featuredProducts,
                    onViewAll: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductsListScreen(
                            title: 'Featured Products',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Featured Products Grid
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const SliverToBoxAdapter(
                      child: Center(child: LoadingIndicator()),
                    );
                  }

                  final products = provider.allProducts.take(6).toList();

                  return SliverPadding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: AppSizes.sm,
                        mainAxisSpacing: AppSizes.sm,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = products[index];
                        return Consumer<WishlistProvider>(
                          builder: (context, wishlistProvider, _) {
                            return ProductCard(
                              product: product,
                              onTap: () => _navigateToDetail(product),
                              isFavorite:
                                  wishlistProvider.isInWishlist(product.id),
                              onFavorite: () {
                                wishlistProvider.toggleWishlist(product.id);
                              },
                            );
                          },
                        );
                      }, childCount: products.length),
                    ),
                  );
                },
              ),
              // Popular Products
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: _SectionHeader(
                    title: AppStrings.popularProducts,
                    onViewAll: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductsListScreen(
                            title: 'Popular Products',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Popular Products Horizontal List
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const SliverToBoxAdapter(
                      child: SizedBox(height: 200),
                    );
                  }

                  final products =
                      provider.allProducts.reversed.take(10).toList();

                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Container(
                            width: 160,
                            margin: EdgeInsets.only(
                              right:
                                  index < products.length - 1 ? AppSizes.sm : 0,
                            ),
                            child: ProductCard(
                              product: product,
                              onTap: () => _navigateToDetail(product),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xl)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  final List<Map<String, String>> banners = const [
    {
      'image':
          'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&h=400&fit=crop',
      'title': 'Summer Sale',
      'subtitle': 'Up to 50% off',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=400&fit=crop',
      'title': 'New Arrivals',
      'subtitle': 'Check out latest products',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=800&h=400&fit=crop',
      'title': 'Best Deals',
      'subtitle': 'Limited time offers',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: banners.length,
      itemBuilder: (context, index, _) {
        final banner = banners[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    banner['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_offer,
                                size: 50, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              banner['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              banner['subtitle']!,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // Banner text
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        banner['subtitle']!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        autoPlayInterval: const Duration(seconds: 4),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'Watch',
      'icon': Icons.watch,
      'collection': 'Watch',
      'image':
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200&h=200&fit=crop',
      'color': 0xFF6366F1,
    },
    {
      'name': 'Laptop',
      'icon': Icons.laptop,
      'collection': 'Laptop',
      'image':
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=200&h=200&fit=crop',
      'color': 0xFF8B5CF6,
    },
    {
      'name': 'Phone',
      'icon': Icons.phone_android,
      'collection': 'Phone',
      'image':
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=200&h=200&fit=crop',
      'color': 0xFFEC4899,
    },
    {
      'name': 'Audio',
      'icon': Icons.headphones,
      'collection': 'Audio',
      'image':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200&h=200&fit=crop',
      'color': 0xFF14B8A6,
    },
    {
      'name': 'Camera',
      'icon': Icons.camera_alt,
      'collection': 'Camera',
      'image':
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=200&h=200&fit=crop',
      'color': 0xFFF59E0B,
    },
    {
      'name': 'Gaming',
      'icon': Icons.sports_esports,
      'collection': 'Gaming',
      'image':
          'https://images.unsplash.com/photo-1612287230202-1ff1d85d1bdf?w=200&h=200&fit=crop',
      'color': 0xFFEF4444,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductsListScreen(
                    title: category['name'],
                    categoryId: category['collection'],
                  ),
                ),
              );
            },
            child: Container(
              width: 85,
              margin: EdgeInsets.only(
                right: index < categories.length - 1 ? AppSizes.sm : 0,
              ),
              child: Column(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Color(category['color']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(
                        color: Color(category['color']).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusLg - 2),
                      child: Image.network(
                        category['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          category['icon'],
                          color: Color(category['color']),
                          size: 28,
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Icon(
                              category['icon'],
                              color: Color(category['color']),
                              size: 28,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    category['name'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(AppStrings.viewAll),
          ),
      ],
    );
  }
}
