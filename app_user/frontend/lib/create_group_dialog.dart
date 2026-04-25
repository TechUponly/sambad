import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'services/chat_service.dart';
import 'theme/app_colors.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedContacts = {};
  String? _groupPhotoPath;

  Future<void> _pickGroupPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _groupPhotoPath = picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Dialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Group', style: TextStyle(color: c.text, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Group photo picker
            Center(
              child: GestureDetector(
                onTap: _pickGroupPhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                      backgroundImage: _groupPhotoPath != null ? FileImage(File(_groupPhotoPath!)) : null,
                      child: _groupPhotoPath == null
                          ? const Icon(Icons.group, size: 40, color: AppColors.primaryBlue)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.card, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: TextStyle(color: c.text, fontSize: 16),
              cursorColor: AppColors.primaryBlue,
              decoration: InputDecoration(
                hintText: 'Group name',
                hintStyle: TextStyle(color: c.textMuted),
                prefixIcon: const Icon(Icons.group, color: AppColors.primaryBlue),
                filled: true,
                fillColor: c.text.withValues(alpha: 0.08),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text('Select Members', style: TextStyle(color: c.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Consumer<ChatService>(
                builder: (context, chatService, _) {
                  final contacts = chatService.contacts;
                  if (contacts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 48, color: c.textHint),
                          const SizedBox(height: 12),
                          Text('No contacts available', style: TextStyle(color: c.textMuted, fontSize: 14)),
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
                              color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.15) : c.text.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: AppColors.primaryBlue, width: 1.5) : null,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected ? AppColors.primaryBlue : c.text.withValues(alpha: 0.1),
                                  radius: 20,
                                  child: Text(
                                    contact.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(color: isSelected ? Colors.white : c.textSecondary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(contact.name, style: TextStyle(color: c.text, fontSize: 15, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text(contact.phone, style: TextStyle(color: c.textMuted, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 24),
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
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: c.textSecondary, fontSize: 15)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _nameController.text.trim().isEmpty ? null : () async {
                    final chatService = context.read<ChatService>();
                    final groupName = _nameController.text.trim();
                    chatService.addGroup(groupName, memberIds: _selectedContacts.toList());
                    // Save group photo if selected
                    if (_groupPhotoPath != null) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('group_photo_$groupName', _groupPhotoPath!);
                    }
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_selectedContacts.isEmpty 
                          ? 'Group "${_nameController.text.trim()}" created!'
                          : 'Group "${_nameController.text.trim()}" created with ${_selectedContacts.length} members!'),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: c.textHint,
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
