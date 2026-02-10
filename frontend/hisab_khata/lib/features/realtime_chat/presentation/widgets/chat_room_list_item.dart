import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_theme.dart';
import '../../domain/entities/chat_room_entity.dart';

/// Widget to display a chat room item in the chat list.
class ChatRoomListItem extends StatelessWidget {
  final ChatRoomEntity chatRoom;
  final int currentUserId;
  final VoidCallback onTap;

  const ChatRoomListItem({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final otherUser = chatRoom.getOtherParticipant(currentUserId);
    final hasUnread = chatRoom.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasUnread
              ? AppTheme.lightBlue.withOpacity(0.3)
              : AppTheme.white,
          border: Border(
            bottom: BorderSide(color: AppTheme.lightGrey.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primaryLight,
              backgroundImage: otherUser.profilePicture != null
                  ? NetworkImage(otherUser.profilePicture!)
                  : null,
              child: otherUser.profilePicture == null
                  ? Text(
                      _getInitials(otherUser.displayName),
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          otherUser.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chatRoom.lastMessage != null)
                        Text(
                          _formatTime(chatRoom.lastMessage!.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? AppTheme.primaryBlue
                                : AppTheme.textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Last message and unread count row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getLastMessagePreview(),
                          style: TextStyle(
                            fontSize: 14,
                            color: hasUnread
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chatRoom.unreadCount > 99
                                ? '99+'
                                : '${chatRoom.unreadCount}',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _getLastMessagePreview() {
    if (chatRoom.lastMessage == null) return 'No messages yet';

    final isFromCurrentUser = chatRoom.lastMessage!.senderId == currentUserId;
    final prefix = isFromCurrentUser ? 'You: ' : '';
    return '$prefix${chatRoom.lastMessage!.content}';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat.jm().format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
