import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/my_snackbar.dart';
import '../../data/datasources/chat_websocket_service.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_list.dart';
import '../widgets/typing_indicator.dart';
import '../../../../shared/widgets/shimmer/shimmer_widgets.dart';

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
          MySnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundGrey,
          appBar: _buildAppBar(state),
          body: _buildBody(state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ChatState state) {
    String displayName =
        widget.otherUserName ?? AppLocalizations.of(context)!.user;
    String? subtitle;
    int? currentUserId = context.read<ChatBloc>().currentUserId;
    WebSocketStatus connectionStatus = WebSocketStatus.disconnected;

    if (state is ChatRoomActive) {
      displayName = state.chatRoom.getDisplayName(currentUserId ?? 0);
      connectionStatus = state.connectionStatus;

      if (state.isOtherUserTyping) {
        subtitle = AppLocalizations.of(context)!.typing;
      } else if (state.connectionStatus == WebSocketStatus.connected) {
        subtitle = AppLocalizations.of(context)!.online;
      } else {
        subtitle = _getConnectionStatusText(context, state.connectionStatus);
      }
    } else if (state is MessagesLoading) {
      displayName = state.chatRoom.getDisplayName(currentUserId ?? 0);
      subtitle = AppLocalizations.of(context)!.loading;
    }

    return AppBar(
      backgroundColor: AppTheme.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  _getInitials(displayName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (state is ChatRoomActive)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(connectionStatus),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryBlue, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(WebSocketStatus status) {
    switch (status) {
      case WebSocketStatus.connected:
        return AppTheme.successGreen;
      case WebSocketStatus.connecting:
      case WebSocketStatus.reconnecting:
        return AppTheme.warningOrange;
      default:
        return AppTheme.lightGrey;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _getConnectionStatusText(
    BuildContext context,
    WebSocketStatus status,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case WebSocketStatus.connecting:
        return l10n.connecting;
      case WebSocketStatus.reconnecting:
        return l10n.reconnecting;
      case WebSocketStatus.error:
        return l10n.connectionError;
      case WebSocketStatus.disconnected:
        return l10n.disconnected;
      default:
        return '';
    }
  }

  Widget _buildBody(ChatState state) {
    if (state is ChatRoomOpening || state is MessagesLoading) {
      return const ChatMessagesShimmer();
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: AppTheme.errorRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.unableToLoadChat,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.goBack),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.dividerColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
