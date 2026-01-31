import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? category;
  final List<String> images;
  final int stock;
  final double rating;
  final int reviewCount;
  final int soldCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    this.category,
    required this.images,
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.soldCount = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  double get finalPrice => price;
  bool get isInStock => stock > 0;

  // Alias for category
  String get categoryId => category ?? '';

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? data['Name'] ?? '',
      description: data['description'] ?? data['Detail'] ?? '',
      price: _parseDouble(data['price'] ?? data['Price']),
      originalPrice: data['originalPrice'] != null
          ? _parseDouble(data['originalPrice'])
          : (data['discountPrice'] != null
              ? _parseDouble(data['discountPrice'])
              : null),
      category:
          data['category'] ?? data['categoryName'] ?? data['categoryId'] ?? '',
      images: _parseImages(data['images'] ?? data['Image']),
      stock: data['stock'] ?? 10,
      rating: _parseDouble(data['rating'] ?? 0),
      reviewCount: data['reviewCount'] ?? 0,
      soldCount: data['soldCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: _parseDateTime(data['createdAt'] ?? data['CreatedAt']),
      updatedAt:
          data['updatedAt'] != null ? _parseDateTime(data['updatedAt']) : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String)
      return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    return 0.0;
  }

  static List<String> _parseImages(dynamic value) {
    if (value == null) return [];
    if (value is String) return [value];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'images': images,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'soldCount': soldCount,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.now(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    List<String>? images,
    int? stock,
    double? rating,
    int? reviewCount,
    int? soldCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      category: category ?? this.category,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      soldCount: soldCount ?? this.soldCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
