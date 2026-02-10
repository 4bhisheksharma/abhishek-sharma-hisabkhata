import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/realtime_chat/data/datasources/chat_remote_data_source.dart';
import 'package:hisab_khata/features/realtime_chat/data/datasources/chat_websocket_service.dart';
import 'package:hisab_khata/features/realtime_chat/data/repositories_imp/chat_repository_impl.dart';
import 'package:hisab_khata/features/realtime_chat/domain/usecases/get_chat_messages_usecase.dart';
import 'package:hisab_khata/features/realtime_chat/domain/usecases/get_chat_rooms_usecase.dart';
import 'package:hisab_khata/features/realtime_chat/domain/usecases/get_or_create_chat_room_usecase.dart';
import 'package:hisab_khata/features/realtime_chat/presentation/bloc/chat_bloc.dart';

/// Provider widget to set up ChatBloc with all dependencies.
class ChatProvider extends StatelessWidget {
  final Widget child;

  const ChatProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Create dependencies
    final remoteDataSource = ChatRemoteDataSourceImpl();
    final repository = ChatRepositoryImpl(remoteDataSource: remoteDataSource);
    final webSocketService = ChatWebSocketService();

    return BlocProvider(
      create: (context) => ChatBloc(
        getChatRoomsUseCase: GetChatRoomsUseCase(repository: repository),
        getOrCreateChatRoomUseCase: GetOrCreateChatRoomUseCase(
          repository: repository,
        ),
        getChatMessagesUseCase: GetChatMessagesUseCase(repository: repository),
        chatRepository: repository,
        webSocketService: webSocketService,
      ),
      child: child,
    );
  }
}

/// Helper function to wrap a widget with ChatProvider.
Widget withChatProvider(Widget child) {
  return ChatProvider(child: child);
}
