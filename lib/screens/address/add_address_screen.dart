import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/address_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../core/utils/validators.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddAddressScreen({super.key, this.address});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Indonesia');

  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _isDefault = false;
  bool _isGettingLocation = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _populateForm(widget.address!);
    }
  }

  void _populateForm(AddressModel address) {
    _labelController.text = address.label ?? '';
    _recipientController.text = address.recipientName;
    _phoneController.text = address.phone;
    _streetController.text = address.streetAddress;
    _cityController.text = address.city;
    _stateController.text = address.state;
    _postalCodeController.text = address.postalCode;
    _countryController.text = address.country;
    _isDefault = address.isDefault;
    _latitude = address.latitude;
    _longitude = address.longitude;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      // For web, check if location services are available
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled. Please enable GPS.');
        setState(() => _isGettingLocation = false);
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError(
              'Location permission denied. Please allow location access.');
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError(
            'Location permission permanently denied. Please enable in browser settings.');
        setState(() => _isGettingLocation = false);
        return;
      }

      // Get position with web-compatible settings
      Position position;
      if (kIsWeb) {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } else {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      }

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Reverse geocoding
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _streetController.text =
                '${place.street ?? ''} ${place.subLocality ?? ''}'.trim();
            _cityController.text =
                place.locality ?? place.subAdministrativeArea ?? '';
            _stateController.text = place.administrativeArea ?? '';
            _postalCodeController.text = place.postalCode ?? '';
            _countryController.text = place.country ?? 'Indonesia';
          });
          _showSuccess('Location detected successfully');
        } else {
          _showSuccess(
              'Location coordinates saved. Please fill address manually.');
        }
      } catch (geocodeError) {
        // Geocoding failed but we still have coordinates
        _showSuccess(
            'Got coordinates (${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}). Please fill address manually.');
      }
    } catch (e) {
      String errorMsg = 'Failed to get location';
      if (e.toString().contains('permission')) {
        errorMsg = 'Location permission denied';
      } else if (e.toString().contains('timeout')) {
        errorMsg = 'Location request timed out. Please try again.';
      } else if (kIsWeb) {
        errorMsg =
            'Location not available. Make sure you\'re using HTTPS and have allowed location access.';
      }
      _showError(errorMsg);
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final address = AddressModel(
        id: widget.address?.id ?? '',
        label: _labelController.text.trim(),
        recipientName: _recipientController.text.trim(),
        phone: _phoneController.text.trim(),
        streetAddress: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _countryController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        isDefault: _isDefault,
      );

      if (widget.address != null) {
        await _firestoreService.updateAddress(userId, address);
      } else {
        await _firestoreService.addAddress(userId, address);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError('Failed to save address: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add Address'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            // Get Location Button
            OutlinedButton.icon(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: _isGettingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isGettingLocation
                  ? 'Getting Location...'
                  : 'Use Current Location'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(AppSizes.md),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Label
            CustomTextField(
              label: 'Label (Optional)',
              hint: 'e.g., Home, Office',
              controller: _labelController,
              prefixIcon: Icons.label_outline,
            ),
            const SizedBox(height: AppSizes.md),

            // Recipient Name
            CustomTextField(
              label: 'Recipient Name',
              hint: 'Full name',
              controller: _recipientController,
              prefixIcon: Icons.person_outline,
              validator: Validators.name,
            ),
            const SizedBox(height: AppSizes.md),

            // Phone
            CustomTextField(
              label: 'Phone Number',
              hint: '08xxxxxxxxxx',
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
            ),
            const SizedBox(height: AppSizes.md),

            // Street Address
            CustomTextField(
              label: 'Street Address',
              hint: 'Street name, building, etc.',
              controller: _streetController,
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (value) =>
                  Validators.required(value, 'Street address'),
            ),
            const SizedBox(height: AppSizes.md),

            // City & State
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'City',
                    hint: 'City',
                    controller: _cityController,
                    prefixIcon: Icons.location_city,
                    validator: (value) => Validators.required(value, 'City'),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: CustomTextField(
                    label: 'State/Province',
                    hint: 'Province',
                    controller: _stateController,
                    prefixIcon: Icons.map,
                    validator: (value) => Validators.required(value, 'State'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // Postal Code & Country
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Postal Code',
                    hint: '12345',
                    controller: _postalCodeController,
                    prefixIcon: Icons.markunread_mailbox_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        Validators.required(value, 'Postal code'),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: CustomTextField(
                    label: 'Country',
                    hint: 'Country',
                    controller: _countryController,
                    prefixIcon: Icons.flag,
                    validator: (value) => Validators.required(value, 'Country'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // Default Address Checkbox
            CheckboxListTile(
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value ?? false),
              title: const Text('Set as default address'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: AppSizes.lg),

            // Save Button
            CustomButton(
              text: isEditing ? 'Update Address' : 'Save Address',
              onPressed: _saveAddress,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
