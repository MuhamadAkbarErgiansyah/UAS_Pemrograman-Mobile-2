import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CartItemModel> _items = [];
  String? _userId;
  bool _isLoading = false;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get shippingFee => _items.isEmpty ? 0 : 15000;
  double get total => subtotal + shippingFee;

  void initialize(String userId) {
    _userId = userId;
    _firestoreService.getCartItems(userId).listen((items) {
      _items = items;
      notifyListeners();
    });
  }

  void clear() {
    _items = [];
    _userId = null;
    notifyListeners();
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final cartItem = CartItemModel(
        id: '',
        productId: product.id,
        productName: product.name,
        productImage: product.images.isNotEmpty ? product.images.first : '',
        price: product.finalPrice,
        quantity: quantity,
        addedAt: DateTime.now(),
      );

      await _firestoreService.addToCart(_userId!, cartItem);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (_userId == null) return;
    await _firestoreService.updateCartItemQuantity(_userId!, itemId, quantity);
  }

  Future<void> incrementQuantity(String itemId) async {
    final item = _items.firstWhere((i) => i.id == itemId);
    await updateQuantity(itemId, item.quantity + 1);
  }

  Future<void> decrementQuantity(String itemId) async {
    final item = _items.firstWhere((i) => i.id == itemId);
    if (item.quantity > 1) {
      await updateQuantity(itemId, item.quantity - 1);
    } else {
      await removeItem(itemId);
    }
  }

  Future<void> removeItem(String itemId) async {
    if (_userId == null) return;
    await _firestoreService.removeFromCart(_userId!, itemId);
  }

  // Alias for removeItem
  Future<void> removeFromCart(String itemId) async {
    await removeItem(itemId);
  }

  Future<void> clearCart() async {
    if (_userId == null) return;
    await _firestoreService.clearCart(_userId!);
  }

  // Get shipping fee (alias for shippingFee)
  double get shipping => shippingFee;

  // Get tax
  double get tax => subtotal * 0.1; // 10% tax
}
