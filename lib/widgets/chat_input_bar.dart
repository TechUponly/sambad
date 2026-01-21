import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  const ChatInputBar({required this.onSend, super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _handleSend,
              splashRadius: 24,
            ),
          ],
        ),
      ),
    );
  }
}
