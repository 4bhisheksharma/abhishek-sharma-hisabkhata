import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket connection status.
enum WebSocketStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Represents a WebSocket event received from the server.
class ChatWebSocketEvent {
  final String type;
  final Map<String, dynamic> data;

  const ChatWebSocketEvent({required this.type, required this.data});
}

/// Service for managing WebSocket connections for real-time chat.
class ChatWebSocketService {
  WebSocketChannel? _channel;
  final StreamController<ChatWebSocketEvent> _eventController =
      StreamController<ChatWebSocketEvent>.broadcast();
  final StreamController<WebSocketStatus> _statusController =
      StreamController<WebSocketStatus>.broadcast();

  String? _baseUrl;
  String? _authToken;
  int? _currentChatRoomId;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  /// Stream of WebSocket events (messages, typing indicators, etc.).
  Stream<ChatWebSocketEvent> get eventStream => _eventController.stream;

  /// Stream of connection status updates.
  Stream<WebSocketStatus> get statusStream => _statusController.stream;

  /// Current connection status.
  WebSocketStatus _status = WebSocketStatus.disconnected;
  WebSocketStatus get status => _status;

  /// Whether currently connected.
  bool get isConnected => _status == WebSocketStatus.connected;

  /// Current chat room ID.
  int? get currentChatRoomId => _currentChatRoomId;

  /// Initialize WebSocket URL configuration.
  void configure({required String baseUrl, required String authToken}) {
    _baseUrl = baseUrl;
    _authToken = authToken;
  }

  /// Connect to a chat room WebSocket.
  Future<void> connect(int chatRoomId) async {
    // Disconnect from current room if different
    if (_currentChatRoomId != null && _currentChatRoomId != chatRoomId) {
      await disconnect();
    }

    if (_channel != null && _currentChatRoomId == chatRoomId) {
      return; // Already connected to this room
    }

    _currentChatRoomId = chatRoomId;
    _updateStatus(WebSocketStatus.connecting);

    try {
      final wsUrl = _buildWebSocketUrl(chatRoomId);
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(_onMessage, onError: _onError, onDone: _onDone);

      _updateStatus(WebSocketStatus.connected);
      _reconnectAttempts = 0;
    } catch (e) {
      _updateStatus(WebSocketStatus.error);
      _scheduleReconnect();
    }
  }

  /// Disconnect from the current chat room.
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;

    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }

    _currentChatRoomId = null;
    _updateStatus(WebSocketStatus.disconnected);
  }

  /// Send a chat message.
  void sendMessage(String content, {String messageType = 'text'}) {
    _send({
      'type': 'chat_message',
      'content': content,
      'message_type': messageType,
    });
  }

  /// Send typing indicator.
  void sendTypingIndicator(bool isTyping) {
    _send({'type': 'typing', 'is_typing': isTyping});
  }

  /// Mark messages as read.
  void markMessagesRead(List<int> messageIds) {
    _send({'type': 'mark_read', 'message_ids': messageIds});
  }

  /// Send raw data to WebSocket.
  void _send(Map<String, dynamic> data) {
    if (_channel != null && isConnected) {
      _channel!.sink.add(json.encode(data));
    }
  }

  /// Build WebSocket URL with authentication.
  String _buildWebSocketUrl(int chatRoomId) {
    // Convert http(s) URL to ws(s) URL
    String wsUrl = _baseUrl ?? 'ws://10.0.2.2:8000';

    // Remove trailing slash and /api/ if present
    wsUrl = wsUrl.replaceAll(RegExp(r'/api/?$'), '');
    wsUrl = wsUrl.replaceAll('http://', 'ws://');
    wsUrl = wsUrl.replaceAll('https://', 'wss://');

    return '$wsUrl/ws/chat/$chatRoomId/?token=$_authToken';
  }

  /// Handle incoming WebSocket message.
  void _onMessage(dynamic message) {
    try {
      final data = json.decode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String? ?? 'unknown';

      _eventController.add(ChatWebSocketEvent(type: type, data: data));
    } catch (e) {
      // Ignore malformed messages
    }
  }

  /// Handle WebSocket error.
  void _onError(Object error) {
    _updateStatus(WebSocketStatus.error);
    _scheduleReconnect();
  }

  /// Handle WebSocket connection closed.
  void _onDone() {
    if (_status != WebSocketStatus.disconnected) {
      _updateStatus(WebSocketStatus.disconnected);
      _scheduleReconnect();
    }
  }

  /// Schedule a reconnection attempt.
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    if (_currentChatRoomId == null) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_currentChatRoomId != null) {
        _reconnectAttempts++;
        _updateStatus(WebSocketStatus.reconnecting);
        connect(_currentChatRoomId!);
      }
    });
  }

  /// Update connection status and notify listeners.
  void _updateStatus(WebSocketStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  /// Dispose resources.
  void dispose() {
    _reconnectTimer?.cancel();
    _eventController.close();
    _statusController.close();
    _channel?.sink.close();
  }
}
