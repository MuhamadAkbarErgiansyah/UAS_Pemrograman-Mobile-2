import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../services/firestore_service.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _completedOrders = 0;
  int _cancelledOrders = 0;
  double _totalRevenue = 0;
  double _todayRevenue = 0;
  double _weekRevenue = 0;
  double _monthRevenue = 0;
  int _totalProducts = 0;
  int _lowStockProducts = 0;
  List<ProductModel> _topProducts = [];
  Map<String, int> _categoryStats = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      // Load products
      final products = await _firestoreService.getAllProducts();
      _totalProducts = products.length;
      _lowStockProducts = products.where((p) => p.stock < 10).length;

      // Category stats
      _categoryStats = {};
      for (var product in products) {
        final category = product.categoryId.isNotEmpty
            ? product.categoryId
            : 'Uncategorized';
        _categoryStats[category] = (_categoryStats[category] ?? 0) + 1;
      }

      // Top products by rating
      products.sort((a, b) => b.rating.compareTo(a.rating));
      _topProducts = products.take(5).toList();

      // Load orders
      final ordersStream = _firestoreService.getAllOrders();
      await ordersStream.first.then((orders) {
        _totalOrders = orders.length;
        _pendingOrders =
            orders.where((o) => o.status == OrderStatus.pending).length;
        _completedOrders =
            orders.where((o) => o.status == OrderStatus.delivered).length;
        _cancelledOrders =
            orders.where((o) => o.status == OrderStatus.cancelled).length;

        // Calculate revenue
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final weekAgo = today.subtract(const Duration(days: 7));
        final monthAgo = today.subtract(const Duration(days: 30));

        for (var order in orders) {
          if (order.status != OrderStatus.cancelled) {
            _totalRevenue += order.total;

            if (order.createdAt.isAfter(today)) {
              _todayRevenue += order.total;
            }
            if (order.createdAt.isAfter(weekAgo)) {
              _weekRevenue += order.total;
            }
            if (order.createdAt.isAfter(monthAgo)) {
              _monthRevenue += order.total;
            }
          }
        }
      });

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Analitik Toko',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ).animate().fadeIn().slideX(begin: -0.1),
                    const SizedBox(height: AppSizes.md),

                    // Revenue Cards
                    Text(
                      '💰 Pendapatan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: AppSizes.sm),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSizes.sm,
                      mainAxisSpacing: AppSizes.sm,
                      childAspectRatio: 1.5,
                      children: [
                        _RevenueCard(
                          title: 'Hari Ini',
                          amount: _todayRevenue,
                          icon: Icons.today,
                          color: Colors.blue,
                        )
                            .animate()
                            .fadeIn(delay: 150.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                        _RevenueCard(
                          title: 'Minggu Ini',
                          amount: _weekRevenue,
                          icon: Icons.date_range,
                          color: Colors.green,
                        )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                        _RevenueCard(
                          title: 'Bulan Ini',
                          amount: _monthRevenue,
                          icon: Icons.calendar_month,
                          color: Colors.orange,
                        )
                            .animate()
                            .fadeIn(delay: 250.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                        _RevenueCard(
                          title: 'Total',
                          amount: _totalRevenue,
                          icon: Icons.attach_money,
                          color: AppColors.primary,
                        )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                      ],
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // Order Stats
                    Text(
                      '📦 Status Pesanan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: AppSizes.sm),
                    _OrderStatsCard(
                      total: _totalOrders,
                      pending: _pendingOrders,
                      completed: _completedOrders,
                      cancelled: _cancelledOrders,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                    const SizedBox(height: AppSizes.lg),

                    // Product Stats
                    Text(
                      '📊 Statistik Produk',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(delay: 450.ms),
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total Produk',
                            value: _totalProducts.toString(),
                            icon: Icons.inventory_2,
                            color: Colors.blue,
                          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: _StatCard(
                            title: 'Stok Rendah',
                            value: _lowStockProducts.toString(),
                            icon: Icons.warning,
                            color: Colors.red,
                          ).animate().fadeIn(delay: 550.ms).slideX(begin: 0.2),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // Category Distribution
                    if (_categoryStats.isNotEmpty) ...[
                      Text(
                        '📁 Produk per Kategori',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: AppSizes.sm),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.md),
                          child: Column(
                            children: _categoryStats.entries.map((entry) {
                              final percentage =
                                  (entry.value / _totalProducts * 100).round();
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSizes.sm),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        entry.key.toUpperCase(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: LinearProgressIndicator(
                                        value: percentage / 100,
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          _getCategoryColor(entry.key),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    Text(
                                      '${entry.value} ($percentage%)',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2),
                    ],

                    const SizedBox(height: AppSizes.lg),

                    // Top Products
                    if (_topProducts.isNotEmpty) ...[
                      Text(
                        '⭐ Produk Rating Tertinggi',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ).animate().fadeIn(delay: 700.ms),
                      const SizedBox(height: AppSizes.sm),
                      Card(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _topProducts.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final product = _topProducts[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.1),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle:
                                  Text(Formatters.currency(product.finalPrice)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 750.ms).slideY(begin: 0.2),
                    ],

                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'watch':
        return Colors.blue;
      case 'laptop':
        return Colors.purple;
      case 'phone':
        return Colors.green;
      case 'audio':
        return Colors.orange;
      case 'camera':
        return Colors.red;
      case 'gaming':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

class _RevenueCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _RevenueCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            Formatters.compactCurrency(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStatsCard extends StatelessWidget {
  final int total;
  final int pending;
  final int completed;
  final int cancelled;

  const _OrderStatsCard({
    required this.total,
    required this.pending,
    required this.completed,
    required this.cancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pesanan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    total.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: _OrderStatusItem(
                    label: 'Pending',
                    count: pending,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _OrderStatusItem(
                    label: 'Selesai',
                    count: completed,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _OrderStatusItem(
                    label: 'Batal',
                    count: cancelled,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderStatusItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _OrderStatusItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
