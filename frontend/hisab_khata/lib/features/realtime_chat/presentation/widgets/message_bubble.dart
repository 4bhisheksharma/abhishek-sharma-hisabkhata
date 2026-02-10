import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_theme.dart';
import '../../domain/entities/message_entity.dart';

/// Widget to display a single chat message bubble.
class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isFromCurrentUser;
  final bool showTimestamp;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
    this.showTimestamp = true,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 8.0 : 2.0,
        bottom: isLastInGroup ? 8.0 : 2.0,
        left: isFromCurrentUser ? 48.0 : 12.0,
        right: isFromCurrentUser ? 12.0 : 48.0,
      ),
      child: Column(
        crossAxisAlignment:
            isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isFromCurrentUser
                  ? AppTheme.primaryBlue
                  : AppTheme.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isFirstInGroup || isFromCurrentUser ? 16 : 4),
                topRight: Radius.circular(isFirstInGroup || !isFromCurrentUser ? 16 : 4),
                bottomLeft: Radius.circular(isLastInGroup || isFromCurrentUser ? 16 : 4),
                bottomRight: Radius.circular(isLastInGroup || !isFromCurrentUser ? 16 : 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isFromCurrentUser
                        ? AppTheme.white
                        : AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                ),
                if (showTimestamp) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          color: isFromCurrentUser
                              ? AppTheme.white.withOpacity(0.7)
                              : AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (isFromCurrentUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? Colors.lightBlueAccent
                              : AppTheme.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat.jm().format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat.jm().format(dateTime)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }
}
