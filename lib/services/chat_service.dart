import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/chat_model.dart';

/// Service untuk chat real-time antara user dan admin
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _chatRooms => _firestore.collection('chat_rooms');
  CollectionReference get _messages => _firestore.collection('chat_messages');

  /// Buat atau dapatkan chat room untuk user
  Future<ChatRoom> getOrCreateChatRoom({
    required String oderId,
    required String participantId,
    required String participantName,
    required String participantEmail,
    String? participantPhotoUrl,
  }) async {
    try {
      // Cek apakah sudah ada chat room untuk user ini
      final existingRoom = await _chatRooms
          .where('participantId', isEqualTo: participantId)
          .get();

      for (var doc in existingRoom.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isActive'] == true) {
          return ChatRoom.fromJson(data);
        }
      }

      // Buat chat room baru
      final docRef = _chatRooms.doc();
      final chatRoom = ChatRoom(
        id: docRef.id,
        oderId: oderId,
        participantId: participantId,
        participantName: participantName,
        participantEmail: participantEmail,
        participantPhotoUrl: participantPhotoUrl,
        unreadCountUser: 0,
        unreadCountAdmin: 0,
        isActive: true,
        createdAt: DateTime.now(),
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      );

      await docRef.set(chatRoom.toJson());
      return chatRoom;
    } catch (e) {
      rethrow;
    }
  }

  /// Kirim pesan
  Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String senderType,
    required String message,
    String? imageUrl,
  }) async {
    try {
      final docRef = _messages.doc();
      final now = DateTime.now();

      final chatMessage = ChatMessage(
        id: docRef.id,
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderName: senderName,
        senderType: senderType,
        message: message,
        imageUrl: imageUrl,
        isRead: false,
        createdAt: now,
      );

      // Simpan pesan
      await docRef.set(chatMessage.toJson());

      // Update last message dan unread count di chat room
      final Map<String, dynamic> updateData = {
        'lastMessage': message,
        'lastMessageTime': Timestamp.fromDate(now),
      };

      if (senderType == 'user') {
        // Increment unread count untuk admin
        await _chatRooms.doc(chatRoomId).update({
          ...updateData,
          'unreadCountAdmin': FieldValue.increment(1),
        });
      } else {
        // Increment unread count untuk user
        await _chatRooms.doc(chatRoomId).update({
          ...updateData,
          'unreadCountUser': FieldValue.increment(1),
        });
      }

      return chatMessage;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream messages untuk chat room tertentu
  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _messages
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    }).handleError((error) {
      // Jika error terkait index, return empty list dan log error
      return <ChatMessage>[];
    });
  }

  /// Stream semua chat rooms untuk admin
  Stream<List<ChatRoom>> getAllChatRooms() {
    return _chatRooms
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs.map((doc) {
        return ChatRoom.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      // Sort di client-side untuk menghindari composite index
      rooms.sort((a, b) {
        final aTime = a.lastMessageTime ?? a.createdAt;
        final bTime = b.lastMessageTime ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      return rooms;
    });
  }

  /// Stream chat room untuk user tertentu
  Stream<ChatRoom?> getUserChatRoom(String oderId) {
    return _chatRooms
        .where('participantId', isEqualTo: oderId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isActive'] == true) {
          return ChatRoom.fromJson(data);
        }
      }
      return null;
    });
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String chatRoomId,
    required String readerType,
  }) async {
    try {
      // Get unread messages - tanpa composite index
      final unreadMessages = await _messages
          .where('chatRoomId', isEqualTo: chatRoomId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Filter di client-side
        if (data['senderType'] != readerType) {
          batch.update(doc.reference, {'isRead': true});
        }
      }
      await batch.commit();

      // Reset unread count
      if (readerType == 'user') {
        await _chatRooms.doc(chatRoomId).update({'unreadCountUser': 0});
      } else {
        await _chatRooms.doc(chatRoomId).update({'unreadCountAdmin': 0});
      }
    } catch (e) {
      // Ignore errors silently
    }
  }

  /// Close chat room
  Future<void> closeChatRoom(String chatRoomId) async {
    await _chatRooms.doc(chatRoomId).update({'isActive': false});
  }

  /// Get unread count for user
  Stream<int> getUnreadCountForUser(String oderId) {
    return _chatRooms
        .where('participantId', isEqualTo: oderId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isActive'] == true) {
          return (data['unreadCountUser'] as int?) ?? 0;
        }
      }
      return 0;
    });
  }

  /// Get total unread count for admin
  Stream<int> getTotalUnreadCountForAdmin() {
    return _chatRooms
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['unreadCountAdmin'] as int?) ?? 0;
      }
      return total;
    });
  }
}
