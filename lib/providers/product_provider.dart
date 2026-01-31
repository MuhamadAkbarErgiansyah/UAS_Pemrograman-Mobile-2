import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _searchResults = [];
  List<ProductModel> _collectionProducts = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _selectedCategoryId;

  List<ProductModel> get products => _products;
  List<ProductModel> get allProducts => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get searchResults => _searchResults;
  List<ProductModel> get productsByCollection => _collectionProducts;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get selectedCategoryId => _selectedCategoryId;

  ProductProvider() {
    _init();
  }

  void _init() {
    // Listen to products from 'products' collection
    _firestoreService.getProducts().listen((products) {
      _products = products;
      notifyListeners();
    });

    // Also load products from existing collections (Watch, Laptop, etc)
    _loadExistingProducts();

    // Listen to categories
    _firestoreService.getCategories().listen((categories) {
      _categories = categories;
      notifyListeners();
    });
  }

  Future<void> _loadExistingProducts() async {
    // Load from all category collections including seeded ones
    final collections = [
      'Watch',
      'Laptop',
      'Phone',
      'Audio',
      'Camera',
      'Gaming',
      'products',
      'Admin'
    ];
    final allProducts = await _firestoreService.getAllProductsFromCollections(
      collections,
    );

    if (allProducts.isNotEmpty) {
      _featuredProducts = allProducts.take(10).toList();
      // Merge with existing products, avoiding duplicates
      final existingIds = _products.map((p) => p.id).toSet();
      final newProducts =
          allProducts.where((p) => !existingIds.contains(p.id)).toList();
      _products = [..._products, ...newProducts];
      notifyListeners();
    }
  }

  Future<void> loadAllProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadExistingProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductsByCollection(String collection) async {
    _isLoading = true;
    notifyListeners();

    try {
      _collectionProducts =
          await _firestoreService.getAllProductsFromCollections([collection]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  List<ProductModel> getProductsByCategory(String categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  Future<ProductModel?> getProductById(String productId) async {
    return await _firestoreService.getProductById(productId);
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // First try Firestore search
      _searchResults = await _firestoreService.searchProducts(query);

      // If no results from Firestore, search locally
      if (_searchResults.isEmpty && _products.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        _searchResults = _products.where((product) {
          return product.name.toLowerCase().contains(lowerQuery) ||
              (product.description?.toLowerCase().contains(lowerQuery) ??
                  false) ||
              (product.category?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadExistingProducts();
  }
}
