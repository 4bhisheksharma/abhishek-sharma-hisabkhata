import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_room_list_item.dart';
import 'chat_room_screen.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChatRoomsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), elevation: 1),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatRoomsLoaded) {
            if (state.chatRooms.isEmpty) {
              return const Center(child: Text('No chat rooms available'));
            }
            return ListView.builder(
              itemCount: state.chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = state.chatRooms[index];
                return ChatRoomListItem(
                  chatRoom: chatRoom,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatRoomScreen(chatRoomId: chatRoom.chatRoomId),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is ChatError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No chat rooms found'));
        },
      ),
    );
  }
}
