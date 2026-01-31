import 'package:flutter/material.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/widgets/chat/chat_loading_indicator.dart';
import 'package:hisab_khata/shared/widgets/chat/chat_message.dart';
import 'package:hisab_khata/shared/widgets/chat/message_bubble.dart';
import 'package:hisab_khata/shared/widgets/chat/message_input_area.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import '../services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotService _chatbotService = ChatbotService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? userImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserImage();
  }

  void _loadUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_picture');
    setState(() {
      userImageUrl = imagePath != null
          ? ImageUtils.getFullImageUrl(imagePath)
          : null;
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      String botResponse = '';
      await for (final chunk in _chatbotService.sendMessageStream(text)) {
        setState(() {
          botResponse += chunk;
          if (_messages.isNotEmpty && !_messages.last.isUser) {
            _messages.last = ChatMessage(
              text: botResponse,
              isUser: false,
              timestamp: DateTime.now(),
            );
          } else {
            _messages.add(
              ChatMessage(
                text: botResponse,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Error: $e',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        title: Text(AppLocalizations.of(context)!.byaparAI),
        elevation: 1,
      ),
      body: Column(
        children: [
          Center(
            child: Image.asset(
              'assets/images/byapar-dAI.png',
              height: 110,
              width: 110,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  message: message,
                  botAvatar: CircleAvatar(
                    backgroundImage: const AssetImage(
                      'assets/images/byapar-dAI.png',
                    ),
                    radius: 20,
                  ),
                  userAvatar: CircleAvatar(
                    backgroundImage: userImageUrl != null
                        ? NetworkImage(userImageUrl!)
                        : null,
                    radius: 20,
                    child: userImageUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const ChatLoadingIndicator(),
          MessageInputArea(
            onSendMessage: (text) {
              _controller.text = text;
              _sendMessage();
            },
            isLoading: _isLoading,
            hintText: AppLocalizations.of(context)!.typeMessage,
            controller: _controller,
          ),
        ],
      ),
    );
  }
}
