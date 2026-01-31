import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/address_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import 'add_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  final bool isSelecting;

  const AddressesScreen({
    super.key,
    this.isSelecting = false,
  });

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<AddressModel> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final addresses = await _firestoreService.getUserAddresses(userId);
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Addresses'),
        actions: [
          IconButton(
            onPressed: () => _navigateToAddAddress(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _addresses.isEmpty
              ? EmptyState(
                  icon: Icons.location_off,
                  title: 'No Addresses Yet',
                  subtitle: 'Add your shipping address',
                  actionText: 'Add Address',
                  onAction: () => _navigateToAddAddress(),
                )
              : RefreshIndicator(
                  onRefresh: _loadAddresses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      return _AddressCard(
                        address: address,
                        isSelecting: widget.isSelecting,
                        onTap: widget.isSelecting
                            ? () => Navigator.of(context).pop(address)
                            : null,
                        onEdit: () => _navigateToEditAddress(address),
                        onDelete: () => _deleteAddress(address),
                        onSetDefault: () => _setAsDefault(address),
                      );
                    },
                  ),
                ),
      floatingActionButton: _addresses.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _navigateToAddAddress(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _navigateToAddAddress() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    if (result == true) {
      _loadAddresses();
    }
  }

  void _navigateToEditAddress(AddressModel address) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(address: address),
      ),
    );
    if (result == true) {
      _loadAddresses();
    }
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final userId = context.read<AuthProvider>().user?.uid;
      if (userId != null) {
        await _firestoreService.deleteAddress(userId, address.id);
        _loadAddresses();
      }
    }
  }

  Future<void> _setAsDefault(AddressModel address) async {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId != null) {
      await _firestoreService.setDefaultAddress(userId, address.id);
      _loadAddresses();
    }
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool isSelecting;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.isSelecting,
    this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      address.label ?? 'Address',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                address.recipientName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                address.phone,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                address.fullAddress,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  if (!address.isDefault)
                    TextButton.icon(
                      onPressed: onSetDefault,
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Set as Default'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline,
                        size: 20, color: AppColors.error),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
