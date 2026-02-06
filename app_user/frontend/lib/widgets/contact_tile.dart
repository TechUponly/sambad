import 'package:flutter/material.dart';
import '../models/contact.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final int unreadCount;

  const ContactTile({super.key, required this.contact, this.onTap, this.unreadCount = 0});

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<ChatService>(context, listen: false);
    final isBlocked = svc.blockedContacts.contains(contact.id);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        child: Text(
          contact.name.isNotEmpty ? contact.name.substring(0, 1) : '?',
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      title: Text(contact.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(contact.phone, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
              child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF23272F),
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF23272F), Color(0xFF18181B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: Colors.redAccent.withOpacity(0.18), width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Delete Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Montserrat')),
                          const SizedBox(height: 18),
                          Text('Are you sure you want to delete ${contact.name}?', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                style: TextButton.styleFrom(foregroundColor: Colors.white70, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  elevation: 6,
                                  shadowColor: Colors.redAccent.withOpacity(0.18),
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                if (confirm == true) {
                  if (!context.mounted) return;
                  await svc.deleteContact(contact.id);
                }
              } else if (value == 'block') {
                if (!context.mounted) return;
                await svc.blockContact(contact.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${contact.name} blocked')));
              } else if (value == 'unblock') {
                if (!context.mounted) return;
                await svc.unblockContact(contact.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${contact.name} unblocked')));
              }
            },
            itemBuilder: (context) => [
              if (!isBlocked)
                const PopupMenuItem(
                  value: 'block',
                  child: Text('Block', style: TextStyle(color: Colors.white)),
                ),
              if (isBlocked)
                const PopupMenuItem(
                  value: 'unblock',
                  child: Text('Unblock', style: TextStyle(color: Colors.white)),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
