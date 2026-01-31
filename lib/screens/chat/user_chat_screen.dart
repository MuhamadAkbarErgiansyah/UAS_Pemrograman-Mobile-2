import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../data/models/chat_model.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  ChatRoom? _chatRoom;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeChatRoom();
  }

  Future<void> _initializeChatRoom() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final userModel = auth.userModel;

    if (user == null) {
      setState(() => _isInitializing = false);
      return;
    }

    try {
      final room = await _chatService.getOrCreateChatRoom(
        oderId: user.uid,
        participantId: user.uid,
        participantName: userModel?.displayName ?? user.displayName ?? 'User',
        participantEmail: user.email ?? '',
        participantPhotoUrl: userModel?.photoUrl ?? user.photoURL,
      );

      setState(() {
        _chatRoom = room;
        _isInitializing = false;
      });

      // Mark messages as read
      _chatService.markMessagesAsRead(
        chatRoomId: room.id,
        readerType: 'user',
      );
    } catch (e) {
      setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _chatRoom == null) return;

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final userModel = auth.userModel;

    if (user == null) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await _chatService.sendMessage(
        chatRoomId: _chatRoom!.id,
        senderId: user.uid,
        senderName: userModel?.displayName ?? user.displayName ?? 'User',
        senderType: 'user',
        message: message,
      );

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: $e')),
        );
      }
    }

    setState(() => _isSending = false);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer Service', style: TextStyle(fontSize: 16)),
                Text(
                  'ShopeZone Support',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : _chatRoom == null
              ? _buildNoChat()
              : Column(
                  children: [
                    // Welcome Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.md),
                      margin: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          const Expanded(
                            child: Text(
                              'Hai! Ada yang bisa kami bantu? Kami siap membantu Anda.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.1),

                    // Messages List
                    Expanded(
                      child: StreamBuilder<List<ChatMessage>>(
                        stream: _chatService.getMessages(_chatRoom!.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final messages = snapshot.data ?? [];

                          if (messages.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 60,
                                    color: AppColors.textHint,
                                  ),
                                  const SizedBox(height: AppSizes.md),
                                  Text(
                                    'Mulai percakapan',
                                    style: TextStyle(
                                        color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: AppSizes.xs),
                                  Text(
                                    'Ketik pesan untuk menghubungi admin',
                                    style: TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn();
                          }

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isUser = message.senderType == 'user';

                              return _MessageBubble(
                                message: message,
                                isUser: isUser,
                              )
                                  .animate(
                                      delay: Duration(milliseconds: index * 30))
                                  .fadeIn()
                                  .slideY(begin: 0.1);
                            },
                          );
                        },
                      ),
                    ),

                    // Quick Actions
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _QuickActionChip(
                              label: 'Tanya produk',
                              onTap: () {
                                _messageController.text =
                                    'Saya ingin bertanya tentang produk ';
                              },
                            ),
                            _QuickActionChip(
                              label: 'Status pesanan',
                              onTap: () {
                                _messageController.text =
                                    'Saya ingin menanyakan status pesanan saya';
                              },
                            ),
                            _QuickActionChip(
                              label: 'Keluhan',
                              onTap: () {
                                _messageController.text =
                                    'Saya memiliki keluhan tentang ';
                              },
                            ),
                            _QuickActionChip(
                              label: 'Refund',
                              onTap: () {
                                _messageController.text =
                                    'Saya ingin mengajukan refund untuk pesanan ';
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Input Area
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Ketik pesan...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor:
                                      AppColors.primary.withOpacity(0.05),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Container(
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _isSending ? null : _sendMessage,
                                icon: _isSending
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send,
                                        color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildNoChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSizes.md),
          const Text('Tidak dapat memuat chat'),
          const SizedBox(height: AppSizes.sm),
          ElevatedButton(
            onPressed: _initializeChatRoom,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const _MessageBubble({
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Admin ShopeZone',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            Text(
              message.message,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isUser
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.textHint,
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead
                        ? Colors.lightBlueAccent
                        : Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        onPressed: onTap,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
    );
  }
}
