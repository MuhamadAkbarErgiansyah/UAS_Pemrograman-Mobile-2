import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/order_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/address_model.dart';

/// Service untuk mengelola pesanan
class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _orders => _firestore.collection('orders');

  /// Buat pesanan baru
  Future<OrderModel> createOrder({
    required String userId,
    required List<CartItemModel> items,
    required double subtotal,
    required double shippingFee,
    required double discount,
    required double total,
    required AddressModel shippingAddress,
    required String paymentMethod,
    String? voucherCode,
    String? notes,
  }) async {
    final docRef = _orders.doc();

    final orderItems = items
        .map((item) => OrderItemModel(
              productId: item.productId,
              productName: item.productName,
              productImage: item.productImage,
              price: item.price,
              quantity: item.quantity,
            ))
        .toList();

    final order = OrderModel(
      id: docRef.id,
      userId: userId,
      items: orderItems,
      subtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      total: total,
      status: OrderStatus.pending,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      voucherCode: voucherCode,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(order.toFirestore());
    return order;
  }

  /// Update status pesanan (Admin)
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _orders.doc(orderId).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Get pesanan by ID
  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  /// Stream pesanan user
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _orders
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  /// Stream semua pesanan (Admin)
  Stream<List<OrderModel>> getAllOrders() {
    return _orders.snapshots().map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  /// Stream pesanan berdasarkan status (Admin)
  Stream<List<OrderModel>> getOrdersByStatus(OrderStatus status) {
    return _orders
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  /// Get order statistics (Admin)
  Future<Map<String, dynamic>> getOrderStatistics() async {
    final allOrders = await _orders.get();

    int totalOrders = allOrders.docs.length;
    int pendingOrders = 0;
    int processingOrders = 0;
    int shippedOrders = 0;
    int deliveredOrders = 0;
    int cancelledOrders = 0;
    double totalRevenue = 0;

    for (var doc in allOrders.docs) {
      final order = OrderModel.fromFirestore(doc);

      switch (order.status) {
        case OrderStatus.pending:
          pendingOrders++;
          break;
        case OrderStatus.processing:
          processingOrders++;
          break;
        case OrderStatus.shipped:
          shippedOrders++;
          break;
        case OrderStatus.delivered:
          deliveredOrders++;
          totalRevenue += order.total;
          break;
        case OrderStatus.cancelled:
          cancelledOrders++;
          break;
        default:
          break;
      }
    }

    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'processingOrders': processingOrders,
      'shippedOrders': shippedOrders,
      'deliveredOrders': deliveredOrders,
      'cancelledOrders': cancelledOrders,
      'totalRevenue': totalRevenue,
    };
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    await _orders.doc(orderId).update({
      'status': OrderStatus.cancelled.name,
      'cancelReason': reason,
      'cancelledAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Add tracking info
  Future<void> addTrackingInfo(
      String orderId, String trackingNumber, String courier) async {
    await _orders.doc(orderId).update({
      'trackingNumber': trackingNumber,
      'courier': courier,
      'status': OrderStatus.shipped.name,
      'shippedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Mark as delivered
  Future<void> markAsDelivered(String orderId) async {
    await _orders.doc(orderId).update({
      'status': OrderStatus.delivered.name,
      'deliveredAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }
}
