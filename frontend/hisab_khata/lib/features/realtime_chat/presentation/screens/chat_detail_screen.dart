import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme/app_theme.dart';
import '../../data/datasources/chat_websocket_service.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_list.dart';
import '../widgets/typing_indicator.dart';

/// Screen to display chat conversation with a user.
class ChatDetailScreen extends StatefulWidget {
  final int chatRoomId;
  final int? otherUserId;
  final String? otherUserName;

  const ChatDetailScreen({
    super.key,
    required this.chatRoomId,
    this.otherUserId,
    this.otherUserName,
  });

  /// Navigate to chat with another user (creates room if needed).
  static Future<void> openChat(
    BuildContext context, {
    required int otherUserId,
    String? otherUserName,
  }) async {
    // Trigger room creation/opening
    context.read<ChatBloc>().add(
      OpenChatRoomEvent(otherUserId: otherUserId, otherUserName: otherUserName),
    );

    // Navigate to screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          chatRoomId: 0, // Will be updated when room is created
          otherUserId: otherUserId,
          otherUserName: otherUserName,
        ),
      ),
    );
  }

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  ChatBloc? _chatBloc;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _chatBloc = context.read<ChatBloc>();
      _initializeChat();
    }
  }

  void _initializeChat() {
    if (_chatBloc == null) return;

    if (widget.otherUserId != null) {
      // Open chat room with user (creates if doesn't exist)
      _chatBloc!.add(
        OpenChatRoomEvent(
          otherUserId: widget.otherUserId!,
          otherUserName: widget.otherUserName,
        ),
      );
    } else if (widget.chatRoomId > 0) {
      // Load existing chat room
      _chatBloc!.add(LoadMessagesEvent(chatRoomId: widget.chatRoomId));
      _chatBloc!.add(ConnectToChatRoomEvent(chatRoomId: widget.chatRoomId));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Disconnect WebSocket when leaving chat
    _chatBloc?.add(const DisconnectFromChatRoomEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatRoomActive) {
          // Mark messages as read when entering chat
          context.read<ChatBloc>().add(
            MarkMessagesReadEvent(chatRoomId: state.chatRoom.chatRoomId),
          );
        }

        if (state is ChatError && state.previousState != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(appBar: _buildAppBar(state), body: _buildBody(state));
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ChatState state) {
    String title = widget.otherUserName ?? 'Chat';
    String? subtitle;
    int? currentUserId = context.read<ChatBloc>().currentUserId;

    if (state is ChatRoomActive) {
      title = state.chatRoom.getDisplayName(currentUserId ?? 0);

      // Show connection status or typing indicator
      if (state.isOtherUserTyping) {
        subtitle = 'typing...';
      } else if (state.connectionStatus != WebSocketStatus.connected) {
        subtitle = _getConnectionStatusText(state.connectionStatus);
      }
    } else if (state is MessagesLoading) {
      title = state.chatRoom.getDisplayName(currentUserId ?? 0);
    }

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppTheme.white.withOpacity(0.8),
              ),
            ),
        ],
      ),
      actions: [
        if (state is ChatRoomActive)
          _buildConnectionIndicator(state.connectionStatus),
      ],
    );
  }

  Widget _buildConnectionIndicator(WebSocketStatus status) {
    Color color;
    switch (status) {
      case WebSocketStatus.connected:
        color = AppTheme.successGreen;
        break;
      case WebSocketStatus.connecting:
      case WebSocketStatus.reconnecting:
        color = AppTheme.warningOrange;
        break;
      default:
        color = AppTheme.errorRed;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  String _getConnectionStatusText(WebSocketStatus status) {
    switch (status) {
      case WebSocketStatus.connecting:
        return 'Connecting...';
      case WebSocketStatus.reconnecting:
        return 'Reconnecting...';
      case WebSocketStatus.error:
        return 'Connection error';
      case WebSocketStatus.disconnected:
        return 'Disconnected';
      default:
        return '';
    }
  }

  Widget _buildBody(ChatState state) {
    if (state is ChatRoomOpening || state is MessagesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChatRoomActive) {
      return _buildChatBody(state);
    }

    if (state is ChatError) {
      return _buildErrorState(state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildChatBody(ChatRoomActive state) {
    final currentUserId = context.read<ChatBloc>().currentUserId ?? 0;

    return Column(
      children: [
        // Messages list
        Expanded(
          child: MessageList(
            messages: state.messages,
            currentUserId: currentUserId,
            isLoadingMore: state.isLoadingMore,
            hasMoreMessages: state.hasMoreMessages,
            scrollController: _scrollController,
            onLoadMore: () {
              context.read<ChatBloc>().add(
                LoadMessagesEvent(
                  chatRoomId: state.chatRoom.chatRoomId,
                  loadMore: true,
                ),
              );
            },
          ),
        ),

        // Typing indicator
        if (state.isOtherUserTyping)
          TypingIndicator(userName: state.otherUserTypingName),

        // Chat input
        ChatInput(
          enabled: state.connectionStatus == WebSocketStatus.connected,
          onSendMessage: (content) {
            context.read<ChatBloc>().add(SendMessageEvent(content: content));
          },
          onTypingChanged: (isTyping) {
            context.read<ChatBloc>().add(TypingEvent(isTyping: isTyping));
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(ChatError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
