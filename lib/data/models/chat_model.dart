import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String senderType; // 'user' or 'admin'
  final String message;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    this.imageUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      chatRoomId: json['chatRoomId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderType: json['senderType'] ?? 'user',
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'],
      isRead: json['isRead'] ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'message': message,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class ChatRoom {
  final String id;
  final String oderId; // Optional: linked to order
  final String participantId; // User ID
  final String participantName;
  final String participantEmail;
  final String? participantPhotoUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCountUser;
  final int unreadCountAdmin;
  final bool isActive;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.oderId,
    required this.participantId,
    required this.participantName,
    required this.participantEmail,
    this.participantPhotoUrl,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCountUser,
    required this.unreadCountAdmin,
    required this.isActive,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      oderId: json['orderId'] ?? '',
      participantId: json['participantId'] ?? '',
      participantName: json['participantName'] ?? '',
      participantEmail: json['participantEmail'] ?? '',
      participantPhotoUrl: json['participantPhotoUrl'],
      lastMessage: json['lastMessage'],
      lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCountUser: json['unreadCountUser'] ?? 0,
      unreadCountAdmin: json['unreadCountAdmin'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': oderId,
      'participantId': participantId,
      'participantName': participantName,
      'participantEmail': participantEmail,
      'participantPhotoUrl': participantPhotoUrl,
      'lastMessage': lastMessage,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCountUser': unreadCountUser,
      'unreadCountAdmin': unreadCountAdmin,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
