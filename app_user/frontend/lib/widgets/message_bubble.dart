import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  String _formatTime(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    final bg = isMe
        ? const LinearGradient(
            colors: [Color(0xFF3A3DFF), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF232B3E), Color(0xFF181A20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final textColor = Colors.white;

    return AnimatedAlign(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: bg,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: radius.topLeft,
                    topRight: radius.topRight,
                    bottomLeft: radius.bottomLeft,
                  )
                : BorderRadius.only(
                    topLeft: radius.topLeft,
                    topRight: radius.topRight,
                    bottomRight: radius.bottomRight,
                  ),
            boxShadow: [
              BoxShadow(
                color: isMe ? const Color(0xFF00FFC2).withOpacity(0.18) : Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.private)
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Icon(Icons.lock, size: 16, color: isMe ? Colors.black54 : Colors.white70),
                    ),
                  Flexible(
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        letterSpacing: 0.1,
                        shadows: isMe
                            ? [const Shadow(color: Colors.white24, blurRadius: 2)]
                            : [const Shadow(color: Colors.black26, blurRadius: 2)],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isMe ? Colors.black54 : Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
