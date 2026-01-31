import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? imageUrl;
  final String? parentId;
  final int order;
  final bool isActive;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.imageUrl,
    this.parentId,
    this.order = 0,
    this.isActive = true,
    this.productCount = 0,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'],
      imageUrl: data['imageUrl'],
      parentId: data['parentId'],
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      productCount: data['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
      'parentId': parentId,
      'order': order,
      'isActive': isActive,
      'productCount': productCount,
    };
  }
}
