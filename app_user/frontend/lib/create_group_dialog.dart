import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/chat_service.dart';

const Color kPrimaryBlue = Color(0xFF5B7FFF);
const Color kBgCard = Color(0xFF23272F);

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedContacts = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kBgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Group', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: kPrimaryBlue,
              decoration: InputDecoration(
                hintText: 'Group name',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.group, color: kPrimaryBlue),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kPrimaryBlue, width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Select Members', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<ChatService>(
                builder: (context, chatService, _) {
                  final contacts = chatService.contacts;
                  if (contacts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 48, color: Colors.white.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text('No contacts available', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final isSelected = _selectedContacts.contains(contact.id);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedContacts.remove(contact.id);
                              } else {
                                _selectedContacts.add(contact.id);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? kPrimaryBlue.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: kPrimaryBlue, width: 1.5) : null,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected ? kPrimaryBlue : Colors.white.withOpacity(0.1),
                                  radius: 20,
                                  child: Text(
                                    contact.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(contact.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text(contact.phone, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                                    ],
                                  ),
                                ),
                                if (isSelected) const Icon(Icons.check_circle, color: kPrimaryBlue, size: 24),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontSize: 15)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedContacts.isEmpty || _nameController.text.isEmpty ? null : () {
                    final chatService = context.read<ChatService>();
                    chatService.addGroup(_nameController.text);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Group "${_nameController.text}" created with ${_selectedContacts.length} members!'),
                        backgroundColor: kPrimaryBlue,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 18),
                      const SizedBox(width: 6),
                      Text('Create (${_selectedContacts.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
