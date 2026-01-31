import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/shared/widgets/chat/chat_loading_indicator.dart';
import 'package:hisab_khata/shared/widgets/chat/chat_message.dart';
import 'package:hisab_khata/shared/widgets/chat/message_bubble.dart';
import 'package:hisab_khata/shared/widgets/chat/message_input_area.dart';
import '../../domain/entities/message_entity.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatRoomScreen extends StatefulWidget {
  final int chatRoomId;

  const ChatRoomScreen({super.key, required this.chatRoomId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(SelectChatRoomEvent(widget.chatRoomId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatBloc>().add(SendMessageEvent(text, MessageType.text));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room ${widget.chatRoomId}'),
        elevation: 1,
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is MessageSent) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is ChatRoomSelected) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return MessageBubble(
                        message: ChatMessage(
                          text: message.content,
                          isUser:
                              message.senderId ==
                              1, // TODO: Get current user ID
                          timestamp: message.createdAt,
                        ),
                      );
                    },
                  ),
                ),
                if (state.isLoadingMessages) const ChatLoadingIndicator(),
                MessageInputArea(
                  onSendMessage: (text) {
                    _messageController.text = text;
                    _sendMessage();
                  },
                  isLoading: state is MessageSending,
                  hintText: 'Type a message...',
                  controller: _messageController,
                ),
              ],
            );
          } else if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Loading chat...'));
        },
      ),
    );
  }
}
