import 'package:flutter/material.dart';
import 'chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Widget? botAvatar;
  final Widget? userAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    this.botAvatar,
    this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            botAvatar ??
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 20,
                  child: const Icon(Icons.smart_toy, color: Colors.grey),
                ),
          if (!message.isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.senderName != null && !message.isUser)
                    Text(
                      message.senderName!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  if (message.timestamp != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatTimestamp(message.timestamp!),
                        style: TextStyle(
                          fontSize: 10,
                          color: message.isUser
                              ? Colors.white70
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            userAvatar ??
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 20,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
