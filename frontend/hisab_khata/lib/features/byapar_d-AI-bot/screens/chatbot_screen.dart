import 'package:flutter/material.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import '../services/chatbot_service.dart';

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotService _chatbotService = ChatbotService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
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
      _messages.add(Message(text: text, isUser: true));
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
            _messages.last = Message(text: botResponse, isUser: false);
          } else {
            _messages.add(Message(text: botResponse, isUser: false));
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add(Message(text: 'Error: $e', isUser: false));
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
                return _buildMessageBubble(context, message);
              },
            ),
          ),
          if (_isLoading) _buildLoadingIndicator(context),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            CircleAvatar(
              backgroundImage: const AssetImage('assets/images/byapar-dAI.png'),
              radius: 20,
            ),
          if (!message.isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            CircleAvatar(
              backgroundImage: userImageUrl != null
                  ? NetworkImage(userImageUrl!)
                  : null,
              radius: 20,
              child: userImageUrl == null ? const Icon(Icons.person) : null,
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: Theme.of(context).primaryColor,
        size: 32,
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.typeMessage,
                filled: true,
                fillColor: Colors.grey[100],
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
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isLoading ? null : _sendMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
