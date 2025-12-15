import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import '../models/auth_response.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();

  // Timeout duration for all requests
  static const Duration _requestTimeout = Duration(seconds: 15);

  // Helper method to handle common network errors
  Exception _handleError(dynamic error, String operation) {
    if (error is SocketException) {
      return Exception(
        'No internet connection. Please check your network and try again.',
      );
    } else if (error is TimeoutException) {
      return Exception(
        'Connection timeout. The server is not responding. Please try again later.',
      );
    } else if (error is http.ClientException) {
      return Exception(
        'Network error. Please check your connection and try again.',
      );
    } else if (error is FormatException) {
      return Exception('Invalid server response. Please try again later.');
    } else if (error.toString().contains('Connection refused')) {
      return Exception(
        'Cannot connect to server. Please ensure the server is running.',
      );
    } else if (error.toString().contains('Failed host lookup')) {
      return Exception(
        'Cannot reach server. Please check your internet connection.',
      );
    } else {
      return Exception('$operation failed: ${error.toString()}');
    }
  }

  // Login
  Future<AuthResponse> login(String username, String password) async {
    print('🔐 Attempting login for user: $username');

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(_requestTimeout);

      print('📡 Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }
        try {
          final data = jsonDecode(response.body);
          print('✅ Login successful');
          return AuthResponse.fromJson(data);
        } catch (e) {
          print('❌ JSON decode error: $e');
          throw Exception('Invalid server response. Please try again.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid username or password');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        String errorMessage = 'Login failed';
        if (response.body.isNotEmpty) {
          try {
            final error = jsonDecode(response.body);
            errorMessage = error['message'] ?? errorMessage;
          } catch (e) {
            errorMessage = response.body;
          }
        }
        print('❌ Login failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw Exception('Connection timeout. The server is not responding.');
    } on http.ClientException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw _handleError(e, 'Login');
    }
  }

  // Register
  Future<User> register(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }
      try {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } catch (e) {
        throw Exception('Invalid JSON response: ${response.body}');
      }
    } else {
      // Handle error responses
      String errorMessage =
          'Registration failed (Status: ${response.statusCode})';
      if (response.body.isNotEmpty) {
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? errorMessage;
        } catch (e) {
          // If error response is not JSON, use the raw body
          errorMessage = response.body;
        }
      }
      throw Exception(errorMessage);
    }
  }

  // Get My Chats
  Future<List<Chat>> getMyChats() async {
    try {
      final token = await _storageService.getToken();

      final response = await http
          .get(
            Uri.parse(ApiConfig.myChatsUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }
        try {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((json) => Chat.fromJson(json)).toList();
        } catch (e) {
          throw Exception('Invalid server response');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        String errorMessage = 'Failed to load chats';
        if (response.body.isNotEmpty) {
          try {
            final error = jsonDecode(response.body);
            errorMessage = error['message'] ?? errorMessage;
          } catch (e) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Connection timeout. Please try again.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw _handleError(e, 'Load chats');
    }
  }

  // Get Chat Messages
  Future<List<Message>> getChatMessages(int chatId, {int page = 1}) async {
    final token = await _storageService.getToken();

    final url =
        '${ApiConfig.getChatMessagesUrl(chatId)}?page=$page&pageSize=${ApiConfig.messagePageSize}';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return [];
      }
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } catch (e) {
        throw Exception('Invalid JSON response for messages: ${response.body}');
      }
    } else {
      String errorMessage =
          'Failed to load messages (Status: ${response.statusCode})';
      if (response.body.isNotEmpty) {
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = response.body;
        }
      }
      throw Exception(errorMessage);
    }
  }

  // Send Message via REST (fallback if SignalR fails)
  Future<Message> sendMessage(
    int chatId,
    String content, {
    int messageType = 0,
  }) async {
    final token = await _storageService.getToken();

    final response = await http.post(
      Uri.parse(ApiConfig.sendMessageUrl(chatId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content, 'messageType': messageType}),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }
      try {
        final data = jsonDecode(response.body);
        return Message.fromJson(data);
      } catch (e) {
        throw Exception('Invalid JSON response for message: ${response.body}');
      }
    } else {
      String errorMessage =
          'Failed to send message (Status: ${response.statusCode})';
      if (response.body.isNotEmpty) {
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = response.body;
        }
      }
      throw Exception(errorMessage);
    }
  }

  // Upload File
  Future<Message> uploadFile(int chatId, File file, {String? content}) async {
    final token = await _storageService.getToken();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadFileUrl(chatId)),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add file
      final fileName = file.path.split('/').last;
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: fileName,
        contentType: _getContentType(fileName),
      );

      request.files.add(multipartFile);

      // Determine message type based on file extension
      final messageType = _getMessageType(fileName);
      request.fields['messageType'] = messageType.toString();

      // Add optional content
      if (content != null && content.isNotEmpty) {
        request.fields['content'] = content;
      }

      print(
        '📤 Uploading file: $fileName (${fileLength} bytes) - MessageType: $messageType',
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Upload response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }
        try {
          final data = jsonDecode(response.body);
          print('✅ File upload successful');
          return Message.fromJson(data);
        } catch (e) {
          print('❌ JSON decode error: $e');
          throw Exception('Invalid JSON response: ${response.body}');
        }
      } else {
        String errorMessage =
            'File upload failed (Status: ${response.statusCode})';
        if (response.body.isNotEmpty) {
          try {
            final error = jsonDecode(response.body);
            errorMessage = error['message'] ?? errorMessage;
          } catch (e) {
            errorMessage = response.body;
          }
        }
        print('❌ File upload failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ File upload error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Upload timeout - file may be too large');
      }
      rethrow;
    }
  }

  // Helper method to determine content type
  MediaType _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'avi':
        return MediaType('video', 'avi');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'wav':
        return MediaType('audio', 'wav');
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        );
      case 'txt':
        return MediaType('text', 'plain');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  // Helper method to determine message type
  int _getMessageType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    // Check for image files
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return 1; // MessageType.image
    }

    // Check for video files
    if (['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv'].contains(extension)) {
      return 3; // MessageType.video
    }

    // Check for audio files
    if (['mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a'].contains(extension)) {
      return 2; // MessageType.audio
    }

    // Default to file type for all other files
    return 4; // MessageType.file
  }
}
