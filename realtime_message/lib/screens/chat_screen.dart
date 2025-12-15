import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/chat.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../services/api_service.dart';
import '../services/file_picker_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _filePickerService = FilePickerService();
  final _apiService = ApiService();
  late ChatProvider _chatProvider;
  bool _isSendingMessage = false;
  bool _isUploadingFile = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _chatProvider.loadMessages(widget.chat.id);

    // Listen to scroll position to show/hide scroll-to-bottom button
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 200;
      if (shouldShow != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = shouldShow;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Widget _buildWelcomeMessage(BuildContext context, AuthProvider authProvider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF40444B),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF5865F2), width: 3),
              ),
              child: Icon(
                widget.chat.type == ChatType.group ? Icons.tag : Icons.person,
                color: const Color(0xFF5865F2),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            // Welcome text
            Text(
              'Welcome to #${widget.chat.getDisplayName(authProvider.user?.id ?? 0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              widget.chat.type == ChatType.group
                  ? 'This is the beginning of the #${widget.chat.getDisplayName(authProvider.user?.id ?? 0)} channel.'
                  : 'This is the beginning of your direct message history with ${widget.chat.getDisplayName(authProvider.user?.id ?? 0)}.',
              style: const TextStyle(
                color: Color(0xFF96989D),
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.chat.type == ChatType.group) ...[
              const SizedBox(height: 8),
              Text(
                '${widget.chat.participants.length} members',
                style: const TextStyle(color: Color(0xFF96989D), fontSize: 13),
              ),
            ],
            const SizedBox(height: 32),
            // CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF40444B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF202225)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF5865F2),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Send the first message!',
                    style: TextStyle(
                      color: Color(0xFFDCDDDE),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFF36393F),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leading: MediaQuery.of(context).size.width < 768
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFB9BBBE)),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back to chats',
                  padding: const EdgeInsets.all(12),
                )
              : null,
          automaticallyImplyLeading: MediaQuery.of(context).size.width < 768,
          titleSpacing: 16,
          title: Row(
            children: [
              // Channel icon with better visual styling
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF40444B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  widget.chat.type == ChatType.group ? Icons.tag : Icons.person,
                  color: const Color(0xFF96989D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Chat name and description/status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.chat.getDisplayName(authProvider.user?.id ?? 0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.chat.type == ChatType.group)
                      Text(
                        '${widget.chat.participants.length} members',
                        style: const TextStyle(
                          color: Color(0xFF96989D),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    else if (chatProvider.isUserTyping(widget.chat.id))
                      const Text(
                        'typing...',
                        style: TextStyle(
                          color: Color(0xFF5865F2),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    else
                      const Text(
                        'Online',
                        style: TextStyle(
                          color: Color(0xFF43B581),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Call button
            IconButton(
              icon: const Icon(Icons.call_outlined, color: Color(0xFFB9BBBE)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voice call - Coming soon!')),
                );
              },
              tooltip: 'Voice call',
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            // Video button
            IconButton(
              icon: const Icon(
                Icons.videocam_outlined,
                color: Color(0xFFB9BBBE),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video call - Coming soon!')),
                );
              },
              tooltip: 'Video call',
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            // Search button
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFFB9BBBE)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search - Coming soon!')),
                );
              },
              tooltip: 'Search',
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            // More options button
            IconButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFFB9BBBE)),
              onPressed: () {
                _showChatOptions(context);
              },
              tooltip: 'More options',
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Column(
        children: [
          // Divider
          Container(height: 1, color: const Color(0xFF202225)),

          // Offline/Reconnecting Banner
          if (!chatProvider.isOnline ||
              chatProvider.isReconnecting ||
              chatProvider.error != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: chatProvider.isReconnecting
                    ? const Color(0xFFFEE75C).withOpacity(0.2)
                    : const Color(0xFFED4245).withOpacity(0.2),
                border: Border(
                  bottom: BorderSide(
                    color: chatProvider.isReconnecting
                        ? const Color(0xFFFEE75C)
                        : const Color(0xFFED4245),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    chatProvider.isReconnecting ? Icons.sync : Icons.cloud_off,
                    color: chatProvider.isReconnecting
                        ? const Color(0xFFFEE75C)
                        : const Color(0xFFED4245),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatProvider.error ??
                          (chatProvider.isReconnecting
                              ? 'Reconnecting to chat server${chatProvider.reconnectAttempts > 0 ? " (${chatProvider.reconnectAttempts}/5)" : ""}...'
                              : 'No internet connection - Messages will be sent when online'),
                      style: TextStyle(
                        color: chatProvider.isReconnecting
                            ? const Color(0xFFFEE75C)
                            : const Color(0xFFED4245),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!chatProvider.isReconnecting && !chatProvider.isConnected)
                    TextButton(
                      onPressed: () async {
                        await chatProvider.retryConnection();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        backgroundColor: const Color(0xFF5865F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Messages list with FAB
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Color(0xFF36393F)),
                  child: chatProvider.getMessages(widget.chat.id).isEmpty
                      ? _buildWelcomeMessage(context, authProvider)
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true, // Newest messages at bottom
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          itemCount: chatProvider
                              .getMessages(widget.chat.id)
                              .length,
                          itemBuilder: (context, index) {
                            final messages = chatProvider.getMessages(
                              widget.chat.id,
                            );
                            final message =
                                messages[messages.length - 1 - index];
                            final isMine =
                                message.sender.id == authProvider.user?.id;

                            // Check if we should show avatar (first message from user or after 5+ minutes)
                            bool showAvatar = true;
                            bool showTimestamp = true;

                            if (index < messages.length - 1) {
                              final nextMessage =
                                  messages[messages.length - 2 - index];
                              if (nextMessage.sender.id == message.sender.id) {
                                final timeDiff = message.sentAt.difference(
                                  nextMessage.sentAt,
                                );
                                if (timeDiff.inMinutes < 5) {
                                  showAvatar = false;
                                  showTimestamp = false;
                                }
                              }
                            }

                            return MessageBubble(
                              message: message,
                              isMine: isMine,
                              showAvatar: showAvatar,
                              showTimestamp: showTimestamp,
                            );
                          },
                        ),
                ),
                // Scroll to bottom FAB
                if (_showScrollToBottom)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(28),
                      child: InkWell(
                        onTap: () {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5865F2),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Typing indicator (below messages)
          if (chatProvider.isUserTyping(widget.chat.id))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const SizedBox(width: 56),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF40444B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF5865F2).withOpacity(0.6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'typing...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Message input area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: const BoxDecoration(color: Color(0xFF36393F)),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Input container
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF40444B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _messageController.text.isNotEmpty
                            ? const Color(0xFF5865F2).withOpacity(0.3)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Attachment button
                            Container(
                              margin: const EdgeInsets.only(left: 4, bottom: 4),
                              child: IconButton(
                                icon: _isUploadingFile
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFFB9BBBE),
                                              ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add_circle,
                                        color: Color(0xFF5865F2),
                                      ),
                                onPressed: _isUploadingFile
                                    ? null
                                    : _showFilePickerOptions,
                                tooltip: _isUploadingFile
                                    ? 'Uploading file...'
                                    : 'Attach file',
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 44,
                                ),
                              ),
                            ),

                            // Message input
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 120,
                                  minHeight: 44,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: TextField(
                                  controller: _messageController,
                                  maxLines: null,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: const TextStyle(
                                    color: Color(0xFFDCDDDE),
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Message #${widget.chat.getDisplayName(authProvider.user?.id ?? 0)}',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF72767D),
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {}); // Update send button state
                                    _chatProvider.sendTypingIndicator(
                                      widget.chat.id,
                                      value.trim().isNotEmpty,
                                    );
                                  },
                                  onSubmitted: (value) {
                                    if (value.trim().isNotEmpty &&
                                        !_isSendingMessage) {
                                      _sendMessage();
                                    }
                                  },
                                ),
                              ),
                            ),

                            // Emoji button
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.emoji_emotions,
                                  color: Color(0xFFB9BBBE),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Emoji picker - Coming soon!',
                                      ),
                                    ),
                                  );
                                },
                                tooltip: 'Emoji',
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 44,
                                ),
                              ),
                            ),

                            // Send button (only show when there's text)
                            if (_messageController.text.trim().isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(
                                  right: 8,
                                  bottom: 4,
                                ),
                                child: IconButton(
                                  icon: _isSendingMessage
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF5865F2),
                                                ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send_rounded,
                                          color: Color(0xFF5865F2),
                                        ),
                                  onPressed: _isSendingMessage
                                      ? null
                                      : _sendMessage,
                                  tooltip: _isSendingMessage
                                      ? 'Sending...'
                                      : 'Send message',
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(
                                    minWidth: 44,
                                    minHeight: 44,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Character count for long messages
                        if (_messageController.text.length > 1800)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 12,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${_messageController.text.length}/2000',
                                  style: TextStyle(
                                    color: _messageController.text.length > 2000
                                        ? const Color(0xFFED4245)
                                        : const Color(0xFF96989D),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2F3136),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF4E5058),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Send a file',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Options
              _buildFileOption(
                icon: Icons.camera_alt,
                iconColor: const Color(0xFFED4245),
                title: 'Take Photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              _buildFileOption(
                icon: Icons.photo_library,
                iconColor: const Color(0xFF5865F2),
                title: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              _buildFileOption(
                icon: Icons.videocam,
                iconColor: const Color(0xFFFEE75C),
                title: 'Choose Video',
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromGallery();
                },
              ),
              _buildFileOption(
                icon: Icons.insert_drive_file,
                iconColor: const Color(0xFF57F287),
                title: 'Choose File',
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFDCDDDE),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final file = await _filePickerService.pickImageFromCamera();
      if (file != null) {
        await _uploadFile(file);
      }
    } catch (e) {
      _showPermissionErrorSnackBar(e.toString());
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final file = await _filePickerService.pickImageFromGallery();
      if (file != null) {
        await _uploadFile(file);
      }
    } catch (e) {
      _showPermissionErrorSnackBar(e.toString());
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final file = await _filePickerService.pickVideoFromGallery();
      if (file != null) {
        await _uploadFile(file);
      }
    } catch (e) {
      _showPermissionErrorSnackBar(e.toString());
    }
  }

  Future<void> _pickFile() async {
    try {
      final file = await _filePickerService.pickFile();
      if (file != null) {
        await _uploadFile(file);
      }
    } catch (e) {
      _showPermissionErrorSnackBar(e.toString());
    }
  }

  Future<void> _uploadFile(File file) async {
    if (_isUploadingFile) return; // Prevent multiple uploads

    setState(() => _isUploadingFile = true);

    try {
      await _apiService.uploadFile(widget.chat.id, file);

      // Don't manually add the message - SignalR will broadcast it automatically

      // Scroll to bottom (SignalR will trigger UI update when message arrives)
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to upload file: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingFile = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPermissionErrorSnackBar(String errorMessage) {
    final isPermissionError =
        errorMessage.contains('permission') ||
        errorMessage.contains('denied') ||
        errorMessage.contains('Permanently denied');

    final isSimulatorError =
        errorMessage.contains('Simulator') ||
        errorMessage.contains('simulator');

    if (isSimulatorError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Camera/gallery access is not available on Simulator. Please test file/camera features on a physical device.',
          ),
          duration: Duration(seconds: 6),
        ),
      );
    } else if (isPermissionError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Gallery access denied. Please grant permission in app settings to select photos/videos.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () async {
              // Open app settings
              await openAppSettings();
            },
          ),
          duration: const Duration(seconds: 8),
        ),
      );
    } else {
      _showErrorSnackBar(errorMessage);
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isNotEmpty && !_isSendingMessage) {
      setState(() => _isSendingMessage = true);

      try {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        await chatProvider.sendMessage(widget.chat.id, content);
        _messageController.clear();
        chatProvider.sendTypingIndicator(widget.chat.id, false);

        // Scroll to bottom after sending
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSendingMessage = false);
        }
      }
    }
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2F3136),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF4E5058),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    widget.chat.getDisplayName(
                      Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).user?.id ??
                          0,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Options
            _buildChatOption(
              icon: Icons.search,
              iconColor: const Color(0xFF5865F2),
              title: 'Search in chat',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search - Coming soon!')),
                );
              },
            ),
            _buildChatOption(
              icon: Icons.notifications_off,
              iconColor: const Color(0xFFFEE75C),
              title: 'Mute notifications',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mute notifications - Coming soon!'),
                  ),
                );
              },
            ),
            if (widget.chat.type == ChatType.group)
              _buildChatOption(
                icon: Icons.group,
                iconColor: const Color(0xFF57F287),
                title: 'View members (${widget.chat.participants.length})',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View members - Coming soon!'),
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildChatOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFDCDDDE),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
