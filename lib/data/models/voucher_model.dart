import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discountPercent;
  final double? maxDiscount;
  final double minPurchase;
  final DateTime validFrom;
  final DateTime validUntil;
  final int usageLimit;
  final int usedCount;
  final bool isActive;
  final List<String>? applicableCategories;
  final DateTime createdAt;

  VoucherModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercent,
    this.maxDiscount,
    required this.minPurchase,
    required this.validFrom,
    required this.validUntil,
    required this.usageLimit,
    required this.usedCount,
    required this.isActive,
    this.applicableCategories,
    required this.createdAt,
  });

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(validFrom) &&
        now.isBefore(validUntil) &&
        usedCount < usageLimit;
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);

  double calculateDiscount(double amount) {
    if (!isValid || amount < minPurchase) return 0;

    double discount = amount * (discountPercent / 100);
    if (maxDiscount != null && discount > maxDiscount!) {
      discount = maxDiscount!;
    }
    return discount;
  }

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
      maxDiscount: json['maxDiscount']?.toDouble(),
      minPurchase: (json['minPurchase'] ?? 0).toDouble(),
      validFrom: (json['validFrom'] as Timestamp).toDate(),
      validUntil: (json['validUntil'] as Timestamp).toDate(),
      usageLimit: json['usageLimit'] ?? 0,
      usedCount: json['usedCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      applicableCategories: json['applicableCategories'] != null
          ? List<String>.from(json['applicableCategories'])
          : null,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'discountPercent': discountPercent,
      'maxDiscount': maxDiscount,
      'minPurchase': minPurchase,
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'isActive': isActive,
      'applicableCategories': applicableCategories,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  VoucherModel copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    double? discountPercent,
    double? maxDiscount,
    double? minPurchase,
    DateTime? validFrom,
    DateTime? validUntil,
    int? usageLimit,
    int? usedCount,
    bool? isActive,
    List<String>? applicableCategories,
    DateTime? createdAt,
  }) {
    return VoucherModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      discountPercent: discountPercent ?? this.discountPercent,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      minPurchase: minPurchase ?? this.minPurchase,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
