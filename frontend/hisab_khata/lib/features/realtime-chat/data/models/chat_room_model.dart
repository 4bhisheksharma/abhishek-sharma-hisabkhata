class ChatRoomModel {
  final int chatRoomId;
  final int relationshipId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ChatRoomModel({
    required this.chatRoomId,
    required this.relationshipId,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    // Handle relationship field - can be int or object
    int relationshipId;
    if (json['relationship'] is int) {
      relationshipId = json['relationship'] as int;
    } else if (json['relationship'] is Map) {
      relationshipId = json['relationship']['relationship_id'] as int;
    } else {
      throw Exception('Invalid relationship format');
    }

    return ChatRoomModel(
      chatRoomId: json['chat_room_id'] as int,
      relationshipId: relationshipId,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_room_id': chatRoomId,
      'relationship': relationshipId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
