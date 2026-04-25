import 'package:flutter/material.dart';
import 'theme/app_colors.dart';

class AIBotChatPage extends StatefulWidget {
  const AIBotChatPage({super.key});

  @override
  State<AIBotChatPage> createState() => _AIBotChatPageState();
}

class _AIBotChatPageState extends State<AIBotChatPage> {
  // REVERT: simple single-thread chat, no groups
  final List<_BotMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_BotMessage(text, true));
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(_BotMessage(_generateBotReply(text), false));
      });
      _scrollToBottom();
    });
    _scrollToBottom();
  }

  String _generateBotReply(String message) {
    // ...existing code (help / hello / reverse reply)...
    if (message.toLowerCase().contains('help')) return 'How can I assist you today?';
    if (message.toLowerCase().contains('hello') || message.toLowerCase().contains('hi')) return 'Hello! I am your AI bot.';
    return 'AI: ${message.split('').reversed.join()}';
  }

  void _scrollToBottom() {
    // ...existing code...
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
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.card,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              'Samvad AI',
              style: TextStyle(
                color: c.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: c.bg,
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.bg, c.card],
                ),
              ),
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.smart_toy, size: 80, color: c.textHint),
                          const SizedBox(height: 16),
                          Text('Chat with Samvad AI', style: TextStyle(color: c.text, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Ask anything...', style: TextStyle(color: c.textMuted, fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isMe = m.isUser;
                  return Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMe)
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryBlue,
                          child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
                        ),
                      if (!isMe) const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.primaryBlue : c.card,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isMe ? 18 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            m.text,
                            style: TextStyle(
                              color: isMe ? Colors.white : c.text,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      if (isMe) const SizedBox(width: 8),
                      if (isMe)
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryBlue,
                          child: const Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: c.card,
              border: Border(top: BorderSide(color: c.textHint.withValues(alpha: 0.2))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: c.text),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: c.textMuted),
                        filled: true,
                        fillColor: c.text.withValues(alpha: 0.08),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _send,
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
}

class _BotMessage {
  final String text;
  final bool isUser;
  _BotMessage(this.text, this.isUser);
}
