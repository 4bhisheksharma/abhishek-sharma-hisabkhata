import 'package:equatable/equatable.dart';

/// Entity representing a user in chat context.
class ChatUserEntity extends Equatable {
  final int userId;
  final String fullName;
  final String email;
  final String? profilePicture;
  final bool isBusiness;
  final String? businessName;
  final String displayName;

  const ChatUserEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.profilePicture,
    this.isBusiness = false,
    this.businessName,
    String? displayName,
  }) : displayName =
           displayName ??
           (isBusiness && businessName != null ? businessName : fullName);

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    profilePicture,
    isBusiness,
    businessName,
    displayName,
  ];
}
