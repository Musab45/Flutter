# 📱 VPChat Flutter Integration Guide

## Complete Guide to Real-Time Messaging in Flutter

This guide will help you integrate VPChat's SignalR real-time messaging into your Flutter application.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup & Dependencies](#setup--dependencies)
3. [Project Structure](#project-structure)
4. [Implementation](#implementation)
5. [Complete Code Examples](#complete-code-examples)
6. [Testing](#testing)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Flutter SDK (3.0+)
- Dart (3.0+)
- VPChat backend running on `http://localhost:5014` (or your server URL)
- Basic understanding of Flutter state management (Provider, Riverpod, or Bloc)

---

## Setup & Dependencies

### 1. Add Dependencies to `pubspec.yaml`

```yaml
name: vpchat_flutter
description: VPChat Flutter Client with Real-Time Messaging

dependencies:
  flutter:
    sdk: flutter
  
  # HTTP & API
  http: ^1.1.0
  dio: ^5.4.0  # Alternative to http, with interceptors
  
  # SignalR
  signalr_netcore: ^1.3.6  # SignalR client for Flutter
  
  # State Management (choose one)
  provider: ^6.1.1  # Recommended for beginners
  # flutter_riverpod: ^2.4.9  # Alternative
  # flutter_bloc: ^8.1.3  # Alternative
  
  # Storage
  shared_preferences: ^2.2.2  # For storing JWT token
  flutter_secure_storage: ^9.0.0  # Secure storage for tokens
  
  # UI Utilities
  intl: ^0.18.1  # Date formatting
  flutter_chat_ui: ^1.6.10  # Optional: Pre-built chat UI
  
  # Permissions (for file upload)
  permission_handler: ^11.1.0
  image_picker: ^1.0.5
  file_picker: ^6.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Update Android Permissions

**`android/app/src/main/AndroidManifest.xml`**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Internet permission for API calls -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application
        android:label="vpchat_flutter"
        android:usesCleartextTraffic="true">  <!-- For local development -->
        <!-- ... -->
    </application>
</manifest>
```

### 4. Update iOS Permissions

**`ios/Runner/Info.plist`**

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>  <!-- For local development only -->
</dict>
```

---

## Project Structure

```
lib/
├── main.dart
├── config/
│   └── api_config.dart          # API endpoints configuration
├── models/
│   ├── user.dart                # User model
│   ├── message.dart             # Message model
│   ├── chat.dart                # Chat model
│   └── auth_response.dart       # Auth response
├── services/
│   ├── api_service.dart         # REST API calls
│   ├── signalr_service.dart     # SignalR connection
│   ├── auth_service.dart        # Authentication
│   └── storage_service.dart     # Local storage
├── providers/
│   ├── auth_provider.dart       # Auth state management
│   ├── chat_provider.dart       # Chat state management
│   └── message_provider.dart    # Messages state
├── screens/
│   ├── login_screen.dart        # Login UI
│   ├── chat_list_screen.dart    # List of chats
│   ├── chat_screen.dart         # Individual chat
│   └── group_settings_screen.dart
└── widgets/
    ├── message_bubble.dart      # Message widget
    ├── typing_indicator.dart    # Typing animation
    └── online_status.dart       # Online indicator
```

---

## Implementation

### 1. Configuration (`lib/config/api_config.dart`)

```dart
class ApiConfig {
  // Change this to your server URL
  static const String baseUrl = 'http://10.0.2.2:5014'; // Android emulator
  // static const String baseUrl = 'http://localhost:5014'; // iOS simulator
  // static const String baseUrl = 'http://192.168.1.100:5014'; // Physical device
  
  // REST API Endpoints
  static const String loginUrl = '$baseUrl/api/Auth/login';
  static const String registerUrl = '$baseUrl/api/Auth/register';
  static const String myChatsUrl = '$baseUrl/api/Chat/my-chats';
  static String getChatMessagesUrl(int chatId) => '$baseUrl/api/Message/chat/$chatId';
  static String sendMessageUrl(int chatId) => '$baseUrl/api/Message/chat/$chatId/send';
  
  // SignalR Hub
  static const String chatHubUrl = '$baseUrl/chatHub';
  
  // Settings
  static const int messagePageSize = 50;
  static const Duration connectionTimeout = Duration(seconds: 30);
}
```

### 2. Models

#### **User Model** (`lib/models/user.dart`)

```dart
class User {
  final int id;
  final String username;
  final bool isOnline;
  final DateTime? lastSeen;

  User({
    required this.id,
    required this.username,
    required this.isOnline,
    this.lastSeen,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null 
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
```

#### **Message Model** (`lib/models/message.dart`)

```dart
enum MessageType {
  text,
  image,
  audio,
  video,
  file,
}

class Message {
  final int id;
  final int chatId;
  final User sender;
  final String? content;
  final MessageType messageType;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final DateTime sentAt;
  final bool isRead;

  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    this.content,
    required this.messageType,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.sentAt,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      chatId: json['chatId'] as int,
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      content: json['content'] as String?,
      messageType: MessageType.values[json['messageType'] as int],
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      sentAt: DateTime.parse(json['sentAt'] as String),
      isRead: json['isRead'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'sender': sender.toJson(),
      'content': content,
      'messageType': messageType.index,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  bool get isMine => false; // Will be set based on current user
}
```

#### **Chat Model** (`lib/models/chat.dart`)

```dart
enum ChatType {
  oneToOne,
  group,
}

class Chat {
  final int id;
  final ChatType type;
  final String? name;
  final DateTime createdAt;
  final bool isActive;
  final List<User> participants;
  final Message? lastMessage;

  Chat({
    required this.id,
    required this.type,
    this.name,
    required this.createdAt,
    required this.isActive,
    required this.participants,
    this.lastMessage,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as int,
      type: ChatType.values[json['type'] as int],
      name: json['name'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
      participants: (json['participants'] as List)
          .map((p) => User.fromJson(p as Map<String, dynamic>))
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
    );
  }

  String getDisplayName(int currentUserId) {
    if (type == ChatType.group) {
      return name ?? 'Unnamed Group';
    }
    
    // For one-to-one, show the other person's name
    final otherUser = participants.firstWhere(
      (user) => user.id != currentUserId,
      orElse: () => participants.first,
    );
    return otherUser.username;
  }
}
```

#### **Auth Response** (`lib/models/auth_response.dart`)

```dart
class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
```

### 3. Services

#### **Storage Service** (`lib/services/storage_service.dart`)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _usernameKey = 'username';

  // Save JWT token (secure)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Get JWT token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Save user info
  Future<void> saveUserInfo(int userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
  }

  // Get user ID
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Get username
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _secureStorage.delete(key: _tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
```

#### **API Service** (`lib/services/api_service.dart`)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_response.dart';
import '../models/chat.dart';
import '../models/message.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();

  // Login
  Future<AuthResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Login failed');
    }
  }

  // Register
  Future<User> register(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Registration failed');
    }
  }

  // Get My Chats
  Future<List<Chat>> getMyChats() async {
    final token = await _storageService.getToken();
    
    final response = await http.get(
      Uri.parse(ApiConfig.myChatsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Chat.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chats');
    }
  }

  // Get Chat Messages
  Future<List<Message>> getChatMessages(int chatId, {int page = 1}) async {
    final token = await _storageService.getToken();
    
    final url = '${ApiConfig.getChatMessagesUrl(chatId)}?page=$page&pageSize=${ApiConfig.messagePageSize}';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  // Send Message via REST (fallback if SignalR fails)
  Future<Message> sendMessage(int chatId, String content, {int messageType = 0}) async {
    final token = await _storageService.getToken();
    
    final response = await http.post(
      Uri.parse(ApiConfig.sendMessageUrl(chatId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'content': content,
        'messageType': messageType,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Message.fromJson(data);
    } else {
      throw Exception('Failed to send message');
    }
  }
}
```

#### **SignalR Service** (`lib/services/signalr_service.dart`)

```dart
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
              logging: (level, message) => print('SignalR: $message'),
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
    _hubConnection!.onclose((error) {
      print('❌ SignalR connection closed: ${error?.toString()}');
      onDisconnected?.call();
    });

    _hubConnection!.onreconnecting((error) {
      print('🔄 SignalR reconnecting...');
    });

    _hubConnection!.onreconnected((connectionId) {
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
  Future<void> sendMessage(int chatId, String content, {int messageType = 0}) async {
    if (!isConnected) {
      throw Exception('Not connected to SignalR');
    }

    try {
      await _hubConnection!.invoke('SendMessage', args: [chatId, content, messageType]);
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
      await _hubConnection!.invoke('SendTypingIndicator', args: [chatId, isTyping]);
    } catch (e) {
      print('❌ Failed to send typing indicator: $e');
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(int messageId, int chatId) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke('MarkMessageAsRead', args: [messageId, chatId]);
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
```

---

## Complete Code Examples

### Main App (`lib/main.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, auth, previous) {
            if (auth.isAuthenticated) {
              previous?.initialize(auth.token!, auth.user!);
            }
            return previous ?? ChatProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'VPChat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            return auth.isAuthenticated
                ? const ChatListScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
```

### Auth Provider (`lib/providers/auth_provider.dart`)

```dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final token = await _storageService.getToken();
    final userId = await _storageService.getUserId();
    final username = await _storageService.getUsername();

    if (token != null && userId != null && username != null) {
      _token = token;
      _user = User(
        id: userId,
        username: username,
        isOnline: true,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final authResponse = await _apiService.login(username, password);
      
      _token = authResponse.token;
      _user = authResponse.user;

      await _storageService.saveToken(authResponse.token);
      await _storageService.saveUserInfo(authResponse.user.id, authResponse.user.username);

      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.register(username, password);
      
      // Auto-login after registration
      final success = await login(username, password);
      
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    _token = null;
    _user = null;
    notifyListeners();
  }
}
```

### Chat Provider (`lib/providers/chat_provider.dart`)

```dart
import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/signalr_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SignalRService _signalRService = SignalRService();

  List<Chat> _chats = [];
  Map<int, List<Message>> _messagesByChat = {};
  Map<int, bool> _typingUsers = {};
  
  bool _isConnected = false;
  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  List<Chat> get chats => _chats;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Message> getMessages(int chatId) => _messagesByChat[chatId] ?? [];
  bool isUserTyping(int chatId) => _typingUsers[chatId] ?? false;

  Future<void> initialize(String token, User user) async {
    _currentUser = user;
    await connectToSignalR();
    await loadChats();
  }

  Future<void> connectToSignalR() async {
    try {
      // Setup event handlers
      _signalRService.onMessageReceived = _handleMessageReceived;
      _signalRService.onUserTyping = _handleUserTyping;
      _signalRService.onConnected = () {
        _isConnected = true;
        notifyListeners();
      };
      _signalRService.onDisconnected = () {
        _isConnected = false;
        notifyListeners();
      };

      await _signalRService.connect();
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to connect: $e';
      _isConnected = false;
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
    super.dispose();
  }
}
```

---

## Testing

### Run the Flutter App

```bash
# Start VPChat backend first
cd VPChat.Server
dotnet run

# In a new terminal, run Flutter app
cd your_flutter_project
flutter run
```

### Test Checklist

1. ✅ **Login** - Test authentication
2. ✅ **View Chats** - Load chat list
3. ✅ **Open Chat** - View messages
4. ✅ **Send Message** - Real-time delivery
5. ✅ **Multiple Devices** - Test sync between devices
6. ✅ **Typing Indicator** - See when others are typing
7. ✅ **Reconnection** - Turn off WiFi, turn back on
8. ✅ **Logout** - Clean disconnect

---

## Best Practices

### 1. **Error Handling**
```dart
try {
  await signalRService.sendMessage(chatId, content);
} catch (e) {
  // Show user-friendly error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to send message')),
  );
  
  // Retry with REST API
  await apiService.sendMessage(chatId, content);
}
```

### 2. **Memory Management**
```dart
@override
void dispose() {
  // Always cleanup SignalR connection
  _signalRService.dispose();
  super.dispose();
}
```

### 3. **Loading States**
```dart
if (isLoading) {
  return Center(child: CircularProgressIndicator());
}
```

### 4. **Offline Mode**
```dart
// Check connection status
if (!chatProvider.isConnected) {
  // Show offline indicator
  // Queue messages for later
  // Use REST API fallback
}
```

---

## Troubleshooting

### Common Issues

#### 1. **"Connection Failed"**
- ✅ Check backend is running on `http://localhost:5014`
- ✅ Update `baseUrl` in `api_config.dart` for emulator/device
- ✅ Enable `usesCleartextTraffic` in Android manifest

#### 2. **"401 Unauthorized"**
- ✅ Verify JWT token is saved correctly
- ✅ Check token is being sent in headers
- ✅ Token might be expired - re-login

#### 3. **Messages Not Appearing**
- ✅ Check `onMessageReceived` callback is set
- ✅ Verify `joinChat()` was called
- ✅ Check console for SignalR events

#### 4. **Android Network Error**
- Use `10.0.2.2` instead of `localhost` for emulator
- For physical device, use computer's IP address

#### 5. **iOS Network Error**
- Add NSAppTransportSecurity to Info.plist
- Use `localhost` for simulator
- Use computer's IP for physical device

---

## Next Steps

1. **UI Polish** - Add animations, themes
2. **Push Notifications** - Firebase Cloud Messaging
3. **File Upload** - Images, videos, documents
4. **Voice Messages** - Audio recording
5. **Video Calls** - WebRTC integration
6. **Offline Support** - Local database with sqflite
7. **Search** - Message and chat search
8. **Reactions** - Emoji reactions on messages

---

## 🎉 You're Ready!

You now have a complete Flutter app with real-time messaging powered by VPChat's SignalR backend!

**Resources:**
- [SignalR Flutter Package](https://pub.dev/packages/signalr_netcore)
- [Provider State Management](https://pub.dev/packages/provider)
- [Flutter Chat UI](https://pub.dev/packages/flutter_chat_ui)

Happy coding! 🚀
