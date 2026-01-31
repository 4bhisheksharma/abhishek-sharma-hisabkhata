/// Shared message model for chat functionality
class ChatMessage {
  final String text;
  final bool isUser;
  final String? senderName;
  final String? avatarUrl;
  final DateTime? timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.senderName,
    this.avatarUrl,
    this.timestamp,
  });
}
