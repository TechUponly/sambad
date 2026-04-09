import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../utils/phone_validator.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final int unreadCount;

  const ContactTile({super.key, required this.contact, this.onTap, this.unreadCount = 0});

  void _showEditDialog(BuildContext context, ChatService svc) {
    final nameCtrl = TextEditingController(text: contact.name);
    final phoneCtrl = TextEditingController(text: contact.phone.replaceAll(RegExp(r'^\+\d{1,3}'), ''));
    String countryCode = '+91';
    // Try to extract country code from existing phone
    final phoneMatch = RegExp(r'^(\+\d{1,3})(\d+)$').firstMatch(contact.phone);
    if (phoneMatch != null) {
      countryCode = phoneMatch.group(1)!;
      phoneCtrl.text = phoneMatch.group(2)!;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Contact', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.person, color: AppColors.primaryBlue),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final codes = ['+91', '+1', '+44', '+61', '+86', '+81', '+49', '+33', '+971', '+92', '+880', '+65'];
                        final selected = await showDialog<String>(
                          context: ctx,
                          builder: (c) => SimpleDialog(
                            backgroundColor: AppColors.bgCard,
                            title: const Text('Country Code', style: TextStyle(color: Colors.white)),
                            children: codes.map((cc) => SimpleDialogOption(
                              onPressed: () => Navigator.pop(c, cc),
                              child: Text(cc, style: const TextStyle(color: Colors.white)),
                            )).toList(),
                          ),
                        );
                        if (selected != null) setDialogState(() => countryCode = selected);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(countryCode, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                            const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(PhoneValidator.getExpectedDigits(countryCode)),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          labelStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final newName = nameCtrl.text.trim();
                        final newPhone = '$countryCode${PhoneValidator.cleanPhone(phoneCtrl.text)}';
                        if (newName.isEmpty) return;
                        svc.updateContact(contact.id, name: newName, phone: newPhone);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$newName updated ✅'), backgroundColor: AppColors.primaryBlue),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<ChatService>(context);
    final isBlocked = svc.blockedContacts.contains(contact.id);
    final isOnline = svc.isOnline(contact.id);
    return ListTile(
      onTap: onTap,
      contentPadding: Responsive.paddingSymmetric(context, v: 6, h: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: Responsive.size(context, 26),
            backgroundColor: AppColors.avatarColor(contact.name),
            child: Text(
              contact.name.isNotEmpty ? contact.name.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.fontSize(context, 16)),
            ),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF23272F), width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(contact.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: Responsive.fontSize(context, 16))),
      subtitle: Text(contact.phone, style: TextStyle(color: Colors.white70, fontSize: Responsive.fontSize(context, 13))),
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
              if (value == 'edit') {
                _showEditDialog(context, svc);
              } else if (value == 'delete') {
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
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.18), width: 1.5),
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
                                  shadowColor: Colors.redAccent.withValues(alpha: 0.18),
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
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit', style: TextStyle(color: Colors.white)),
              ),
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
