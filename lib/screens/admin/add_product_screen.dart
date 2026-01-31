import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../data/models/product_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _stockController = TextEditingController();

  String _selectedCategory = 'Watch';
  final List<String> _categories = [
    'Watch',
    'Laptop',
    'Phone',
    'Audio',
    'Camera',
    'Gaming',
  ];

  List<String> _existingImages = [];
  List<XFile> _newImages = [];
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadProductData();
    }
  }

  void _loadProductData() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _priceController.text = product.price.toString();
    _originalPriceController.text = product.originalPrice?.toString() ?? '';
    _stockController.text = product.stock.toString();
    _selectedCategory = product.category ?? 'Watch';
    _existingImages = List.from(product.images);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles);
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_existingImages.isEmpty && _newImages.isEmpty) {
      Helpers.showSnackBar(
        context,
        'Please add at least one image',
        isError: true,
      );
      return;
    }

    Helpers.unfocus(context);
    setState(() => _isLoading = true);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_isEditing ? 'Updating product...' : 'Saving product...'),
            const SizedBox(height: 8),
            Text(
              'Uploading ${_newImages.length} image(s)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );

    try {
      final firestoreService = FirestoreService();
      final storageService = StorageService();

      // Upload new images
      List<String> allImageUrls = List.from(_existingImages);

      for (final imageFile in _newImages) {
        Uint8List bytes;
        if (kIsWeb) {
          bytes = await imageFile.readAsBytes();
        } else {
          bytes = await File(imageFile.path).readAsBytes();
        }

        final imageUrl = await storageService.uploadProductImage(
          _selectedCategory,
          bytes,
          fileName:
              '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}',
        );
        allImageUrls.add(imageUrl);
      }

      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        originalPrice: _originalPriceController.text.isNotEmpty
            ? double.parse(_originalPriceController.text.trim())
            : null,
        images: allImageUrls,
        category: _selectedCategory,
        stock: int.parse(_stockController.text.trim()),
        rating: widget.product?.rating ?? 0,
        reviewCount: widget.product?.reviewCount ?? 0,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await firestoreService.updateProduct(product, _selectedCategory);
      } else {
        await firestoreService.addProduct(product, _selectedCategory);
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Helpers.showSnackBar(
          context,
          _isEditing
              ? 'Product updated successfully!'
              : 'Product added successfully!',
          isSuccess: true,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Helpers.showSnackBar(
          context,
          'Failed to save product: $e',
          isError: true,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Product' : 'Add Product')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Section
              Text(
                'Product Images',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.sm),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Existing Images
                    ..._existingImages.asMap().entries.map((entry) {
                      return _ImageTile(
                        imageUrl: entry.value,
                        onRemove: () => _removeExistingImage(entry.key),
                      );
                    }),
                    // New Images
                    ..._newImages.asMap().entries.map((entry) {
                      return _ImageTile(
                        imageFile: entry.value,
                        onRemove: () => _removeNewImage(entry.key),
                      );
                    }),
                    // Add Button
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: AppSizes.sm),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                          border: Border.all(
                            color: AppColors.border,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add Image',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              // Product Name
              CustomTextField(
                label: 'Product Name',
                hint: 'Enter product name',
                controller: _nameController,
                validator: Validators.required,
              ),
              const SizedBox(height: AppSizes.md),
              // Description
              CustomTextField(
                label: 'Description',
                hint: 'Enter product description',
                controller: _descriptionController,
                maxLines: 4,
                validator: Validators.required,
              ),
              const SizedBox(height: AppSizes.md),
              // Category
              Text(
                'Category',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: AppSizes.xs),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: AppSizes.md),
              // Price Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Price',
                      hint: '0',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: Validators.price,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: CustomTextField(
                      label: 'Original Price (Optional)',
                      hint: '0',
                      controller: _originalPriceController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              // Stock
              CustomTextField(
                label: 'Stock',
                hint: '0',
                controller: _stockController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.inventory,
                validator: Validators.required,
              ),
              const SizedBox(height: AppSizes.xl),
              // Save Button
              CustomButton(
                text: _isEditing ? 'Update Product' : 'Add Product',
                onPressed: _saveProduct,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String? imageUrl;
  final XFile? imageFile;
  final VoidCallback onRemove;

  const _ImageTile({this.imageUrl, this.imageFile, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: AppSizes.sm),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.background,
                      child: const Icon(Icons.image),
                    ),
                  )
                : kIsWeb
                    ? FutureBuilder<Uint8List>(
                        future: imageFile!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          }
                          return Container(
                            color: AppColors.background,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          );
                        },
                      )
                    : Image.file(
                        File(imageFile!.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
