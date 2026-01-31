import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../services/firestore_service.dart';
import '../../data/models/order_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<OrderStatus> _statusFilters = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.shipped,
    OrderStatus.delivered,
    OrderStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar Header
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _statusFilters.map((status) {
              return Tab(text: status.name.toUpperCase());
            }).toList(),
          ),
        ),
        // Tab Content
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: FirestoreService().getAllOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingIndicator());
              }

              if (snapshot.hasError) {
                return EmptyState(
                  icon: Icons.error_outline,
                  title: 'Error',
                  message: 'Failed to load orders: ${snapshot.error}',
                );
              }

              final allOrders = snapshot.data ?? [];

              return TabBarView(
                controller: _tabController,
                children: _statusFilters.map((status) {
                  final filteredOrders = allOrders
                      .where((order) => order.status == status)
                      .toList();

                  if (filteredOrders.isEmpty) {
                    return EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: 'No Orders',
                      message: 'No ${status.name} orders found',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _AdminOrderCard(
                        order: order,
                        onStatusChange: (newStatus) =>
                            _updateOrderStatus(order, newStatus),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _updateOrderStatus(
    OrderModel order,
    OrderStatus newStatus,
  ) async {
    try {
      await FirestoreService().updateOrderStatus(order.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to ${newStatus.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(OrderStatus) onStatusChange;

  const _AdminOrderCard({required this.order, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    _buildStatusChip(order.status),
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  Formatters.dateTime(order.createdAt),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Customer Info
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.person_outline,
                  order.shippingAddress.recipientName,
                ),
                _buildInfoRow(
                  Icons.phone_outlined,
                  order.shippingAddress.phone,
                ),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  order.shippingAddress.fullAddress,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Order Summary
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} item(s)',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  Formatters.currency(order.total),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
          // Actions
          if (order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled)
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Update Status',
                      Icons.update,
                      () => _showStatusDialog(context),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Cancel',
                      Icons.cancel_outlined,
                      () => onStatusChange(OrderStatus.cancelled),
                      isDestructive: true,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        break;
      case OrderStatus.processing:
        color = Colors.purple;
        break;
      case OrderStatus.shipped:
        color = Colors.indigo;
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        break;
      case OrderStatus.refunded:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: AppSizes.xs),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.primary,
          fontSize: 12,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: OrderStatus.values
                .where((s) => s != OrderStatus.cancelled)
                .map((status) {
              return ListTile(
                title: Text(status.name.toUpperCase()),
                leading: Radio<OrderStatus>(
                  value: status,
                  groupValue: order.status,
                  onChanged: (value) {
                    Navigator.pop(context);
                    if (value != null) {
                      onStatusChange(value);
                    }
                  },
                ),
                onTap: () {
                  Navigator.pop(context);
                  onStatusChange(status);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
