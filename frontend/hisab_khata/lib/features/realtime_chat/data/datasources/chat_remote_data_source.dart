import '../../../../core/data/base_remote_data_source.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

/// Abstract class defining chat remote data source contract.
abstract class ChatRemoteDataSource {
  /// Get all chat rooms for current user.
  Future<List<ChatRoomModel>> getChatRooms();

  /// Get or create a chat room with another user.
  Future<ChatRoomModel> getOrCreateChatRoom(int otherUserId);

  /// Get messages for a chat room.
  Future<ChatMessagesResponse> getChatMessages(
    int chatRoomId, {
    int? limit,
    int? beforeMessageId,
  });

  /// Mark all messages in a chat room as read.
  Future<void> markChatRoomAsRead(int chatRoomId);

  /// Send a message via REST API (fallback).
  Future<MessageModel> sendMessage({
    required int chatRoomId,
    required String content,
    String messageType = 'text',
  });
}

/// Response wrapper for paginated messages.
class ChatMessagesResponse {
  final List<MessageModel> messages;
  final bool hasMore;

  ChatMessagesResponse({
    required this.messages,
    required this.hasMore,
  });
}

/// Implementation of ChatRemoteDataSource.
class ChatRemoteDataSourceImpl extends BaseRemoteDataSource
    implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({super.client});

  @override
  Future<List<ChatRoomModel>> getChatRooms() async {
    final response = await get(ApiEndpoints.chatRooms);

    if (response is List) {
      return response
          .map((json) => ChatRoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<ChatRoomModel> getOrCreateChatRoom(int otherUserId) async {
    final response = await post(
      ApiEndpoints.getOrCreateChatRoom,
      body: {'other_user_id': otherUserId},
    );

    return ChatRoomModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ChatMessagesResponse> getChatMessages(
    int chatRoomId, {
    int? limit,
    int? beforeMessageId,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (beforeMessageId != null) {
      queryParams['before'] = beforeMessageId.toString();
    }

    final response = await get(
      ApiEndpoints.chatMessages(chatRoomId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response as Map<String, dynamic>;
    final messagesList = data['messages'] as List;

    return ChatMessagesResponse(
      messages: messagesList
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList(),
      hasMore: data['has_more'] as bool? ?? false,
    );
  }

  @override
  Future<void> markChatRoomAsRead(int chatRoomId) async {
    await post(ApiEndpoints.markChatRoomAsRead(chatRoomId), body: {});
  }

  @override
  Future<MessageModel> sendMessage({
    required int chatRoomId,
    required String content,
    String messageType = 'text',
  }) async {
    final response = await post(
      ApiEndpoints.sendMessage,
      body: {
        'chat_room': chatRoomId,
        'content': content,
        'message_type': messageType,
      },
    );

    return MessageModel.fromJson(response as Map<String, dynamic>);
  }
}
