import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../services/chat_service.dart';
import '../../data/models/chat_model.dart';
import 'admin_chat_detail_screen.dart';

class AdminChatsScreen extends StatelessWidget {
  const AdminChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chat Pelanggan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                StreamBuilder<int>(
                  stream: chatService.getTotalUnreadCountForAdmin(),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data ?? 0;
                    if (unreadCount == 0) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$unreadCount belum dibaca',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ).animate().fadeIn().slideX(begin: -0.1),

          // Chat List
          Expanded(
            child: StreamBuilder<List<ChatRoom>>(
              stream: chatService.getAllChatRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chatRooms = snapshot.data ?? [];

                if (chatRooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'Belum ada chat',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          'Chat dari pelanggan akan muncul di sini',
                          style: TextStyle(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ).animate().fadeIn();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = chatRooms[index];
                    return _ChatRoomCard(
                      room: room,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminChatDetailScreen(chatRoom: room),
                          ),
                        );
                      },
                    )
                        .animate(delay: Duration(milliseconds: index * 50))
                        .fadeIn()
                        .slideX(begin: 0.1);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatRoomCard extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;

  const _ChatRoomCard({
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = room.unreadCountAdmin > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: hasUnread
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.1),
          backgroundImage: room.participantPhotoUrl != null
              ? NetworkImage(room.participantPhotoUrl!)
              : null,
          child: room.participantPhotoUrl == null
              ? Text(
                  room.participantName.isNotEmpty
                      ? room.participantName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: hasUnread ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                room.participantName,
                style: TextStyle(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (room.lastMessageTime != null)
              Text(
                Formatters.formatTimeAgo(room.lastMessageTime!),
                style: TextStyle(
                  fontSize: 12,
                  color: hasUnread ? AppColors.primary : AppColors.textHint,
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                room.lastMessage ?? 'Belum ada pesan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasUnread
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (hasUnread)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${room.unreadCountAdmin}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
