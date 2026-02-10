import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_theme.dart';
import '../../domain/entities/message_entity.dart';
import 'message_bubble.dart';

/// Widget to display a scrollable list of messages with date separators.
class MessageList extends StatefulWidget {
  final List<MessageEntity> messages;
  final int currentUserId;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final VoidCallback? onLoadMore;
  final ScrollController? scrollController;

  const MessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
    this.isLoadingMore = false,
    this.hasMoreMessages = true,
    this.onLoadMore,
    this.scrollController,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    // Load more when scrolled near the top (messages are reversed)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (widget.hasMoreMessages && !widget.isLoadingMore) {
        widget.onLoadMore?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: AppTheme.lightGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Build list items with date separators
    final items = _buildListItems();

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (widget.isLoadingMore && index == items.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final item = items[index];

        if (item is _DateSeparator) {
          return _buildDateSeparator(item.date);
        }

        final messageItem = item as _MessageItem;
        return MessageBubble(
          message: messageItem.message,
          isFromCurrentUser:
              messageItem.message.sender.userId == widget.currentUserId,
          isFirstInGroup: messageItem.isFirstInGroup,
          isLastInGroup: messageItem.isLastInGroup,
        );
      },
    );
  }

  List<_ListItem> _buildListItems() {
    final items = <_ListItem>[];

    // With ListView.reverse=true, index 0 appears at BOTTOM
    // So we process messages newest→oldest, putting newest at index 0
    final reversedMessages = widget.messages.reversed.toList();

    for (int i = 0; i < reversedMessages.length; i++) {
      final message = reversedMessages[i];
      final messageDate = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );

      // In reversed list: prev = newer message, next = older message
      final prevMessage = i > 0 ? reversedMessages[i - 1] : null;
      final nextMessage = i + 1 < reversedMessages.length
          ? reversedMessages[i + 1]
          : null;

      // isLastInGroup: bottom of group visually (newer message is different or none)
      final isLastInGroup =
          prevMessage == null ||
          prevMessage.sender.userId != message.sender.userId ||
          _isDifferentDay(message.createdAt, prevMessage.createdAt);

      // isFirstInGroup: top of group visually (older message is different or none)
      final isFirstInGroup =
          nextMessage == null ||
          nextMessage.sender.userId != message.sender.userId ||
          _isDifferentDay(message.createdAt, nextMessage.createdAt);

      items.add(
        _MessageItem(
          message: message,
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
        ),
      );

      // Add date separator after all messages of this date
      // (appears above messages visually due to reverse)
      final nextMsgDate = nextMessage != null
          ? DateTime(
              nextMessage.createdAt.year,
              nextMessage.createdAt.month,
              nextMessage.createdAt.day,
            )
          : null;

      if (nextMsgDate == null || nextMsgDate != messageDate) {
        items.add(_DateSeparator(date: messageDate));
      }
    }

    return items;
  }

  bool _isDifferentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String label;
    if (messageDate == today) {
      label = 'Today';
    } else if (messageDate == yesterday) {
      label = 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      label = DateFormat('EEEE').format(date);
    } else {
      label = DateFormat('MMMM d, y').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppTheme.lightGrey)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppTheme.lightGrey)),
        ],
      ),
    );
  }
}

/// Base class for list items.
abstract class _ListItem {}

/// Date separator item.
class _DateSeparator extends _ListItem {
  final DateTime date;
  _DateSeparator({required this.date});
}

/// Message item.
class _MessageItem extends _ListItem {
  final MessageEntity message;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  _MessageItem({
    required this.message,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });
}
