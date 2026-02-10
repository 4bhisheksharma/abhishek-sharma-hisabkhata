import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../data/datasources/chat_websocket_service.dart';

/// Base class for all chat states.
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action.
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Loading state for chat rooms list.
class ChatRoomsLoading extends ChatState {
  const ChatRoomsLoading();
}

/// Success state with loaded chat rooms.
class ChatRoomsLoaded extends ChatState {
  final List<ChatRoomEntity> chatRooms;

  const ChatRoomsLoaded({required this.chatRooms});

  @override
  List<Object?> get props => [chatRooms];
}

/// Loading state for opening a chat room.
class ChatRoomOpening extends ChatState {
  const ChatRoomOpening();
}

/// Active chat room state with messages.
class ChatRoomActive extends ChatState {
  final ChatRoomEntity chatRoom;
  final List<MessageEntity> messages;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final WebSocketStatus connectionStatus;
  final bool isOtherUserTyping;
  final String? otherUserTypingName;

  const ChatRoomActive({
    required this.chatRoom,
    required this.messages,
    this.isLoadingMore = false,
    this.hasMoreMessages = true,
    this.connectionStatus = WebSocketStatus.disconnected,
    this.isOtherUserTyping = false,
    this.otherUserTypingName,
  });

  ChatRoomActive copyWith({
    ChatRoomEntity? chatRoom,
    List<MessageEntity>? messages,
    bool? isLoadingMore,
    bool? hasMoreMessages,
    WebSocketStatus? connectionStatus,
    bool? isOtherUserTyping,
    String? otherUserTypingName,
  }) {
    return ChatRoomActive(
      chatRoom: chatRoom ?? this.chatRoom,
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isOtherUserTyping: isOtherUserTyping ?? this.isOtherUserTyping,
      otherUserTypingName: otherUserTypingName ?? this.otherUserTypingName,
    );
  }

  @override
  List<Object?> get props => [
        chatRoom,
        messages,
        isLoadingMore,
        hasMoreMessages,
        connectionStatus,
        isOtherUserTyping,
        otherUserTypingName,
      ];
}

/// Loading messages state.
class MessagesLoading extends ChatState {
  final ChatRoomEntity chatRoom;

  const MessagesLoading({required this.chatRoom});

  @override
  List<Object?> get props => [chatRoom];
}

/// Error state.
class ChatError extends ChatState {
  final String message;
  final ChatState? previousState;

  const ChatError({
    required this.message,
    this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

/// Empty state when no chat rooms exist.
class ChatRoomsEmpty extends ChatState {
  const ChatRoomsEmpty();
}
