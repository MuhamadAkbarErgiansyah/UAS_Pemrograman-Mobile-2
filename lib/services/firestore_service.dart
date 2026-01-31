import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/order_model.dart';
import '../data/models/address_model.dart';
import '../data/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ PRODUCTS ============

  Stream<List<ProductModel>> getProducts({
    String? categoryId,
    int? limit,
    String? orderBy,
    bool descending = true,
  }) {
    Query query = _firestore.collection('products');

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      return ProductModel.fromFirestore(doc);
    }
    return null;
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    List<ProductModel> results = [];

    // Search in main products collection
    final mainSnapshot = await _firestore.collection('products').get();
    results.addAll(
      mainSnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              (product.description
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false))
          .toList(),
    );

    // Also search in category collections
    final collections = [
      'Watch',
      'Laptop',
      'Phone',
      'Audio',
      'Camera',
      'Gaming',
      'Admin'
    ];
    for (var collection in collections) {
      try {
        final snapshot = await _firestore.collection(collection).get();
        final products = snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                (product.description
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false))
            .toList();
        results.addAll(products);
      } catch (e) {
        // Collection doesn't exist, skip
      }
    }

    // Remove duplicates by ID
    final seen = <String>{};
    results.retainWhere((product) => seen.add(product.id));

    return results;
  }

  // Get products from specific collection (Watch, Laptop, etc)
  Stream<List<ProductModel>> getProductsByCollection(String collectionName) {
    return _firestore.collection(collectionName).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Get all products from multiple collections
  Future<List<ProductModel>> getAllProductsFromCollections(
    List<String> collections,
  ) async {
    List<ProductModel> allProducts = [];
    for (var collection in collections) {
      final snapshot = await _firestore.collection(collection).get();
      allProducts.addAll(
        snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList(),
      );
    }
    return allProducts;
  }

  // ============ CATEGORIES ============

  Stream<List<CategoryModel>> getCategories() {
    return _firestore.collection('categories').orderBy('order').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ============ CART ============

  Stream<List<CartItemModel>> getCartItems(String userId) {
    return _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CartItemModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addToCart(String userId, CartItemModel item) async {
    final cartRef =
        _firestore.collection('carts').doc(userId).collection('items');

    final existing =
        await cartRef.where('productId', isEqualTo: item.productId).get();

    if (existing.docs.isNotEmpty) {
      final existingItem = CartItemModel.fromFirestore(existing.docs.first);
      await cartRef.doc(existing.docs.first.id).update({
        'quantity': existingItem.quantity + item.quantity,
      });
    } else {
      await cartRef.add(item.toFirestore());
    }
  }

  Future<void> updateCartItemQuantity(
    String userId,
    String itemId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await removeFromCart(userId, itemId);
    } else {
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(itemId)
          .update({'quantity': quantity});
    }
  }

  Future<void> removeFromCart(String userId, String itemId) async {
    await _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  Future<void> clearCart(String userId) async {
    final batch = _firestore.batch();
    final items = await _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .get();

    for (var doc in items.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ============ WISHLIST ============

  Stream<List<String>> getWishlist(String userId) {
    return _firestore
        .collection('wishlists')
        .doc(userId)
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<void> addToWishlist(String userId, String productId) async {
    await _firestore
        .collection('wishlists')
        .doc(userId)
        .collection('products')
        .doc(productId)
        .set({'addedAt': Timestamp.now()});
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    await _firestore
        .collection('wishlists')
        .doc(userId)
        .collection('products')
        .doc(productId)
        .delete();
  }

  // ============ ORDERS ============

  Future<String> createOrder(OrderModel order) async {
    final docRef =
        await _firestore.collection('orders').add(order.toFirestore());
    return docRef.id;
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
      (snapshot) {
        final orders =
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
        // Sort client-side to avoid needing composite index
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return orders;
      },
    );
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return OrderModel.fromFirestore(doc);
    }
    return null;
  }

  // ============ BANNERS ============

  Stream<List<Map<String, dynamic>>> getBanners() {
    return _firestore
        .collection('banners')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // ============ ADMIN FUNCTIONS ============

  /// Get all products from all collections
  Future<List<ProductModel>> getAllProducts() async {
    final collections = [
      'Watch',
      'Laptop',
      'Phone',
      'Audio',
      'Camera',
      'Gaming',
      'products',
    ];
    List<ProductModel> allProducts = [];

    for (var collection in collections) {
      try {
        final snapshot = await _firestore.collection(collection).get();
        allProducts.addAll(
          snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList(),
        );
      } catch (e) {
        // Collection may not exist, continue
      }
    }
    return allProducts;
  }

  /// Add a new product to specified collection
  Future<String> addProduct(ProductModel product, String collection) async {
    final docRef =
        await _firestore.collection(collection).add(product.toFirestore());
    return docRef.id;
  }

  /// Update an existing product
  Future<void> updateProduct(ProductModel product, String collection) async {
    await _firestore
        .collection(collection)
        .doc(product.id)
        .update(product.toFirestore());
  }

  /// Delete a product
  Future<void> deleteProduct(String productId, String collection) async {
    await _firestore.collection(collection).doc(productId).delete();
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Update user admin status
  Future<void> updateUserAdminStatus(String userId, bool isAdmin) async {
    await _firestore.collection('users').doc(userId).update({
      'isAdmin': isAdmin,
    });
  }

  /// Get all orders (for admin)
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore.collection('orders').snapshots().map(
      (snapshot) {
        final orders =
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
        // Sort client-side to avoid needing index
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return orders;
      },
    );
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Get orders by user (alias for getUserOrders)
  Stream<List<OrderModel>> getOrders(String userId) {
    return getUserOrders(userId);
  }

  // ============ ADDRESSES ============

  /// Get user addresses
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .orderBy('isDefault', descending: true)
        .get();
    return snapshot.docs.map((doc) => AddressModel.fromFirestore(doc)).toList();
  }

  /// Add new address
  Future<void> addAddress(String userId, AddressModel address) async {
    // If this is the first address or marked as default, update other addresses
    if (address.isDefault) {
      await _resetDefaultAddress(userId);
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .add(address.toFirestore());
  }

  /// Update address
  Future<void> updateAddress(String userId, AddressModel address) async {
    if (address.isDefault) {
      await _resetDefaultAddress(userId);
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(address.id)
        .update(address.toFirestore());
  }

  /// Delete address
  Future<void> deleteAddress(String userId, String addressId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  /// Set default address
  Future<void> setDefaultAddress(String userId, String addressId) async {
    await _resetDefaultAddress(userId);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .update({'isDefault': true});
  }

  /// Helper to reset all default addresses
  Future<void> _resetDefaultAddress(String userId) async {
    final addresses = await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .where('isDefault', isEqualTo: true)
        .get();

    for (var doc in addresses.docs) {
      await doc.reference.update({'isDefault': false});
    }
  }

  /// Get default address
  Future<AddressModel?> getDefaultAddress(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      // If no default, get first address
      final firstAddress = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .limit(1)
          .get();

      if (firstAddress.docs.isNotEmpty) {
        return AddressModel.fromFirestore(firstAddress.docs.first);
      }
      return null;
    }

    return AddressModel.fromFirestore(snapshot.docs.first);
  }
}
