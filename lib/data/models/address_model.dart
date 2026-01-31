import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String? label;
  final String recipientName;
  final String phone;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? notes;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.id,
    this.label,
    required this.recipientName,
    required this.phone,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'Indonesia',
    this.notes,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  // Alias for backward compatibility
  String get province => state;

  String get fullAddress =>
      '$streetAddress, $city, $state $postalCode, $country';

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel.fromMap({...data, 'id': doc.id});
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      label: map['label'],
      recipientName: map['recipientName'] ?? '',
      phone: map['phone'] ?? '',
      streetAddress: map['streetAddress'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? map['province'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? 'Indonesia',
      notes: map['notes'],
      isDefault: map['isDefault'] ?? false,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'recipientName': recipientName,
      'phone': phone,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'notes': notes,
      'isDefault': isDefault,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  Map<String, dynamic> toMap() {
    return {'id': id, ...toFirestore()};
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? recipientName,
    String? phone,
    String? streetAddress,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? notes,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
