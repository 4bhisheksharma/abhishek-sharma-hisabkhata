import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/storage/storage_service.dart';
import '../../../../core/constants/api_base_url.dart';
import '../../data/datasources/chat_websocket_service.dart';
import '../../data/models/message_model.dart';
import '../../domain/usecases/get_chat_rooms_usecase.dart';
import '../../domain/usecases/get_or_create_chat_room_usecase.dart';
import '../../domain/usecases/get_chat_messages_usecase.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// BLoC for managing chat state and real-time messaging.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatRoomsUseCase getChatRoomsUseCase;
  final GetOrCreateChatRoomUseCase getOrCreateChatRoomUseCase;
  final GetChatMessagesUseCase getChatMessagesUseCase;
  final ChatRepository chatRepository;
  final ChatWebSocketService webSocketService;

  StreamSubscription? _wsEventSubscription;
  StreamSubscription? _wsStatusSubscription;
  int? _currentUserId;

  ChatBloc({
    required this.getChatRoomsUseCase,
    required this.getOrCreateChatRoomUseCase,
    required this.getChatMessagesUseCase,
    required this.chatRepository,
    required this.webSocketService,
  }) : super(const ChatInitial()) {
    on<LoadChatRoomsEvent>(_onLoadChatRooms);
    on<OpenChatRoomEvent>(_onOpenChatRoom);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<ConnectToChatRoomEvent>(_onConnectToChatRoom);
    on<DisconnectFromChatRoomEvent>(_onDisconnectFromChatRoom);
    on<SendMessageEvent>(_onSendMessage);
    on<MessageReceivedEvent>(_onMessageReceived);
    on<MarkMessagesReadEvent>(_onMarkMessagesRead);
    on<TypingEvent>(_onTyping);
    on<TypingIndicatorReceivedEvent>(_onTypingIndicatorReceived);
    on<ConnectionStatusChangedEvent>(_onConnectionStatusChanged);
    on<MessagesReadReceivedEvent>(_onMessagesReadReceived);

    _initializeWebSocket();
  }

  /// Initialize WebSocket service and subscriptions.
  Future<void> _initializeWebSocket() async {
    // Configure WebSocket with auth token
    final token = await StorageService.getAccessToken();
    _currentUserId = await StorageService.getUserId();

    if (token != null) {
      webSocketService.configure(
        baseUrl: ApiBaseUrl.baseUrl,
        authToken: token,
      );
    }

    // Listen to WebSocket events
    _wsEventSubscription = webSocketService.eventStream.listen(_handleWsEvent);
    _wsStatusSubscription = webSocketService.statusStream.listen(_handleWsStatus);
  }

  /// Handle WebSocket events.
  void _handleWsEvent(ChatWebSocketEvent event) {
    switch (event.type) {
      case 'chat_message':
        final messageData = event.data['message'] as Map<String, dynamic>;
        add(MessageReceivedEvent(messageData: messageData));
        break;
      case 'typing':
        add(TypingIndicatorReceivedEvent(
          userId: event.data['user_id'] as int,
          userName: event.data['user_name'] as String,
          isTyping: event.data['is_typing'] as bool,
        ));
        break;
      case 'messages_read':
        add(MessagesReadReceivedEvent(
          messageIds: List<int>.from(event.data['message_ids'] as List),
          readByUserId: event.data['read_by'] as int,
        ));
        break;
      case 'connection_established':
        add(const ConnectionStatusChangedEvent(isConnected: true));
        break;
      case 'error':
        // Handle error if needed
        break;
    }
  }

  /// Handle WebSocket connection status changes.
  void _handleWsStatus(WebSocketStatus status) {
    final isConnected = status == WebSocketStatus.connected;
    add(ConnectionStatusChangedEvent(isConnected: isConnected));
  }

  /// Load all chat rooms.
  Future<void> _onLoadChatRooms(
    LoadChatRoomsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatRoomsLoading());

    try {
      final chatRooms = await getChatRoomsUseCase();

      if (chatRooms.isEmpty) {
        emit(const ChatRoomsEmpty());
      } else {
        emit(ChatRoomsLoaded(chatRooms: chatRooms));
      }
    } catch (e) {
      emit(ChatError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Open or create a chat room with another user.
  Future<void> _onOpenChatRoom(
    OpenChatRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatRoomOpening());

    try {
      final chatRoom = await getOrCreateChatRoomUseCase(event.otherUserId);

      emit(MessagesLoading(chatRoom: chatRoom));

      // Load messages and connect to WebSocket
      add(LoadMessagesEvent(chatRoomId: chatRoom.chatRoomId));
      add(ConnectToChatRoomEvent(chatRoomId: chatRoom.chatRoomId));
    } catch (e) {
      emit(ChatError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Load messages for a chat room.
  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;

    // Handle loading more messages
    if (event.loadMore && currentState is ChatRoomActive) {
      if (currentState.isLoadingMore || !currentState.hasMoreMessages) return;

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final oldestMessageId = currentState.messages.isNotEmpty
            ? currentState.messages.first.messageId
            : null;

        final result = await getChatMessagesUseCase(
          event.chatRoomId,
          limit: 50,
          beforeMessageId: oldestMessageId,
        );

        final allMessages = [...result.messages, ...currentState.messages];

        emit(currentState.copyWith(
          messages: allMessages,
          isLoadingMore: false,
          hasMoreMessages: result.hasMore,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
      return;
    }

    // Initial load
    try {
      final result = await getChatMessagesUseCase(event.chatRoomId, limit: 50);

      final chatRoom = currentState is MessagesLoading
          ? currentState.chatRoom
          : currentState is ChatRoomActive
              ? currentState.chatRoom
              : null;

      if (chatRoom == null) return;

      emit(ChatRoomActive(
        chatRoom: chatRoom,
        messages: result.messages,
        hasMoreMessages: result.hasMore,
        connectionStatus: webSocketService.status,
      ));
    } catch (e) {
      emit(ChatError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Connect to chat room WebSocket.
  Future<void> _onConnectToChatRoom(
    ConnectToChatRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    await webSocketService.connect(event.chatRoomId);
  }

  /// Disconnect from chat room WebSocket.
  Future<void> _onDisconnectFromChatRoom(
    DisconnectFromChatRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    await webSocketService.disconnect();
  }

  /// Send a message.
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatRoomActive) return;

    // Send via WebSocket if connected
    if (webSocketService.isConnected) {
      webSocketService.sendMessage(event.content, messageType: event.messageType);
    } else {
      // Fallback to REST API
      final currentState = state as ChatRoomActive;
      try {
        final message = await chatRepository.sendMessage(
          chatRoomId: currentState.chatRoom.chatRoomId,
          content: event.content,
          messageType: event.messageType,
        );

        // Add message to state
        emit(currentState.copyWith(
          messages: [...currentState.messages, message],
        ));
      } catch (e) {
        emit(ChatError(
          message: 'Failed to send message',
          previousState: currentState,
        ));
      }
    }
  }

  /// Handle received message from WebSocket.
  void _onMessageReceived(
    MessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatRoomActive) return;

    final currentState = state as ChatRoomActive;
    final chatRoomId = webSocketService.currentChatRoomId;

    if (chatRoomId == null) return;

    final message = MessageModel.fromWebSocketJson(
      event.messageData,
      chatRoomId: chatRoomId,
    );

    // Check if message already exists (avoid duplicates)
    final exists = currentState.messages.any(
      (m) => m.messageId == message.messageId,
    );

    if (!exists) {
      emit(currentState.copyWith(
        messages: [...currentState.messages, message],
        isOtherUserTyping: false, // Clear typing indicator on message receive
      ));

      // Auto-mark as read if not from current user
      if (message.sender.userId != _currentUserId) {
        webSocketService.markMessagesRead([message.messageId]);
      }
    }
  }

  /// Mark messages as read.
  Future<void> _onMarkMessagesRead(
    MarkMessagesReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatRepository.markChatRoomAsRead(event.chatRoomId);
    } catch (e) {
      // Silently fail - not critical
    }
  }

  /// Send typing indicator.
  void _onTyping(
    TypingEvent event,
    Emitter<ChatState> emit,
  ) {
    if (webSocketService.isConnected) {
      webSocketService.sendTypingIndicator(event.isTyping);
    }
  }

  /// Handle typing indicator from other user.
  void _onTypingIndicatorReceived(
    TypingIndicatorReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatRoomActive) return;
    if (event.userId == _currentUserId) return;

    final currentState = state as ChatRoomActive;
    emit(currentState.copyWith(
      isOtherUserTyping: event.isTyping,
      otherUserTypingName: event.isTyping ? event.userName : null,
    ));
  }

  /// Handle connection status change.
  void _onConnectionStatusChanged(
    ConnectionStatusChangedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatRoomActive) {
      final currentState = state as ChatRoomActive;
      emit(currentState.copyWith(
        connectionStatus: event.isConnected
            ? WebSocketStatus.connected
            : WebSocketStatus.disconnected,
      ));
    }
  }

  /// Handle messages read receipt.
  void _onMessagesReadReceived(
    MessagesReadReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatRoomActive) return;
    if (event.readByUserId == _currentUserId) return;

    final currentState = state as ChatRoomActive;

    // Update read status in messages
    final updatedMessages = currentState.messages.map((msg) {
      if (event.messageIds.contains(msg.messageId)) {
        return MessageModel(
          messageId: msg.messageId,
          chatRoomId: msg.chatRoomId,
          sender: msg.sender,
          content: msg.content,
          messageType: msg.messageType,
          isRead: true,
          readAt: DateTime.now(),
          createdAt: msg.createdAt,
        );
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(messages: updatedMessages));
  }

  /// Get current user ID.
  int? get currentUserId => _currentUserId;

  @override
  Future<void> close() {
    _wsEventSubscription?.cancel();
    _wsStatusSubscription?.cancel();
    webSocketService.dispose();
    return super.close();
  }
}
