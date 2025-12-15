import 'user.dart';

enum MessageType { text, image, audio, video, file }

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
