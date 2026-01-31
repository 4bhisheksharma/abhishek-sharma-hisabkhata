import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoomEntity> chatRooms;

  const ChatRoomsLoaded(this.chatRooms);

  @override
  List<Object?> get props => [chatRooms];
}

class ChatRoomSelected extends ChatState {
  final ChatRoomEntity chatRoom;
  final List<MessageEntity> messages;
  final bool isLoadingMessages;

  const ChatRoomSelected(
    this.chatRoom,
    this.messages,
    this.isLoadingMessages,
  );

  @override
  List<Object?> get props => [chatRoom, messages, isLoadingMessages];
}

class MessageSending extends ChatState {
  final ChatRoomEntity chatRoom;
  final List<MessageEntity> messages;

  const MessageSending(this.chatRoom, this.messages);

  @override
  List<Object?> get props => [chatRoom, messages];
}

class MessageSent extends ChatState {
  final ChatRoomEntity chatRoom;
  final List<MessageEntity> messages;

  const MessageSent(this.chatRoom, this.messages);

  @override
  List<Object?> get props => [chatRoom, messages];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}