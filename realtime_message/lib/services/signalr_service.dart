import 'package:signalr_netcore/signalr_client.dart';
import '../config/api_config.dart';
import '../models/message.dart';
import 'storage_service.dart';

class SignalRService {
  HubConnection? _hubConnection;
  final StorageService _storageService = StorageService();

  // Connection state
  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  // Event callbacks
  Function(Message)? onMessageReceived;
  Function(int userId, int chatId)? onUserJoined;
  Function(int userId, int chatId)? onUserLeft;
  Function(int userId, bool isTyping)? onUserTyping;
  Function(int messageId, int readBy)? onMessageRead;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String error)? onError;

  Future<void> connect() async {
    if (_hubConnection != null && isConnected) {
      print('Already connected to SignalR');
      return;
    }

    try {
      final token = await _storageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      // Create hub connection
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            ApiConfig.chatHubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              // logging removed - not supported in this version
            ),
          )
          .withAutomaticReconnect(
            retryDelays: [0, 2000, 5000, 10000, 30000], // Retry delays in ms
          )
          .build();

      // Setup event handlers
      _setupEventHandlers();

      // Connect
      await _hubConnection!.start();
      print('✅ Connected to SignalR Hub');
      onConnected?.call();
    } catch (e) {
      print('❌ SignalR connection failed: $e');
      onError?.call(e.toString());
      rethrow;
    }
  }

  void _setupEventHandlers() {
    // Receive Message
    _hubConnection!.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final messageData = arguments[0] as Map<String, dynamic>;
          final message = Message.fromJson(messageData);
          onMessageReceived?.call(message);
        } catch (e) {
          print('Error parsing message: $e');
        }
      }
    });

    // User Joined
    _hubConnection!.on('UserJoined', (arguments) {
      if (arguments != null && arguments.length >= 2) {
        final data = arguments[0] as Map<String, dynamic>;
        final userId = data['userId'] as int;
        final chatId = data['chatId'] as int;
        onUserJoined?.call(userId, chatId);
      }
    });

    // User Left
    _hubConnection!.on('UserLeft', (arguments) {
      if (arguments != null && arguments.length >= 2) {
        final data = arguments[0] as Map<String, dynamic>;
        final userId = data['userId'] as int;
        final chatId = data['chatId'] as int;
        onUserLeft?.call(userId, chatId);
      }
    });

    // User Typing
    _hubConnection!.on('UserTyping', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        final userId = data['userId'] as int;
        final isTyping = data['isTyping'] as bool;
        onUserTyping?.call(userId, isTyping);
      }
    });

    // Message Read
    _hubConnection!.on('MessageRead', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        final messageId = data['messageId'] as int;
        final readBy = data['readBy'] as int;
        onMessageRead?.call(messageId, readBy);
      }
    });

    // Connection events
    _hubConnection!.onclose(({Exception? error}) {
      print('❌ SignalR connection closed: ${error?.toString()}');
      onDisconnected?.call();
    });

    _hubConnection!.onreconnecting(({Exception? error}) {
      print('🔄 SignalR reconnecting...');
    });

    _hubConnection!.onreconnected(({String? connectionId}) {
      print('✅ SignalR reconnected');
      onConnected?.call();
    });
  }

  // Join a chat room
  Future<void> joinChat(int chatId) async {
    if (!isConnected) {
      throw Exception('Not connected to SignalR');
    }

    try {
      await _hubConnection!.invoke('JoinChat', args: [chatId]);
      print('✅ Joined chat $chatId');
    } catch (e) {
      print('❌ Failed to join chat: $e');
      rethrow;
    }
  }

  // Leave a chat room
  Future<void> leaveChat(int chatId) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke('LeaveChat', args: [chatId]);
      print('✅ Left chat $chatId');
    } catch (e) {
      print('❌ Failed to leave chat: $e');
    }
  }

  // Send message
  Future<void> sendMessage(
    int chatId,
    String content, {
    int messageType = 0,
  }) async {
    if (!isConnected) {
      throw Exception('Not connected to SignalR');
    }

    try {
      await _hubConnection!.invoke(
        'SendMessage',
        args: [chatId, content, messageType],
      );
      print('✅ Message sent');
    } catch (e) {
      print('❌ Failed to send message: $e');
      rethrow;
    }
  }

  // Send typing indicator
  Future<void> sendTypingIndicator(int chatId, bool isTyping) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke(
        'SendTypingIndicator',
        args: [chatId, isTyping],
      );
    } catch (e) {
      print('❌ Failed to send typing indicator: $e');
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(int messageId, int chatId) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke(
        'MarkMessageAsRead',
        args: [messageId, chatId],
      );
    } catch (e) {
      print('❌ Failed to mark message as read: $e');
    }
  }

  // Disconnect
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _hubConnection = null;
      print('❌ Disconnected from SignalR');
      onDisconnected?.call();
    }
  }

  // Dispose (cleanup)
  void dispose() {
    disconnect();
  }
}
