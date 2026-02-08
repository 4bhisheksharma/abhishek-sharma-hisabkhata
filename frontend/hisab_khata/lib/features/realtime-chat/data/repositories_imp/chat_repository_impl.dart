import 'dart:async';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/message_status_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import '../models/message_status_model.dart';

/// Implementation of ChatRepository
/// Handles data operations and converts between models and entities
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ChatRoomEntity>> getChatRooms() async* {
    // Initial load from API
    try {
      final chatRoomModels = await remoteDataSource.getChatRooms();
      final chatRoomEntities = chatRoomModels
          .map((model) => _chatRoomModelToEntity(model))
          .toList();
      yield chatRoomEntities;
    } catch (e) {
      yield [];
    }

    // For real-time updates, we could listen to a global chat rooms stream
    // For now, just return the initial data
  }

  @override
  Stream<List<MessageEntity>> getMessages(int chatRoomId) async* {
    // Initial load from API
    try {
      final messageModels = await remoteDataSource.getMessages(chatRoomId);
      final messageEntities = messageModels
          .map((model) => _messageModelToEntity(model))
          .toList();
      yield messageEntities;
    } catch (e) {
      yield [];
    }

    // Connect to WebSocket for real-time updates
    final webSocketStream = remoteDataSource.connectToChatRoom(chatRoomId);

    List<MessageEntity> currentMessages = [];
    await for (final data in webSocketStream) {
      if (data['type'] == 'new_message') {
        final messageModel = MessageModel.fromJson(data['message']);
        final messageEntity = _messageModelToEntity(messageModel);
        currentMessages = [...currentMessages, messageEntity];
        yield currentMessages;
      } else if (data['type'] == 'message_updated') {
        final messageModel = MessageModel.fromJson(data['message']);
        final messageEntity = _messageModelToEntity(messageModel);
        currentMessages = currentMessages.map((msg) {
          return msg.messageId == messageEntity.messageId ? messageEntity : msg;
        }).toList();
        yield currentMessages;
      } else if (data['type'] == 'message_deleted') {
        final messageId = data['message_id'] as int;
        currentMessages = currentMessages
            .where((msg) => msg.messageId != messageId)
            .toList();
        yield currentMessages;
      }
    }
  }

  @override
  Future<MessageEntity> sendMessage({
    required int chatRoomId,
    required String content,
    required MessageType messageType,
    String? fileUrl,
  }) async {
    final messageModel = await remoteDataSource.sendMessage(
      chatRoomId: chatRoomId,
      content: content,
      messageType: _messageTypeEntityToModel(messageType),
      fileUrl: fileUrl,
    );

    // Also send via WebSocket for real-time updates
    remoteDataSource.sendMessageViaWebSocket(chatRoomId, {
      'type': 'send_message',
      'content': content,
      'message_type': messageType.name,
      'file_url': fileUrl,
    });

    return _messageModelToEntity(messageModel);
  }

  @override
  Future<bool> markMessagesAsRead({required int chatRoomId}) async {
    final result = await remoteDataSource.markMessagesAsRead(
      chatRoomId: chatRoomId,
    );

    // Send read receipt via WebSocket
    remoteDataSource.sendMessageViaWebSocket(chatRoomId, {
      'type': 'mark_as_read',
    });

    return result;
  }

  @override
  Stream<List<MessageStatusEntity>> getMessageStatuses(int chatRoomId) async* {
    // Connect to WebSocket for status updates
    final webSocketStream = remoteDataSource.connectToChatRoom(chatRoomId);

    List<MessageStatusEntity> currentStatuses = [];
    await for (final data in webSocketStream) {
      if (data['type'] == 'status_update') {
        final statusModel = MessageStatusModel.fromJson(data['status']);
        final statusEntity = _messageStatusModelToEntity(statusModel);
        currentStatuses = [...currentStatuses, statusEntity];
        yield currentStatuses;
      }
    }
  }

  @override
  Future<ChatRoomEntity> getOrCreateChatRoom(int relationshipId) async {
    final chatRoomModel = await remoteDataSource.getOrCreateChatRoom(
      relationshipId,
    );
    return _chatRoomModelToEntity(chatRoomModel);
  }

  // Helper methods for converting between models and entities

  ChatRoomEntity _chatRoomModelToEntity(ChatRoomModel model) {
    return ChatRoomEntity(
      chatRoomId: model.chatRoomId,
      relationshipId: model.relationshipId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  MessageEntity _messageModelToEntity(MessageModel model) {
    return MessageEntity(
      messageId: model.messageId,
      chatRoomId: model.chatRoomId,
      senderId: model.senderId,
      messageType: _messageTypeModelToEntity(model.messageType),
      content: model.content,
      fileUrl: model.fileUrl,
      isEdited: model.isEdited,
      isDeleted: model.isDeleted,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  MessageStatusEntity _messageStatusModelToEntity(MessageStatusModel model) {
    return MessageStatusEntity(
      messageStatusId: model.messageStatusId,
      messageId: model.messageId,
      userId: model.userId,
      status: _messageStatusTypeModelToEntity(model.status),
      timestamp: model.timestamp,
    );
  }

  MessageType _messageTypeModelToEntity(MessageTypeModel model) {
    switch (model) {
      case MessageTypeModel.text:
        return MessageType.text;
      case MessageTypeModel.image:
        return MessageType.image;
      case MessageTypeModel.file:
        return MessageType.file;
      case MessageTypeModel.transactionUpdate:
        return MessageType.transactionUpdate;
      case MessageTypeModel.system:
        return MessageType.system;
    }
  }

  MessageTypeModel _messageTypeEntityToModel(MessageType entity) {
    switch (entity) {
      case MessageType.text:
        return MessageTypeModel.text;
      case MessageType.image:
        return MessageTypeModel.image;
      case MessageType.file:
        return MessageTypeModel.file;
      case MessageType.transactionUpdate:
        return MessageTypeModel.transactionUpdate;
      case MessageType.system:
        return MessageTypeModel.system;
    }
  }

  MessageStatusType _messageStatusTypeModelToEntity(
    MessageStatusTypeModel model,
  ) {
    switch (model) {
      case MessageStatusTypeModel.sent:
        return MessageStatusType.sent;
      case MessageStatusTypeModel.delivered:
        return MessageStatusType.delivered;
      case MessageStatusTypeModel.read:
        return MessageStatusType.read;
    }
  }
}
