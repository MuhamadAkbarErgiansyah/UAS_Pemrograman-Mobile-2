import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../services/firestore_service.dart';
import '../../services/seed_products.dart';
import '../../widgets/common/loading_indicator.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _totalProducts = 0;
  int _totalOrders = 0;
  int _totalUsers = 0;
  double _totalRevenue = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final firestoreService = FirestoreService();

      // Load counts
      final products = await firestoreService.getAllProducts();
      final users = await firestoreService.getAllUsers();

      // Calculate revenue from orders
      double revenue = 0;
      int orderCount = 0;

      // For now, use sample data
      // In production, you would stream/fetch actual order data

      setState(() {
        _totalProducts = products.length;
        _totalUsers = users.length;
        _totalOrders = orderCount;
        _totalRevenue = revenue;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: LoadingIndicator())
        : RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  Text(
                    'Dashboard Admin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSizes.sm,
                    mainAxisSpacing: AppSizes.sm,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        icon: Icons.inventory_2_outlined,
                        title: 'Products',
                        value: _totalProducts.toString(),
                        color: Colors.blue,
                        onTap: () => _navigateTo(const AdminProductsScreen()),
                      ),
                      _StatCard(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Orders',
                        value: _totalOrders.toString(),
                        color: Colors.orange,
                        onTap: () => _navigateTo(const AdminOrdersScreen()),
                      ),
                      _StatCard(
                        icon: Icons.people_outline,
                        title: 'Users',
                        value: _totalUsers.toString(),
                        color: Colors.purple,
                        onTap: () => _navigateTo(const AdminUsersScreen()),
                      ),
                      _StatCard(
                        icon: Icons.attach_money,
                        title: 'Revenue',
                        value: Formatters.compactCurrency(_totalRevenue),
                        color: AppColors.success,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  _ActionCard(
                    icon: Icons.add_box_outlined,
                    title: 'Add New Product',
                    subtitle: 'Add a product to your store',
                    onTap: () => _navigateTo(const AdminProductsScreen()),
                  ),
                  _ActionCard(
                    icon: Icons.category_outlined,
                    title: 'Manage Categories',
                    subtitle: 'Organize your products',
                    onTap: () {},
                  ),
                  _ActionCard(
                    icon: Icons.local_offer_outlined,
                    title: 'Promotions',
                    subtitle: 'Create discounts and offers',
                    onTap: () {},
                  ),
                  _ActionCard(
                    icon: Icons.analytics_outlined,
                    title: 'Analytics',
                    subtitle: 'View store performance',
                    onTap: () {},
                  ),
                  _ActionCard(
                    icon: Icons.cloud_upload_outlined,
                    title: 'Seed Sample Products',
                    subtitle: 'Add sample products to all categories',
                    onTap: () => _seedProducts(),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> _seedProducts() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Seeding products...'),
          ],
        ),
      ),
    );

    try {
      await SeedProducts.seedAllProducts();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample products added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadDashboardData(); // Refresh counts
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to seed products: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(title, style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppColors.textHint, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
