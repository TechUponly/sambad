import 'package:flutter/material.dart';
import '../models/message.dart';
import '../utils/responsive.dart';
import '../theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  String _formatTime(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }


  Widget _buildStatusIcon() {
    if (!isMe) return const SizedBox.shrink();
    switch (message.status) {
      case 'sent':
        return const Icon(Icons.check, size: 14, color: Colors.white70);
      case 'delivered':
        return const Icon(Icons.done_all, size: 14, color: Colors.white70);
      case 'read':
        return const Icon(Icons.done_all, size: 14, color: Color(0xFF00C853));
      default:
        return const Icon(Icons.schedule, size: 14, color: Colors.white54);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final radius = BorderRadius.circular(20);
    final bg = isMe
        ? const LinearGradient(
            colors: [Color(0xFF3A3DFF), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [c.card, c.bg],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final textColor = isMe ? Colors.white : c.text;

    final maxBubbleWidth = Responsive.widthPercent(context, 0.75);
    return AnimatedAlign(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Container(
          margin: Responsive.paddingSymmetric(context, v: 8, h: 8),
          padding: Responsive.paddingSymmetric(context, h: 16, v: 14),
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
                color: isMe ? const Color(0xFF00FFC2).withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.18),
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
                      child: Icon(Icons.lock, size: 16, color: isMe ? Colors.black54 : c.textMuted),
                    ),
                  Flexible(
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: Responsive.fontSize(context, 16),
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
                      color: isMe ? Colors.white60 : c.textMuted,
                      fontSize: Responsive.fontSize(context, 11),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
