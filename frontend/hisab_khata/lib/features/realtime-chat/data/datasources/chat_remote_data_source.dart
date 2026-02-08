import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../../../core/data/base_remote_data_source.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

/// Abstract class defining chat remote data source contract
abstract class ChatRemoteDataSource {
  /// Get all chat rooms for current user
  Future<List<ChatRoomModel>> getChatRooms();

  /// Get messages for a specific chat room
  Future<List<MessageModel>> getMessages(int chatRoomId);

  /// Send a message
  Future<MessageModel> sendMessage({
    required int chatRoomId,
    required String content,
    required MessageTypeModel messageType,
    String? fileUrl,
  });

  /// Mark messages as read
  Future<bool> markMessagesAsRead({required int chatRoomId});

  /// Get or create chat room for relationship
  Future<ChatRoomModel> getOrCreateChatRoom(int relationshipId);

  /// Connect to WebSocket for real-time updates
  Stream<Map<String, dynamic>> connectToChatRoom(int chatRoomId);

  /// Send message via WebSocket
  void sendMessageViaWebSocket(
    int chatRoomId,
    Map<String, dynamic> messageData,
  );

  /// Disconnect from WebSocket
  void disconnectWebSocket(int chatRoomId);
}

/// Implementation of ChatRemoteDataSource
class ChatRemoteDataSourceImpl extends BaseRemoteDataSource
    implements ChatRemoteDataSource {
  final Map<int, WebSocketChannel?> _webSocketChannels = {};
  final Map<int, StreamController<Map<String, dynamic>>> _messageControllers =
      {};

  ChatRemoteDataSourceImpl({super.client});

  @override
  Future<List<ChatRoomModel>> getChatRooms() async {
    final response = await get(ApiEndpoints.chatRooms);
    // DRF viewset returns list directly, not wrapped in 'data'
    final List<dynamic> data = response is List
        ? response
        : (response['results'] ?? []);
    return data.map((json) => ChatRoomModel.fromJson(json)).toList();
  }

  @override
  Future<List<MessageModel>> getMessages(int chatRoomId) async {
    final response = await get(ApiEndpoints.chatMessages(chatRoomId));
    // DRF ListAPIView returns paginated data or list directly
    final List<dynamic> data = response is List
        ? response
        : (response['results'] ?? []);
    return data.map((json) => MessageModel.fromJson(json)).toList();
  }

  /// Converts MessageTypeModel to snake_case string for backend
  String _messageTypeToString(MessageTypeModel type) {
    switch (type) {
      case MessageTypeModel.text:
        return 'text';
      case MessageTypeModel.image:
        return 'image';
      case MessageTypeModel.file:
        return 'file';
      case MessageTypeModel.transactionUpdate:
        return 'transaction_update';
      case MessageTypeModel.system:
        return 'system';
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required int chatRoomId,
    required String content,
    required MessageTypeModel messageType,
    String? fileUrl,
  }) async {
    final response = await post(
      ApiEndpoints.sendMessage,
      body: {
        'chat_room': chatRoomId,
        'content': content,
        'message_type': _messageTypeToString(messageType),
        'file_url': fileUrl,
      },
    );
    // DRF ModelViewSet.create returns the created object directly
    return MessageModel.fromJson(response);
  }

  @override
  Future<bool> markMessagesAsRead({required int chatRoomId}) async {
    final response = await post(
      ApiEndpoints.markChatRoomAsRead(chatRoomId),
      body: {},
    );
    return response['success'] ?? true;
  }

  @override
  Future<ChatRoomModel> getOrCreateChatRoom(int relationshipId) async {
    final response = await post(
      ApiEndpoints.getOrCreateChatRoom,
      body: {'relationship_id': relationshipId},
    );
    return ChatRoomModel.fromJson(response['chat_room']);
  }

  @override
  Stream<Map<String, dynamic>> connectToChatRoom(int chatRoomId) {
    // Create stream controller if it doesn't exist
    if (!_messageControllers.containsKey(chatRoomId)) {
      _messageControllers[chatRoomId] =
          StreamController<Map<String, dynamic>>.broadcast();
    }

    // Connect to WebSocket if not already connected
    if (_webSocketChannels[chatRoomId] == null) {
      final wsUrl = '${ApiEndpoints.webSocketBase}/ws/chat/$chatRoomId/';
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _webSocketChannels[chatRoomId] = channel;

      // Listen to WebSocket messages
      channel.stream.listen(
        (message) {
          final data = json.decode(message as String) as Map<String, dynamic>;
          _messageControllers[chatRoomId]?.add(data);
        },
        onError: (error) {
          _messageControllers[chatRoomId]?.addError(error);
        },
        onDone: () {
          _messageControllers[chatRoomId]?.close();
          _webSocketChannels[chatRoomId] = null;
        },
      );
    }

    return _messageControllers[chatRoomId]!.stream;
  }

  @override
  void sendMessageViaWebSocket(
    int chatRoomId,
    Map<String, dynamic> messageData,
  ) {
    final channel = _webSocketChannels[chatRoomId];
    if (channel != null) {
      channel.sink.add(json.encode(messageData));
    }
  }

  @override
  void disconnectWebSocket(int chatRoomId) {
    final channel = _webSocketChannels[chatRoomId];
    if (channel != null) {
      channel.sink.close(status.goingAway);
      _webSocketChannels[chatRoomId] = null;
    }

    _messageControllers[chatRoomId]?.close();
    _messageControllers.remove(chatRoomId);
  }
}
