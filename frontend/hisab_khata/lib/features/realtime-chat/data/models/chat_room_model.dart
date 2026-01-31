class ChatRoomModel {
  final int chatRoomId;
  final int relationshipId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatRoomModel({
    required this.chatRoomId,
    required this.relationshipId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      chatRoomId: json['chat_room_id'] as int,
      relationshipId: json['relationship'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_room_id': chatRoomId,
      'relationship': relationshipId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
