import '../../domain/entities/chat_user_entity.dart';

/// Model for user data from API response.
class ChatUserModel extends ChatUserEntity {
  const ChatUserModel({
    required super.userId,
    required super.fullName,
    required super.email,
    super.profilePicture,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      profilePicture: json['profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'profile_picture': profilePicture,
    };
  }
}
