import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/voucher_service.dart';
import '../../data/models/order_model.dart';
import '../../data/models/address_model.dart';
import '../../data/models/voucher_model.dart';
import '../orders/orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingAddresses = true;

  // Saved addresses
  List<AddressModel> _savedAddresses = [];
  AddressModel? _selectedAddress;

  // Address form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _notesController = TextEditingController();

  // Voucher
  final _voucherController = TextEditingController();
  final VoucherService _voucherService = VoucherService();
  VoucherModel? _appliedVoucher;
  double _voucherDiscount = 0;
  bool _isValidatingVoucher = false;
  String? _voucherError;

  String _selectedPayment = 'COD';

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      setState(() => _isLoadingAddresses = false);
      return;
    }

    try {
      final firestoreService = FirestoreService();
      final addresses = await firestoreService.getUserAddresses(auth.user!.uid);

      setState(() {
        _savedAddresses = addresses;
        _isLoadingAddresses = false;

        // Auto-select default address or first address
        if (addresses.isNotEmpty) {
          final defaultAddress = addresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => addresses.first,
          );
          _selectAddress(defaultAddress);
        }
      });
    } catch (e) {
      setState(() => _isLoadingAddresses = false);
    }
  }

  void _selectAddress(AddressModel address) {
    setState(() {
      _selectedAddress = address;
      _nameController.text = address.recipientName;
      _phoneController.text = address.phone;
      _addressController.text = address.streetAddress;
      _cityController.text = address.city;
      _provinceController.text = address.state;
      _postalCodeController.text = address.postalCode;
      if (address.notes != null) {
        _notesController.text = address.notes!;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _notesController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _validateVoucher() async {
    final code = _voucherController.text.trim();
    if (code.isEmpty) {
      setState(() => _voucherError = 'Masukkan kode voucher');
      return;
    }

    setState(() {
      _isValidatingVoucher = true;
      _voucherError = null;
    });

    try {
      final cart = context.read<CartProvider>();
      final voucher =
          await _voucherService.validateVoucher(code, cart.subtotal);

      if (voucher != null) {
        // Calculate discount
        double discount = cart.subtotal * voucher.discountPercent / 100;
        if (voucher.maxDiscount != null && discount > voucher.maxDiscount!) {
          discount = voucher.maxDiscount!;
        }

        setState(() {
          _appliedVoucher = voucher;
          _voucherDiscount = discount;
          _voucherError = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '🎉 Voucher ${voucher.code} berhasil digunakan! Hemat ${Formatters.currency(discount)}'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        setState(() {
          _voucherError = 'Voucher tidak valid atau tidak memenuhi syarat';
          _appliedVoucher = null;
          _voucherDiscount = 0;
        });
      }
    } catch (e) {
      setState(() {
        _voucherError = 'Gagal memvalidasi voucher';
        _appliedVoucher = null;
        _voucherDiscount = 0;
      });
    } finally {
      setState(() => _isValidatingVoucher = false);
    }
  }

  void _removeVoucher() {
    setState(() {
      _appliedVoucher = null;
      _voucherDiscount = 0;
      _voucherController.clear();
      _voucherError = null;
    });
  }

  double get _totalWithVoucher {
    final cart = context.read<CartProvider>();
    return cart.total - _voucherDiscount;
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final cart = context.read<CartProvider>();
      final firestoreService = FirestoreService();

      final address = AddressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: 'Shipping',
        recipientName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        streetAddress: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _provinceController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        isDefault: true,
      );

      final orderItems = cart.items
          .map((item) => OrderItemModel(
                productId: item.productId,
                productName: item.productName,
                productImage: item.productImage,
                price: item.price,
                quantity: item.quantity,
              ))
          .toList();

      final order = OrderModel(
        id: '',
        userId: auth.user!.uid,
        items: orderItems,
        subtotal: cart.subtotal,
        shippingFee: cart.shippingFee,
        discount: _voucherDiscount,
        total: _totalWithVoucher,
        status: OrderStatus.pending,
        shippingAddress: address,
        paymentMethod: _selectedPayment,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final orderId = await firestoreService.createOrder(order);

      // Apply voucher if used
      if (_appliedVoucher != null) {
        await _voucherService.applyVoucher(_appliedVoucher!.id, orderId);
      }

      await cart.clearCart();

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 64,
        ),
        title: const Text('Order Placed!'),
        content: const Text(
          'Your order has been placed successfully. You can track your order in My Orders.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
            child: const Text('View Orders'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.checkout),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _placeOrder();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).pop();
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSizes.md),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _currentStep == 2 ? 'Place Order' : 'Continue'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: AppSizes.md),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Address
            Step(
              title: const Text('Shipping Address'),
              content: _buildAddressForm(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            // Step 2: Payment
            Step(
              title: const Text('Payment Method'),
              content: _buildPaymentSelection(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            // Step 3: Review
            Step(
              title: const Text('Review Order'),
              content: _buildOrderSummary(cart),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressForm() {
    return Column(
      children: [
        // Saved Addresses Dropdown
        if (_isLoadingAddresses)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSizes.md),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_savedAddresses.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bookmark, color: AppColors.primary, size: 18),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      'Pilih Alamat Tersimpan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                ...(_savedAddresses.map((address) => InkWell(
                      onTap: () => _selectAddress(address),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: AppSizes.xs),
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: _selectedAddress?.id == address.id
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSm),
                          border: Border.all(
                            color: _selectedAddress?.id == address.id
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedAddress?.id == address.id
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        address.recipientName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (address.isDefault) ...[
                                        const SizedBox(width: AppSizes.xs),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.success,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Default',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    address.phone,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${address.streetAddress}, ${address.city}',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const Divider(),
          const Text(
            'Atau isi manual:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppSizes.md),
        ],

        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Recipient Name *',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) => v?.isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (v) => v?.isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Street Address *',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: (v) => v?.isEmpty == true ? 'Required' : null,
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City *'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: TextFormField(
                controller: _provinceController,
                decoration: const InputDecoration(labelText: 'Province *'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _postalCodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Postal Code'),
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            hintText: 'e.g., Leave at the door',
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSelection() {
    return Column(
      children: [
        _PaymentOption(
          title: 'Cash on Delivery',
          subtitle: 'Pay when you receive your order',
          icon: Icons.money,
          value: 'COD',
          groupValue: _selectedPayment,
          onChanged: (v) => setState(() => _selectedPayment = v!),
        ),
        _PaymentOption(
          title: 'Bank Transfer',
          subtitle: 'Transfer to our bank account',
          icon: Icons.account_balance,
          value: 'Bank Transfer',
          groupValue: _selectedPayment,
          onChanged: (v) => setState(() => _selectedPayment = v!),
        ),
        _PaymentOption(
          title: 'E-Wallet',
          subtitle: 'GoPay, OVO, DANA, etc.',
          icon: Icons.wallet,
          value: 'E-Wallet',
          groupValue: _selectedPayment,
          onChanged: (v) => setState(() => _selectedPayment = v!),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Items
        ...cart.items.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: Image.network(
                  item.productImage,
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
              title: Text(item.productName),
              subtitle: Text('Qty: ${item.quantity}'),
              trailing: Text(Formatters.currency(item.totalPrice)),
            )),
        const Divider(),

        // Voucher Input Section
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_offer, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Punya Kode Voucher?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              if (_appliedVoucher != null) ...[
                // Show applied voucher
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _appliedVoucher!.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            Text(
                              'Hemat ${Formatters.currency(_voucherDiscount)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.error),
                        onPressed: _removeVoucher,
                        tooltip: 'Hapus voucher',
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Voucher input
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _voucherController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'Masukkan kode voucher',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          errorText: _voucherError,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isValidatingVoucher ? null : _validateVoucher,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      child: _isValidatingVoucher
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Pakai'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),

        _SummaryRow(
            label: AppStrings.subtotal,
            value: Formatters.currency(cart.subtotal)),
        const SizedBox(height: AppSizes.xs),
        _SummaryRow(
            label: AppStrings.shippingFee,
            value: Formatters.currency(cart.shippingFee)),
        if (_voucherDiscount > 0) ...[
          const SizedBox(height: AppSizes.xs),
          _SummaryRow(
            label: 'Diskon Voucher',
            value: '-${Formatters.currency(_voucherDiscount)}',
            isDiscount: true,
          ),
        ],
        const Divider(),
        _SummaryRow(
          label: AppStrings.total,
          value: Formatters.currency(_totalWithVoucher),
          isTotal: true,
        ),
        const SizedBox(height: AppSizes.md),
        // Shipping info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ship to: ${_nameController.text}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${_addressController.text}, ${_cityController.text}'),
                Text('Payment: $_selectedPayment'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(icon,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: AppSizes.sm),
            Text(title),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(subtitle),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isDiscount;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)
              : isDiscount
                  ? TextStyle(color: AppColors.success)
                  : null,
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  )
              : isDiscount
                  ? TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    )
                  : Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
