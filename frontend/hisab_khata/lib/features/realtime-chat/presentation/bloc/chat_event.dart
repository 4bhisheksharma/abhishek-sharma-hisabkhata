import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatRoomsEvent extends ChatEvent {}

class SelectChatRoomEvent extends ChatEvent {
  final int chatRoomId;

  const SelectChatRoomEvent(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}

class SendMessageEvent extends ChatEvent {
  final String content;
  final MessageType messageType;

  const SendMessageEvent(this.content, this.messageType);

  @override
  List<Object?> get props => [content, messageType];
}

class MarkMessagesAsReadEvent extends ChatEvent {
  final List<int> messageIds;

  const MarkMessagesAsReadEvent(this.messageIds);

  @override
  List<Object?> get props => [messageIds];
}

class LoadMessagesEvent extends ChatEvent {
  final int chatRoomId;

  const LoadMessagesEvent(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}