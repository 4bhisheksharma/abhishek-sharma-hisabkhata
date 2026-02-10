import 'package:equatable/equatable.dart';

/// Base class for all chat events.
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all chat rooms.
class LoadChatRoomsEvent extends ChatEvent {
  const LoadChatRoomsEvent();
}

/// Event to open/create a chat room with another user.
class OpenChatRoomEvent extends ChatEvent {
  final int otherUserId;
  final String? otherUserName;

  const OpenChatRoomEvent({
    required this.otherUserId,
    this.otherUserName,
  });

  @override
  List<Object?> get props => [otherUserId, otherUserName];
}

/// Event to load messages for current chat room.
class LoadMessagesEvent extends ChatEvent {
  final int chatRoomId;
  final bool loadMore;

  const LoadMessagesEvent({
    required this.chatRoomId,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [chatRoomId, loadMore];
}

/// Event to connect to chat room WebSocket.
class ConnectToChatRoomEvent extends ChatEvent {
  final int chatRoomId;

  const ConnectToChatRoomEvent({required this.chatRoomId});

  @override
  List<Object?> get props => [chatRoomId];
}

/// Event to disconnect from chat room WebSocket.
class DisconnectFromChatRoomEvent extends ChatEvent {
  const DisconnectFromChatRoomEvent();
}

/// Event to send a message.
class SendMessageEvent extends ChatEvent {
  final String content;
  final String messageType;

  const SendMessageEvent({
    required this.content,
    this.messageType = 'text',
  });

  @override
  List<Object?> get props => [content, messageType];
}

/// Event when a new message is received via WebSocket.
class MessageReceivedEvent extends ChatEvent {
  final Map<String, dynamic> messageData;

  const MessageReceivedEvent({required this.messageData});

  @override
  List<Object?> get props => [messageData];
}

/// Event to mark messages as read.
class MarkMessagesReadEvent extends ChatEvent {
  final int chatRoomId;

  const MarkMessagesReadEvent({required this.chatRoomId});

  @override
  List<Object?> get props => [chatRoomId];
}

/// Event for typing indicator.
class TypingEvent extends ChatEvent {
  final bool isTyping;

  const TypingEvent({required this.isTyping});

  @override
  List<Object?> get props => [isTyping];
}

/// Event when typing indicator received from other user.
class TypingIndicatorReceivedEvent extends ChatEvent {
  final int userId;
  final String userName;
  final bool isTyping;

  const TypingIndicatorReceivedEvent({
    required this.userId,
    required this.userName,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [userId, userName, isTyping];
}

/// Event when WebSocket connection status changes.
class ConnectionStatusChangedEvent extends ChatEvent {
  final bool isConnected;

  const ConnectionStatusChangedEvent({required this.isConnected});

  @override
  List<Object?> get props => [isConnected];
}

/// Event when messages are marked as read by other user.
class MessagesReadReceivedEvent extends ChatEvent {
  final List<int> messageIds;
  final int readByUserId;

  const MessagesReadReceivedEvent({
    required this.messageIds,
    required this.readByUserId,
  });

  @override
  List<Object?> get props => [messageIds, readByUserId];
}
