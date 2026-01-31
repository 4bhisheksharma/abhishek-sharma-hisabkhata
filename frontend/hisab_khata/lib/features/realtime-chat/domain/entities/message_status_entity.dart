enum MessageStatusType { sent, delivered, read }

class MessageStatusEntity {
  final int messageStatusId;
  final int messageId;
  final int userId;
  final MessageStatusType status;
  final DateTime timestamp;

  MessageStatusEntity({
    required this.messageStatusId,
    required this.messageId,
    required this.userId,
    required this.status,
    required this.timestamp,
  });

  // Factory constructor for creating from JSON
  factory MessageStatusEntity.fromJson(Map<String, dynamic> json) {
    return MessageStatusEntity(
      messageStatusId: json['message_status_id'] as int,
      messageId: json['message'] as int,
      userId: json['user'] as int,
      status: MessageStatusType.values.firstWhere(
        (e) => e.name == json['status'] as String,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'message_status_id': messageStatusId,
      'message': messageId,
      'user': userId,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
