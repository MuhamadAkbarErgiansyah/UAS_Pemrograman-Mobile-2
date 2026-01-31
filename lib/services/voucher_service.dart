import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/voucher_model.dart';

/// Service untuk mengelola voucher
class VoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _vouchers => _firestore.collection('vouchers');
  CollectionReference get _userVouchers =>
      _firestore.collection('user_vouchers');

  /// Buat voucher baru (Admin only)
  Future<VoucherModel> createVoucher(VoucherModel voucher) async {
    final docRef = _vouchers.doc();
    final newVoucher = voucher.copyWith(id: docRef.id);
    await docRef.set(newVoucher.toJson());
    return newVoucher;
  }

  /// Update voucher (Admin only)
  Future<void> updateVoucher(VoucherModel voucher) async {
    await _vouchers.doc(voucher.id).update(voucher.toJson());
  }

  /// Delete voucher (Admin only)
  Future<void> deleteVoucher(String voucherId) async {
    await _vouchers.doc(voucherId).delete();
  }

  /// Get semua voucher aktif
  Stream<List<VoucherModel>> getActiveVouchers() {
    final now = DateTime.now();
    return _vouchers
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final vouchers = snapshot.docs
          .map((doc) =>
              VoucherModel.fromJson(doc.data() as Map<String, dynamic>))
          .where((v) => v.validUntil.isAfter(now)) // Filter client-side
          .toList();
      vouchers.sort((a, b) => a.validUntil.compareTo(b.validUntil));
      return vouchers;
    });
  }

  /// Get semua voucher (Admin)
  Stream<List<VoucherModel>> getAllVouchers() {
    return _vouchers.snapshots().map((snapshot) {
      final vouchers = snapshot.docs.map((doc) {
        return VoucherModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      // Sort client-side to avoid needing index
      vouchers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return vouchers;
    });
  }

  /// Validate voucher code
  Future<VoucherModel?> validateVoucher(String code, double cartTotal) async {
    final result = await _vouchers
        .where('code', isEqualTo: code.toUpperCase())
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (result.docs.isEmpty) return null;

    final voucher = VoucherModel.fromJson(
      result.docs.first.data() as Map<String, dynamic>,
    );

    // Check if valid
    if (!voucher.isValid) return null;
    if (cartTotal < voucher.minPurchase) return null;

    return voucher;
  }

  /// Apply voucher (increment used count)
  Future<void> applyVoucher(String voucherId, String oderId) async {
    // Increment used count
    await _vouchers.doc(voucherId).update({
      'usedCount': FieldValue.increment(1),
    });

    // Record user voucher usage
    await _userVouchers.add({
      'voucherId': voucherId,
      'userId': oderId,
      'usedAt': Timestamp.now(),
    });
  }

  /// Check if user already used voucher
  Future<bool> hasUserUsedVoucher(String voucherId, String oderId) async {
    final result = await _userVouchers
        .where('voucherId', isEqualTo: voucherId)
        .where('userId', isEqualTo: oderId)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  /// Seed sample vouchers
  Future<void> seedSampleVouchers() async {
    final now = DateTime.now();
    final vouchers = [
      VoucherModel(
        id: '',
        code: 'WELCOME10',
        title: 'Diskon Pengguna Baru',
        description: 'Diskon 10% untuk pengguna baru. Maksimal Rp 50.000',
        discountPercent: 10,
        maxDiscount: 50000,
        minPurchase: 100000,
        validFrom: now,
        validUntil: now.add(const Duration(days: 30)),
        usageLimit: 1000,
        usedCount: 0,
        isActive: true,
        createdAt: now,
      ),
      VoucherModel(
        id: '',
        code: 'HEMAT20',
        title: 'Hemat 20%',
        description: 'Diskon 20% untuk semua produk. Maksimal Rp 100.000',
        discountPercent: 20,
        maxDiscount: 100000,
        minPurchase: 200000,
        validFrom: now,
        validUntil: now.add(const Duration(days: 14)),
        usageLimit: 500,
        usedCount: 0,
        isActive: true,
        createdAt: now,
      ),
      VoucherModel(
        id: '',
        code: 'GRATIS0NGKIR',
        title: 'Gratis Ongkir',
        description: 'Gratis ongkos kirim untuk belanja minimal Rp 150.000',
        discountPercent: 100,
        maxDiscount: 30000,
        minPurchase: 150000,
        validFrom: now,
        validUntil: now.add(const Duration(days: 7)),
        usageLimit: 200,
        usedCount: 0,
        isActive: true,
        createdAt: now,
      ),
      VoucherModel(
        id: '',
        code: 'FLASH50',
        title: 'Flash Sale 50%',
        description: 'Diskon 50%! Maksimal Rp 200.000. Terbatas!',
        discountPercent: 50,
        maxDiscount: 200000,
        minPurchase: 300000,
        validFrom: now,
        validUntil: now.add(const Duration(days: 3)),
        usageLimit: 100,
        usedCount: 0,
        isActive: true,
        createdAt: now,
      ),
      VoucherModel(
        id: '',
        code: 'WEEKEND15',
        title: 'Weekend Sale',
        description: 'Diskon 15% khusus weekend. Maksimal Rp 75.000',
        discountPercent: 15,
        maxDiscount: 75000,
        minPurchase: 100000,
        validFrom: now,
        validUntil: now.add(const Duration(days: 60)),
        usageLimit: 1000,
        usedCount: 0,
        isActive: true,
        createdAt: now,
      ),
    ];

    for (var voucher in vouchers) {
      // Check if voucher code already exists
      final existing =
          await _vouchers.where('code', isEqualTo: voucher.code).limit(1).get();

      if (existing.docs.isEmpty) {
        await createVoucher(voucher);
      }
    }
  }
}
