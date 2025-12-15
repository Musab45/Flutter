import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/signalr_service.dart';
import '../services/connectivity_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SignalRService _signalRService = SignalRService();
  final ConnectivityService _connectivityService = ConnectivityService();

  List<Chat> _chats = [];
  Map<int, List<Message>> _messagesByChat = {};
  Map<int, bool> _typingUsers = {};

  bool _isConnected = false;
  bool _isLoading = false;
  bool _isOnline = true;
  String? _error;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  bool _shouldStopReconnecting = false;

  List<Chat> get chats => _chats;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  bool get isReconnecting => _isReconnecting;
  String? get error => _error;
  int get reconnectAttempts => _reconnectAttempts;

  List<Message> getMessages(int chatId) => _messagesByChat[chatId] ?? [];
  bool isUserTyping(int chatId) => _typingUsers[chatId] ?? false;

  Future<void> initialize(String token, User user) async {
    // Initialize connectivity service
    await _connectivityService.initialize();
    _isOnline = _connectivityService.isOnline;

    // Listen to connectivity changes
    _connectivityService.onConnectivityChanged = (isOnline) {
      _isOnline = isOnline;
      notifyListeners();

      if (isOnline) {
        print('📡 Network restored - attempting to reconnect...');
        _handleNetworkRestored();
      } else {
        print('📡 Network lost');
        _isConnected = false;
        notifyListeners();
      }
    };

    await connectToSignalR();
    await loadChats();
  }

  Future<void> _handleNetworkRestored() async {
    // Reset reconnection state when network is restored
    _reconnectAttempts = 0;
    _shouldStopReconnecting = false;

    // Try to reconnect SignalR
    if (!_isConnected) {
      try {
        _isReconnecting = true;
        notifyListeners();

        await connectToSignalR();

        // Rejoin all active chats
        for (var chatId in _messagesByChat.keys) {
          if (_isConnected) {
            await _signalRService.joinChat(chatId);
          }
        }

        _isReconnecting = false;
        notifyListeners();
      } catch (e) {
        _isReconnecting = false;
        print('❌ Failed to reconnect: $e');
        notifyListeners();
      }
    }
  }

  Future<void> connectToSignalR() async {
    if (!_isOnline) {
      _error = 'No internet connection';
      _isConnected = false;
      notifyListeners();
      return;
    }

    try {
      // Setup event handlers
      _signalRService.onMessageReceived = _handleMessageReceived;
      _signalRService.onUserTyping = _handleUserTyping;
      _signalRService.onConnected = () {
        _isConnected = true;
        _isReconnecting = false;
        _reconnectAttempts = 0; // Reset on successful connection
        _shouldStopReconnecting = false;
        _error = null;
        print('✅ SignalR connected');
        notifyListeners();
      };
      _signalRService.onDisconnected = () {
        _isConnected = false;
        print('❌ SignalR disconnected');
        notifyListeners();

        // Only try to reconnect if we haven't exceeded max attempts and should continue
        if (_isOnline &&
            !_shouldStopReconnecting &&
            _reconnectAttempts < _maxReconnectAttempts) {
          _reconnectAttempts++;

          // Exponential backoff: 2s, 4s, 8s, 16s, 32s
          final delaySeconds = (2 * (1 << (_reconnectAttempts - 1))).clamp(
            2,
            32,
          );

          print(
            '🔄 Attempting auto-reconnect (${_reconnectAttempts}/$_maxReconnectAttempts) in ${delaySeconds}s...',
          );

          Future.delayed(Duration(seconds: delaySeconds), () {
            if (!_isConnected && _isOnline && !_shouldStopReconnecting) {
              connectToSignalR();
            }
          });
        } else if (_reconnectAttempts >= _maxReconnectAttempts) {
          _error =
              'Failed to connect after $_maxReconnectAttempts attempts. Tap retry to try again.';
          _isReconnecting = false;
          print('❌ Max reconnect attempts reached');
          notifyListeners();
        }
      };
      _signalRService.onError = (error) {
        // Check if it's a connection refused error (server not available)
        if (error.contains('Connection refused') ||
            error.contains('Failed host lookup') ||
            error.contains('Connection reset')) {
          _shouldStopReconnecting = true;
          _error =
              'Cannot connect to server. Please ensure the server is running.';
          _isReconnecting = false;
          print('❌ Server unavailable - stopping reconnection attempts');
        } else {
          _error = error;
        }
        print('❌ SignalR error: $error');
        notifyListeners();
      };

      await _signalRService.connect();
      _isConnected = true;
      _error = null;
      _reconnectAttempts = 0;
      _shouldStopReconnecting = false;
      notifyListeners();
    } catch (e) {
      final errorMessage = e.toString();

      // Check if it's a connection refused error
      if (errorMessage.contains('Connection refused') ||
          errorMessage.contains('Failed host lookup') ||
          errorMessage.contains('SocketException')) {
        _shouldStopReconnecting = true;
        _error =
            'Cannot connect to server. Please ensure the server is running.';
        _isReconnecting = false;
        print('❌ Server unavailable - stopping reconnection attempts');
      } else {
        _error = 'Failed to connect to chat server';
      }

      _isConnected = false;
      print('❌ SignalR connection failed: $e');
      notifyListeners();
    }
  }

  Future<void> loadChats() async {
    try {
      _isLoading = true;
      notifyListeners();

      _chats = await _apiService.getMyChats();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(int chatId) async {
    try {
      final messages = await _apiService.getChatMessages(chatId);
      _messagesByChat[chatId] = messages.reversed.toList(); // Newest last
      notifyListeners();

      // Join SignalR group
      if (_isConnected) {
        await _signalRService.joinChat(chatId);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendMessage(int chatId, String content) async {
    try {
      if (_isConnected) {
        // Send via SignalR (real-time)
        await _signalRService.sendMessage(chatId, content);
      } else {
        // Fallback to REST API
        final message = await _apiService.sendMessage(chatId, content);
        _handleMessageReceived(message);
      }
    } catch (e) {
      _error = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  void sendTypingIndicator(int chatId, bool isTyping) {
    if (_isConnected) {
      _signalRService.sendTypingIndicator(chatId, isTyping);
    }
  }

  // Manual retry - resets all reconnection state
  Future<void> retryConnection() async {
    print('🔄 Manual retry requested');
    _reconnectAttempts = 0;
    _shouldStopReconnecting = false;
    _error = null;
    _isReconnecting = true;
    notifyListeners();

    await connectToSignalR();

    // Rejoin all active chats if connection successful
    if (_isConnected) {
      for (var chatId in _messagesByChat.keys) {
        await _signalRService.joinChat(chatId);
      }
    }

    _isReconnecting = false;
    notifyListeners();
  }

  void addMessage(Message message) {
    _handleMessageReceived(message);
  }

  void _handleMessageReceived(Message message) {
    if (!_messagesByChat.containsKey(message.chatId)) {
      _messagesByChat[message.chatId] = [];
    }
    _messagesByChat[message.chatId]!.add(message);

    // Update last message in chat list
    final chatIndex = _chats.indexWhere((c) => c.id == message.chatId);
    if (chatIndex != -1) {
      // Move chat to top
      final chat = _chats.removeAt(chatIndex);
      _chats.insert(0, chat);
    }

    notifyListeners();
  }

  void _handleUserTyping(int userId, bool isTyping) {
    // Update typing status
    _typingUsers[userId] = isTyping;
    notifyListeners();

    // Auto-clear after 3 seconds
    if (isTyping) {
      Future.delayed(const Duration(seconds: 3), () {
        _typingUsers[userId] = false;
        notifyListeners();
      });
    }
  }

  Future<void> leaveChat(int chatId) async {
    if (_isConnected) {
      await _signalRService.leaveChat(chatId);
    }
  }

  @override
  void dispose() {
    _signalRService.dispose();
    _connectivityService.dispose();
    super.dispose();
  }
}
