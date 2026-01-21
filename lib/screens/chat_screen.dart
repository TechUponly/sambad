import 'package:flutter/material.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_bar.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  void _handleSend(String text) {
    final now = DateTime.now();
    final newMessage = ChatMessage(
      id: now.microsecondsSinceEpoch.toString(),
      text: text,
      isMe: true,
      timestamp: now,
    );
    setState(() {
      _messages.add(newMessage);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
    // Network/WebSocket send is async and does NOT block UI
    // sendMessageToServer(newMessage); // Implement as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return MessageBubble(
                  key: ValueKey(msg.id),
                  text: msg.text,
                  isMe: msg.isMe,
                );
              },
            ),
          ),
          ChatInputBar(onSend: _handleSend),
        ],
      ),
    );
  }
}
