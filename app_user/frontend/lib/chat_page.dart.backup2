import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/chat_service.dart';
import 'models/message.dart';
import 'widgets/message_bubble.dart';
import 'package:image_picker/image_picker.dart';

// NEW: Home page with groups
class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatGroupCreateResult {
  final String name;
  final List<String> memberIds;

  _ChatGroupCreateResult({required this.name, required this.memberIds});
}

class _ChatHomePageState extends State<ChatHomePage> {
  // Group creation dialog logic is available for integration when needed.

  @override
  Widget build(BuildContext context) {
    // ...existing code for your main chat home page UI...
    return Scaffold(
      // Example placeholder
      appBar: AppBar(title: const Text('Chats')),
      body: Center(child: Text('Chat Home Page')),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String name;
  final bool isPrivate;
  final VoidCallback? onCall;

  const ChatPage({
    super.key,
    required this.name,
    this.isPrivate = false,
    this.onCall,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Future<void> _pickAndSendImage({bool fromCamera = false}) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? image = await imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (!mounted) return;
      if (image != null) {
        final svc = context.read<ChatService>();
        await svc.sendMessage(
          _contactId,
          'me',
          '[Image] ${image.path}',
          private: widget.isPrivate,
        );
        _scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image sharing failed.')));
    }
  }

  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  String get _contactId => widget.isPrivate
      ? context.read<ChatService>().privateConversationId
      : context.read<ChatService>().groupIdForName(widget.name);

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final svc = context.read<ChatService>();
    svc.userActive();
    await svc.sendMessage(
      _contactId,
      'me',
      text,
      private: widget.isPrivate, // was: private: false
    );
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 700), () async {
      if (!mounted) return;
      final reply = _generateBotReply(text);
      svc.userActive();
      await svc.sendMessage(
        _contactId,
        'bot',
        reply,
        private: widget.isPrivate, // was: private: false
      );
      _scrollToBottom();
    });
    _scrollToBottom();
  }

  String _generateBotReply(String message) {
    if (message.toLowerCase().contains('how') && message.contains('?')) {
      return 'I am doing well — thanks for asking!';
    }
    if (message.toLowerCase().contains('hi') ||
        message.toLowerCase().contains('hello')) {
      return 'Hi there! How can I help?';
    }
    return 'AI reply: ${message.split('').reversed.join()}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<ChatService>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)), 
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B7FFF), Color(0xFF4A6FE8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, color: Colors.black87),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (widget.isPrivate && widget.onCall != null) ...[
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.call, color: Colors.greenAccent),
                tooltip: 'Call',
                onPressed: widget.onCall,
              ),
            ],
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF181A20), Color(0xFF232B3E), Color(0xFF23272F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<Message>>(
          future: svc.messagesFor(_contactId),
          builder: (context, snapshot) {
            final messages = snapshot.data ?? [];
            return Stack(
              children: [
                // Main chat area
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.from == 'me';
                          return MessageBubble(message: msg, isMe: isMe);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Gallery button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                await _pickAndSendImage(fromCamera: false);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.photo,
                                  color: Color(0xFF5B7FFF),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Camera button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                await _pickAndSendImage(fromCamera: true);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF4A6FE8),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Message input
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF23272F),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextField(
                                controller: _ctrl,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Type a message',
                                  hintStyle: const TextStyle(
                                    color: Colors.white54,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                onSubmitted: (_) => _send(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Send button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: _send,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5B7FFF),
                                      Color(0xFF4A6FE8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.18),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.black,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Arrow button to scroll to bottom
                Positioned(
                  right: 16,
                  bottom: 90,
                  child: AnimatedBuilder(
                    animation: _scroll,
                    builder: (context, child) {
                      final showArrow =
                          _scroll.hasClients &&
                          _scroll.offset <
                              _scroll.position.maxScrollExtent - 100;
                      return showArrow
                          ? FloatingActionButton(
                              heroTag: 'chat_scroll_fab',
                              mini: true,
                              backgroundColor: Colors.deepPurple,
                              onPressed: _scrollToBottom,
                              tooltip: 'Jump to latest',
                              elevation: 2,
                              child: const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
