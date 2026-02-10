import 'package:equatable/equatable.dart';

/// Entity representing a user in chat context.
class ChatUserEntity extends Equatable {
  final int userId;
  final String fullName;
  final String email;
  final String? profilePicture;

  const ChatUserEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [userId, fullName, email, profilePicture];
}
