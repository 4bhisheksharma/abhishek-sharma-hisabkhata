import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

class MessageInputArea extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;
  final String hintText;
  final TextEditingController? controller;

  const MessageInputArea({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
    this.hintText = 'Type a message...',
    this.controller,
  });

  @override
  State<MessageInputArea> createState() => _MessageInputAreaState();
}

class _MessageInputAreaState extends State<MessageInputArea> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: AppTheme.textHint),
                filled: true,
                fillColor: AppTheme.backgroundGrey,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              enabled: !widget.isLoading,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: widget.isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send_rounded, size: 20),
              color: Colors.white,
              disabledColor: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
