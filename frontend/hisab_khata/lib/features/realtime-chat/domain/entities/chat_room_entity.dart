class ChatRoomEntity {
  final int chatRoomId;
  final int relationshipId; // Reference to CustomerBusinessRelationship
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatRoomEntity({
    required this.chatRoomId,
    required this.relationshipId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating from JSON
  factory ChatRoomEntity.fromJson(Map<String, dynamic> json) {
    return ChatRoomEntity(
      chatRoomId: json['chat_room_id'] as int,
      relationshipId: json['relationship'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'chat_room_id': chatRoomId,
      'relationship': relationshipId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
