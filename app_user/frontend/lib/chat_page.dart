import 'package:flutter/material.dart';
import 'models/contact.dart';
import 'package:provider/provider.dart';
import 'services/chat_service.dart';
import 'models/message.dart';
import 'widgets/message_bubble.dart';
import 'package:image_picker/image_picker.dart';
import 'utils/responsive.dart';
import 'theme/app_colors.dart';
import 'group_info_page.dart';
import 'contact_profile_page.dart';


class ChatPage extends StatefulWidget {
  final String name;
  final bool isPrivate;
  final Contact? contact;
  final VoidCallback? onCall;

  const ChatPage({
    super.key,
    required this.name,
    this.isPrivate = false,
    this.contact,
    this.onCall,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    // Load messages initially and listen for changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshMessages();
      // Mark incoming messages as read when chat is opened
      final svc = context.read<ChatService>();
      svc.markMessagesAsRead(_contactId);
    });
    context.read<ChatService>().addListener(_refreshMessages);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    // Remove listener if still mounted
    try {
      context.read<ChatService>().removeListener(_refreshMessages);
    } catch (_) {}
    super.dispose();
  }

  Future<void> _refreshMessages() async {
    if (!mounted) return;
    final svc = context.read<ChatService>();
    final msgs = await svc.messagesFor(_contactId);
    if (mounted) {
      setState(() => _messages = msgs);
    }
  }

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
      ? (widget.contact?.phone ?? context.read<ChatService>().privateConversationId)
      : context.read<ChatService>().groupIdForName(widget.name);

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    
    // Clear immediately
    setState(() {
      _ctrl.clear();
    });
    
    final svc = context.read<ChatService>();
    svc.userActive();
    await svc.sendMessage(
      _contactId,
      'me',
      text,
      private: widget.isPrivate,
    );

    _scrollToBottom();
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
    // Still watch for rebuilds (e.g. contact changes), but messages come from cached _messages
    context.watch<ChatService>();
    final cc = AppColors.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.arrow_back, color: cc.text), onPressed: () => Navigator.pop(context)), 
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            if (!widget.isPrivate) {
              // Group chat — open group info page
              Navigator.push(context, MaterialPageRoute(builder: (_) => GroupInfoPage(groupName: widget.name)));
            } else if (widget.contact != null) {
              // Individual chat — open contact profile page
              Navigator.push(context, MaterialPageRoute(builder: (_) => ContactProfilePage(contact: widget.contact!)));
            }
          },
          child: Row(
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.isPrivate
                          ? [const Color(0xFF5B7FFF), const Color(0xFF4A6FE8)]
                          : [const Color(0xFF5B7FFF), const Color(0xFF4A6FE8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(widget.isPrivate ? Icons.person : Icons.group, color: Colors.black87),
                  ),
                ),
                // Online indicator dot
                if (widget.contact != null && context.watch<ChatService>().isOnline(widget.contact!.id))
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    color: cc.text,
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 20),
                  ),
                ),
                if (widget.contact != null && context.watch<ChatService>().isTyping(widget.contact!.id))
                  const Text('typing...', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontStyle: FontStyle.italic)),
              ],
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
        ),), // GestureDetector + Row
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cc.bg, cc.card, cc.bg],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
              children: [
                // Main chat area
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg.from == 'me';
                          return MessageBubble(message: msg, isMe: isMe);
                        },
                      ),
                    ),
                    Container(
                      color: cc.card,
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
                                  color: cc.card,
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
                                  color: cc.card,
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
                                color: cc.card,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextField(
                                controller: _ctrl,
                                cursorColor: cc.text,
                                style: TextStyle(
                                  color: cc.text,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  filled: false,
                                  hintText: 'Type a message',
                                  hintStyle: TextStyle(
                                    color: cc.textMuted,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                onSubmitted: (_) => _send(),
                                onChanged: (text) {
                                  if (widget.contact != null) {
                                    final svc = context.read<ChatService>();
                                    if (text.isNotEmpty) {
                                      svc.sendTypingIndicator(widget.contact!.id);
                                    } else {
                                      svc.sendStopTypingIndicator(widget.contact!.id);
                                    }
                                  }
                                },
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
                                      color: Colors.black.withValues(alpha: 0.18),
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
                  right: Responsive.horizontal(context, 16),
                  bottom: Responsive.vertical(context, 90),
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
            ),
      ),
    );
  }
}
