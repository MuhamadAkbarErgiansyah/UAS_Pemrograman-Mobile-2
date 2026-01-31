import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../data/models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<String> _wishlistIds = [];
  List<ProductModel> _wishlistItems = [];
  String? _userId;
  StreamSubscription? _wishlistSubscription;
  bool _isInitialized = false;

  List<String> get wishlistIds => _wishlistIds;
  List<ProductModel> get items => _wishlistItems;
  int get itemCount => _wishlistIds.length;

  void initialize(String userId) {
    // Prevent re-initialization for same user
    if (_userId == userId && _isInitialized) return;

    // Cancel existing subscription if any
    _wishlistSubscription?.cancel();

    _userId = userId;
    _isInitialized = true;

    debugPrint('WishlistProvider: Initializing for user $userId');

    _wishlistSubscription = _firestoreService.getWishlist(userId).listen(
      (ids) {
        debugPrint('WishlistProvider: Received ${ids.length} wishlist items');
        _wishlistIds = ids;
        _loadWishlistItems();
        notifyListeners();
      },
      onError: (error) {
        debugPrint('WishlistProvider: Error listening to wishlist: $error');
      },
    );
  }

  Future<void> _loadWishlistItems() async {
    if (_wishlistIds.isEmpty) {
      _wishlistItems = [];
      notifyListeners();
      return;
    }

    final items = <ProductModel>[];
    for (final id in _wishlistIds) {
      final product = await _firestoreService.getProductById(id);
      if (product != null) {
        items.add(product);
      }
    }
    _wishlistItems = items;
    notifyListeners();
  }

  void clear() {
    _wishlistSubscription?.cancel();
    _wishlistIds = [];
    _wishlistItems = [];
    _userId = null;
    _isInitialized = false;
    notifyListeners();
  }

  bool isInWishlist(String productId) {
    return _wishlistIds.contains(productId);
  }

  Future<void> toggleWishlist(String productId) async {
    if (_userId == null) {
      debugPrint('WishlistProvider: Cannot toggle - userId is null');
      return;
    }

    debugPrint('WishlistProvider: Toggling wishlist for product $productId');

    try {
      if (isInWishlist(productId)) {
        await _firestoreService.removeFromWishlist(_userId!, productId);
        debugPrint('WishlistProvider: Removed $productId from wishlist');
      } else {
        await _firestoreService.addToWishlist(_userId!, productId);
        debugPrint('WishlistProvider: Added $productId to wishlist');
      }
    } catch (e) {
      debugPrint('WishlistProvider: Error toggling wishlist: $e');
    }
  }

  Future<void> addToWishlist(String productId) async {
    if (_userId == null || isInWishlist(productId)) return;
    await _firestoreService.addToWishlist(_userId!, productId);
  }

  Future<void> removeFromWishlist(String productId) async {
    if (_userId == null) return;
    await _firestoreService.removeFromWishlist(_userId!, productId);
  }

  Future<void> clearWishlist() async {
    if (_userId == null) return;
    for (final id in _wishlistIds) {
      await _firestoreService.removeFromWishlist(_userId!, id);
    }
  }

  @override
  void dispose() {
    _wishlistSubscription?.cancel();
    super.dispose();
  }
}
