import '../../domain/entities/user_search_result.dart';

class UserSearchResultModel extends UserSearchResult {
  const UserSearchResultModel({
    required super.userId,
    required super.email,
    super.phoneNumber,
    required super.fullName,
    super.profilePicture,
    super.connectionStatus,
    super.requestId,
    super.isSender,
  });

  factory UserSearchResultModel.fromJson(Map<String, dynamic> json) {
    return UserSearchResultModel(
      userId: json['user_id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
      profilePicture: json['profile_picture'],
      connectionStatus: json['connection_status'],
      requestId: json['request_id'],
      isSender: json['is_sender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'profile_picture': profilePicture,
      'connection_status': connectionStatus,
      'request_id': requestId,
      'is_sender': isSender,
    };
  }
}
