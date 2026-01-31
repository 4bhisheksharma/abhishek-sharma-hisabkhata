enum MessageStatusTypeModel { sent, delivered, read }

class MessageStatusModel {
  final int messageStatusId;
  final int messageId;
  final int userId;
  final MessageStatusTypeModel status;
  final DateTime timestamp;

  MessageStatusModel({
    required this.messageStatusId,
    required this.messageId,
    required this.userId,
    required this.status,
    required this.timestamp,
  });

  factory MessageStatusModel.fromJson(Map<String, dynamic> json) {
    return MessageStatusModel(
      messageStatusId: json['message_status_id'] as int,
      messageId: json['message'] as int,
      userId: json['user'] as int,
      status: MessageStatusTypeModel.values.firstWhere(
        (e) => e.name == json['status'] as String,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
