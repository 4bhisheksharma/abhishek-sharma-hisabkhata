import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/realtime-chat/data/datasources/chat_remote_data_source.dart';
import 'package:hisab_khata/features/realtime-chat/domain/entities/chat_room_entity.dart';
import 'package:hisab_khata/features/realtime-chat/domain/entities/message_entity.dart';
import '../../domain/usecases/get_chat_rooms_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/mark_messages_as_read_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatRoomsUseCase getChatRoomsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MarkMessagesAsReadUseCase markMessagesAsReadUseCase;

  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  int? _currentChatRoomId;

  ChatBloc({
    required this.getChatRoomsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.markMessagesAsReadUseCase,
  }) : super(ChatInitial()) {
    on<LoadChatRoomsEvent>(_onLoadChatRooms);
    on<SelectChatRoomEvent>(_onSelectChatRoom);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);
    on<LoadMessagesEvent>(_onLoadMessages);
  }

  Future<void> _onLoadChatRooms(
    LoadChatRoomsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final chatRoomsStream = getChatRoomsUseCase();
      await for (final chatRooms in chatRoomsStream) {
        emit(ChatRoomsLoaded(chatRooms));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSelectChatRoom(
    SelectChatRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Cancel previous subscription
    await _messagesSubscription?.cancel();

    _currentChatRoomId = event.chatRoomId;
    emit(ChatLoading());

    try {
      // Get chat room details (you might need to add this to the repository)
      // For now, we'll create a placeholder
      final chatRoom = ChatRoomEntity(
        chatRoomId: event.chatRoomId,
        relationshipId: 0, // This should come from repository
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Load messages
      _messagesSubscription = getMessagesUseCase(chatRoomId: event.chatRoomId)
          .listen(
            (messages) {
              add(LoadMessagesEvent(event.chatRoomId));
            },
            onError: (error) {
              emit(ChatError(error.toString()));
            },
          );

      emit(ChatRoomSelected(chatRoom, [], true));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatRoomSelected) {
      final currentState = state as ChatRoomSelected;
      try {
        final messagesStream = getMessagesUseCase(chatRoomId: event.chatRoomId);
        await for (final messages in messagesStream) {
          emit(ChatRoomSelected(currentState.chatRoom, messages, false));
        }
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatRoomSelected) {
      final currentState = state as ChatRoomSelected;
      emit(MessageSending(currentState.chatRoom, currentState.messages));

      try {
        await sendMessageUseCase(
          chatRoomId: _currentChatRoomId!,
          content: event.content,
          messageType: event.messageType,
        );

        // The message will be added via the stream subscription
        emit(MessageSent(currentState.chatRoom, currentState.messages));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await markMessagesAsReadUseCase(chatRoomId: _currentChatRoomId!);
    } catch (e) {
      // Don't emit error for read receipts, just log
      print('Failed to mark messages as read: $e');
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
