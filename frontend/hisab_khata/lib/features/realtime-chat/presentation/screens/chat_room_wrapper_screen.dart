import 'package:flutter/material.dart';
import '../../../../core/di/dependency_injection.dart';
import 'chat_room_screen.dart';

/// Wrapper screen that creates/retrieves chat room before opening the chat
class ChatRoomWrapperScreen extends StatefulWidget {
  final int relationshipId;
  final String? otherUserName;

  const ChatRoomWrapperScreen({
    super.key,
    required this.relationshipId,
    this.otherUserName,
  });

  @override
  State<ChatRoomWrapperScreen> createState() => _ChatRoomWrapperScreenState();
}

class _ChatRoomWrapperScreenState extends State<ChatRoomWrapperScreen> {
  bool _isLoading = true;
  String? _error;
  int? _chatRoomId;

  @override
  void initState() {
    super.initState();
    _getOrCreateChatRoom();
  }

  Future<void> _getOrCreateChatRoom() async {
    try {
      final useCase = DependencyInjection().getOrCreateChatRoomUseCase;
      final chatRoom = await useCase(widget.relationshipId);

      if (mounted) {
        setState(() {
          _chatRoomId = chatRoom.chatRoomId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.otherUserName ?? 'Chat')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.otherUserName ?? 'Chat')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load chat',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _getOrCreateChatRoom();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Navigate to actual chat room screen
    return ChatRoomScreen(
      chatRoomId: _chatRoomId!,
      otherUserName: widget.otherUserName,
    );
  }
}
