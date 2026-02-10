import '../../domain/entities/chat_user_entity.dart';

/// Model for user data from API response.
class ChatUserModel extends ChatUserEntity {
  const ChatUserModel({
    required super.userId,
    required super.fullName,
    required super.email,
    super.profilePicture,
    super.isBusiness,
    super.businessName,
    super.displayName,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    final isBusiness = json['is_business'] as bool? ?? false;
    final businessName = json['business_name'] as String?;
    final fullName = json['full_name'] as String;

    return ChatUserModel(
      userId: json['user_id'] as int,
      fullName: fullName,
      email: json['email'] as String,
      profilePicture: json['profile_picture'] as String?,
      isBusiness: isBusiness,
      businessName: businessName,
      displayName:
          json['display_name'] as String? ??
          (isBusiness && businessName != null ? businessName : fullName),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'profile_picture': profilePicture,
      'is_business': isBusiness,
      'business_name': businessName,
      'display_name': displayName,
    };
  }
}
