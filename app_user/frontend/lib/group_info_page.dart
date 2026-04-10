import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'services/chat_service.dart';
import 'models/contact.dart';
import 'theme/app_colors.dart';
import 'utils/responsive.dart';
import 'config/app_config.dart';
import 'utils/phone_validator.dart';
import 'utils/country_code_picker.dart';
import 'utils/country_codes.dart';
import 'package:flutter/services.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupName;
  final String? groupId;

  const GroupInfoPage({super.key, required this.groupName, this.groupId});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  Map<String, dynamic>? _groupDetails;
  bool _loading = true;
  String? _myRole;
  String? _groupPhotoPath;

  String? get resolvedGroupId {
    final svc = Provider.of<ChatService>(context, listen: false);
    return widget.groupId ?? svc.serverIdForGroup(widget.groupName);
  }

  @override
  void initState() {
    super.initState();
    _loadGroupPhoto();
    _fetchGroupDetails();
  }

  Future<void> _loadGroupPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('group_photo_${widget.groupName}');
    if (path != null && File(path).existsSync() && mounted) {
      setState(() => _groupPhotoPath = path);
    }
  }

  Future<void> _pickGroupPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _groupPhotoPath = picked.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('group_photo_${widget.groupName}', picked.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group photo updated'), backgroundColor: AppColors.primaryBlue),
        );
      }
    }
  }

  Future<void> _fetchGroupDetails() async {
    final svc = Provider.of<ChatService>(context, listen: false);
    
    // Resolve server ID: use passed groupId, or look up from ChatService
    final resolvedId = resolvedGroupId ?? svc.serverIdForGroup(widget.groupName);

    if (resolvedId == null) {
      // No server ID — use local data with proper roles
      final localMembers = svc.membersForGroup(widget.groupName);
      final roles = svc.rolesForGroup(widget.groupName);
      final contacts = svc.contacts;
      final prefs = await SharedPreferences.getInstance();
      final myName = prefs.getString('current_user_name') ?? prefs.getString('profile_name') ?? 'You';
      final myPhone = prefs.getString('current_user_phone') ?? '';
      
      final savedDesc = prefs.getString('group_desc_${widget.groupName}') ?? '';
      
      setState(() {
        _groupDetails = {
          'name': widget.groupName,
          'description': savedDesc,
          'members': localMembers.map((uid) {
            // Check if it's me
            if (uid == svc.currentUserId) {
              final role = roles[uid] ?? 'admin';
              return {'userId': uid, 'name': myName, 'phone': myPhone, 'role': role};
            }
            // Try to find contact name
            final contact = contacts.where((c) => c.id == uid).toList();
            final name = contact.isNotEmpty ? contact.first.name : uid;
            final phone = contact.isNotEmpty ? contact.first.phone : '';
            final role = roles[uid] ?? 'member';
            return {'userId': uid, 'name': name, 'phone': phone, 'role': role};
          }).toList(),
        };
        // Set my role from local roles
        _myRole = svc.isGroupAdmin(widget.groupName) ? 'admin' : 'member';
        _loading = false;
      });
      return;
    }

    try {
      final headers = await svc.authHeaders();
      final resp = await http.get(
        Uri.parse('${AppConfig.apiBase}/groups/$resolvedId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        setState(() {
          _groupDetails = jsonDecode(resp.body);
          // Find my role
          final myId = svc.currentUserId;
          final members = _groupDetails?['members'] as List? ?? [];
          final me = members.cast<Map<String, dynamic>>().firstWhere(
            (m) => m['userId'] == myId,
            orElse: () => {'role': 'member'},
          );
          _myRole = me['role'] as String? ?? 'member';
          _loading = false;
        });
      } else {
        // API failed — fall back to local data
        _useLocalGroupData(svc);
      }
    } catch (e) {
      debugPrint('[GroupInfo] Error: $e — falling back to local data');
      _useLocalGroupData(svc);
    }
  }

  /// Fallback: build group details from local data when the API is unreachable
  void _useLocalGroupData(ChatService svc) async {
    final localMembers = svc.membersForGroup(widget.groupName);
    final roles = svc.rolesForGroup(widget.groupName);
    final contacts = svc.contacts;
    final prefs = await SharedPreferences.getInstance();
    final myName = prefs.getString('current_user_name') ?? prefs.getString('profile_name') ?? 'You';
    final myPhone = prefs.getString('current_user_phone') ?? '';

    // If no members recorded, add current user
    List<Map<String, dynamic>> memberList;
    if (localMembers.isEmpty) {
      memberList = [
        {'userId': svc.currentUserId ?? '', 'name': myName, 'phone': myPhone, 'role': 'admin'},
      ];
    } else {
      memberList = localMembers.map((uid) {
        if (uid == svc.currentUserId) {
          final role = roles[uid] ?? 'admin';
          return {'userId': uid, 'name': myName, 'phone': myPhone, 'role': role};
        }
        final contact = contacts.where((c) => c.id == uid).toList();
        final name = contact.isNotEmpty ? contact.first.name : uid;
        final phone = contact.isNotEmpty ? contact.first.phone : '';
        final role = roles[uid] ?? 'member';
        return <String, dynamic>{'userId': uid, 'name': name, 'phone': phone, 'role': role};
      }).toList();
    }

    // Load saved description
    final savedDesc = prefs.getString('group_desc_${widget.groupName}') ?? '';

    if (mounted) {
      setState(() {
        _groupDetails = {
          'name': widget.groupName,
          'description': savedDesc,
          'members': memberList,
        };
        _myRole = svc.isGroupAdmin(widget.groupName) ? 'admin' : 'member';
        _loading = false;
      });
    }
  }

  bool get isAdmin => _myRole == 'admin';

  Future<void> _editGroupName() async {
    final nameCtrl = TextEditingController(text: widget.groupName);
    final descCtrl = TextEditingController(text: _groupDetails?['description'] ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        final dc = AppColors.of(ctx);
        return Dialog(
        backgroundColor: AppColors.of(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Group', style: TextStyle(color: dc.text, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: dc.text),
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  labelStyle: TextStyle(color: dc.textMuted),
                  prefixIcon: const Icon(Icons.group, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: dc.text.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                style: TextStyle(color: dc.text),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: TextStyle(color: dc.textMuted),
                  prefixIcon: const Icon(Icons.description, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: dc.text.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: dc.textSecondary))),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, {'name': nameCtrl.text.trim(), 'description': descCtrl.text.trim()}),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );},
    );

    if (result != null && result['name']!.isNotEmpty) {
      // Save locally regardless of API success
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('group_desc_${widget.groupName}', result['description'] ?? '');
      
      // Update in-memory state immediately
      if (mounted) {
        setState(() {
          _groupDetails?['description'] = result['description'] ?? '';
          _groupDetails?['name'] = result['name'];
        });
      }
      
      // Try API (may fail if backend is down)
      if (resolvedGroupId != null) {
        try {
          final svc = Provider.of<ChatService>(context, listen: false);
          final headers = await svc.authHeaders();
          headers['Content-Type'] = 'application/json';
          await http.put(
            Uri.parse('${AppConfig.apiBase}/groups/${resolvedGroupId}'),
            headers: headers,
            body: jsonEncode({'name': result['name'], 'description': result['description'], 'userId': svc.currentUserId}),
          );
        } catch (e) {
          debugPrint('[GroupInfo] Edit API error: $e');
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Group updated'), backgroundColor: AppColors.primaryBlue));
      }
    }
  }

  Future<void> _addMember() async {
    final svc = Provider.of<ChatService>(context, listen: false);
    final contacts = svc.contacts;
    final currentMemberPhones = (_groupDetails?['members'] as List? ?? [])
        .map((m) => (m['phone'] as String? ?? '').replaceAll(RegExp(r'[^\d]'), ''))
        .where((p) => p.isNotEmpty)
        .toSet();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _AddMemberDialog(
        availableContacts: contacts,
        groupName: widget.groupName,
        existingMemberPhones: currentMemberPhones,
      ),
    );

    if (result != null) {
      final selectedId = result['id'];
      final manualName = result['name'];
      final manualPhone = result['phone'];

      if (selectedId != null) {
        // Existing contact selected
        await svc.addMemberToGroup(widget.groupName, selectedId);
        
        // Try backend sync
        if (resolvedGroupId != null) {
          try {
            final headers = await svc.authHeaders();
            headers['Content-Type'] = 'application/json';
            await http.post(
              Uri.parse('${AppConfig.apiBase}/groups/$resolvedGroupId/members'),
              headers: headers,
              body: jsonEncode({'userId': selectedId, 'addedBy': svc.currentUserId}),
            ).timeout(const Duration(seconds: 5));
          } catch (e) {
            debugPrint('[GroupInfo] Backend sync failed: $e');
          }
        }
      } else if (manualName != null && manualPhone != null) {
        // Manual entry — add as local contact + group member
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        await svc.addContact(Contact(id: newId, name: manualName, phone: manualPhone));
        await svc.addMemberToGroup(widget.groupName, newId);
      }
      
      _fetchGroupDetails();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Member added'), backgroundColor: AppColors.primaryBlue));
    }
  }

  Future<void> _removeMember(String userId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(context).card,
        title: Text('Remove Member', style: TextStyle(color: AppColors.of(context).text)),
        content: Text('Remove $name from this group?', style: TextStyle(color: AppColors.of(context).textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final svc = Provider.of<ChatService>(context, listen: false);
      // Save locally first
      await svc.removeMemberFromGroup(widget.groupName, userId);
      
      // Try backend sync
      if (resolvedGroupId != null) {
        try {
          final headers = await svc.authHeaders();
          await http.delete(
            Uri.parse('${AppConfig.apiBase}/groups/$resolvedGroupId/members/$userId?removedBy=${svc.currentUserId}'),
            headers: headers,
          ).timeout(const Duration(seconds: 5));
        } catch (e) {
          debugPrint('[GroupInfo] Backend remove sync failed: $e');
        }
      }
      _fetchGroupDetails();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name removed'), backgroundColor: Colors.red));
    }
  }

  Future<void> _toggleRole(String userId, String currentRole, String name) async {
    final newRole = currentRole == 'admin' ? 'member' : 'admin';
    final svc = Provider.of<ChatService>(context, listen: false);
    
    // Save locally first
    await svc.setMemberRole(widget.groupName, userId, newRole);
    
    // Try backend sync
    if (resolvedGroupId != null) {
      try {
        final headers = await svc.authHeaders();
        headers['Content-Type'] = 'application/json';
        await http.put(
          Uri.parse('${AppConfig.apiBase}/groups/$resolvedGroupId/members/$userId/role'),
          headers: headers,
          body: jsonEncode({'role': newRole, 'changedBy': svc.currentUserId}),
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('[GroupInfo] Backend role sync failed: $e');
      }
    }
    _fetchGroupDetails();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name is now ${newRole == 'admin' ? 'an admin' : 'a member'}'), backgroundColor: AppColors.primaryBlue));
  }

  Future<void> _exitGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(context).card,
        title: Text('Exit Group', style: TextStyle(color: AppColors.of(context).text)),
        content: Text('Are you sure you want to leave this group?', style: TextStyle(color: AppColors.of(context).textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (confirm == true && resolvedGroupId != null) {
      try {
        final svc = Provider.of<ChatService>(context, listen: false);
        final headers = await svc.authHeaders();
        headers['Content-Type'] = 'application/json';
        await http.post(
          Uri.parse('${AppConfig.apiBase}/groups/${resolvedGroupId}/exit'),
          headers: headers,
          body: jsonEncode({'userId': svc.currentUserId}),
        );
        svc.removeGroupLocally(widget.groupName);
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Left the group'), backgroundColor: Colors.orange));
        }
      } catch (e) {
        debugPrint('[GroupInfo] Exit error: $e');
      }
    }
  }

  Future<void> _deleteGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(context).card,
        title: Text('Delete Group', style: TextStyle(color: AppColors.of(context).text)),
        content: Text('This will permanently delete the group for all members. This cannot be undone.', style: TextStyle(color: AppColors.of(context).textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final svc = Provider.of<ChatService>(context, listen: false);
      
      // Try backend sync if server ID available
      if (resolvedGroupId != null) {
        try {
          final headers = await svc.authHeaders();
          await http.delete(
            Uri.parse('${AppConfig.apiBase}/groups/$resolvedGroupId?userId=${svc.currentUserId}'),
            headers: headers,
          ).timeout(const Duration(seconds: 5));
        } catch (e) {
          debugPrint('[GroupInfo] Backend delete failed (continuing locally): $e');
        }
      }
      
      // Always delete locally
      svc.removeGroupLocally(widget.groupName);
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group deleted'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = (_groupDetails?['members'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final description = _groupDetails?['description'] as String? ?? '';

    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        foregroundColor: c.text,
        title: Text('Group Info', style: TextStyle(color: c.text)),
        actions: [
          if (isAdmin)
            IconButton(icon: const Icon(Icons.edit), onPressed: _editGroupName, tooltip: 'Edit Group'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: Responsive.paddingAll(context, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group Header
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: isAdmin ? _pickGroupPhoto : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: Responsive.size(context, 48),
                                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                                backgroundImage: _groupPhotoPath != null && File(_groupPhotoPath!).existsSync()
                                    ? FileImage(File(_groupPhotoPath!))
                                    : null,
                                child: _groupPhotoPath == null || !File(_groupPhotoPath!).existsSync()
                                    ? Icon(Icons.group, size: Responsive.size(context, 48), color: AppColors.primaryBlue)
                                    : null,
                              ),
                              if (isAdmin)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: c.bg, width: 2),
                                    ),
                                    child: Icon(Icons.camera_alt, size: Responsive.size(context, 14), color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.vertical(context, 16)),
                        Text(
                          _groupDetails?['name'] ?? widget.groupName,
                          style: TextStyle(color: c.text, fontSize: Responsive.fontSize(context, 24), fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: Responsive.vertical(context, 4)),
                        Text(
                          '${members.length} members',
                          style: TextStyle(color: c.textMuted, fontSize: Responsive.fontSize(context, 14)),
                        ),
                        if (description.isNotEmpty) ...[
                          SizedBox(height: Responsive.vertical(context, 8)),
                          Text(description, style: TextStyle(color: c.textSecondary, fontSize: Responsive.fontSize(context, 14)), textAlign: TextAlign.center),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.vertical(context, 24)),

                  // Members Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Members', style: TextStyle(color: c.text, fontSize: Responsive.fontSize(context, 18), fontWeight: FontWeight.bold)),
                      if (isAdmin)
                        TextButton.icon(
                          onPressed: _addMember,
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Add'),
                        ),
                    ],
                  ),
                  SizedBox(height: Responsive.vertical(context, 8)),

                  ...members.map((m) {
                    final name = m['name'] as String? ?? 'Unknown';
                    final phone = m['phone'] as String? ?? '';
                    final role = m['role'] as String? ?? 'member';
                    final userId = m['userId'] as String? ?? '';
                    final svc = Provider.of<ChatService>(context, listen: false);
                    final isMe = userId == svc.currentUserId;

                    return Container(
                      margin: EdgeInsets.only(bottom: Responsive.vertical(context, 4)),
                      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.avatarColor(name),
                          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Row(
                          children: [
                            Text(isMe ? '$name (You)' : name, style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
                            if (role == 'admin') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                child: Text('Admin', style: TextStyle(color: AppColors.primaryBlue, fontSize: Responsive.fontSize(context, 11), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(phone, style: TextStyle(color: c.textMuted, fontSize: Responsive.fontSize(context, 13))),
                        trailing: isAdmin && !isMe
                            ? PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: c.textMuted),
                                color: c.card,
                                onSelected: (v) {
                                  if (v == 'remove') _removeMember(userId, name);
                                  if (v == 'role') _toggleRole(userId, role, name);
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'role',
                                    child: Text(role == 'admin' ? 'Demote to Member' : 'Make Admin', style: TextStyle(color: c.text)),
                                  ),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Text('Remove', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  }),

                  SizedBox(height: Responsive.vertical(context, 32)),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _exitGroup,
                      icon: const Icon(Icons.exit_to_app, color: Colors.orange),
                      label: const Text('Exit Group', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  if (isAdmin) ...[
                    SizedBox(height: Responsive.vertical(context, 12)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _deleteGroup,
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Delete Group'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: Responsive.vertical(context, 24)),
                ],
              ),
            ),
    );
  }
}

// ── Add Member Dialog (search + manual + invite) ──

// ── Add Member Dialog (search + manual + invite) ──

class _AddMemberDialog extends StatefulWidget {
  final List<dynamic> availableContacts;
  final String groupName;
  final Set<String> existingMemberPhones;

  const _AddMemberDialog({required this.availableContacts, required this.groupName, this.existingMemberPhones = const {}});

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _showManualEntry = false;
  String _searchQuery = '';
  String _countryCode = '+91';
  String? _phoneError;

  static const String _playStoreLink = 'https://play.google.com/store/apps/details?id=com.shamrai.sambad';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool _isAlreadyMember(dynamic c) {
    final phoneDigits = (c.phone as String).replaceAll(RegExp(r'[^0-9]'), '');
    return widget.existingMemberPhones.any((p) => phoneDigits.endsWith(p) || p.endsWith(phoneDigits));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? widget.availableContacts
        : widget.availableContacts.where((c) {
            final name = (c.name as String).toLowerCase();
            final phone = (c.phone as String).toLowerCase();
            final q = _searchQuery.toLowerCase();
            return name.contains(q) || phone.contains(q);
          }).toList();

    final dc = AppColors.of(context);
    final expectedDigits = PhoneValidator.getExpectedDigits(_countryCode);

    return Dialog(
      backgroundColor: dc.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Member', style: TextStyle(color: dc.text, fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close, color: dc.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Search bar
            TextField(
              controller: _searchCtrl,
              style: TextStyle(color: dc.text),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: TextStyle(color: dc.textHint),
                prefixIcon: Icon(Icons.search, color: dc.textHint),
                filled: true,
                fillColor: dc.text.withValues(alpha: 0.08),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 12),

            if (!_showManualEntry) ...[
              // Scrollable contact list
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: filtered.isEmpty
                    ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(widget.availableContacts.isEmpty ? 'No contacts available' : 'No matches found', style: TextStyle(color: dc.textMuted))))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final c = filtered[i];
                          final alreadyMember = _isAlreadyMember(c);
                          return Opacity(
                            opacity: alreadyMember ? 0.5 : 1.0,
                            child: ListTile(
                              leading: CircleAvatar(backgroundColor: AppColors.avatarColor(c.name), child: Text(c.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              title: Text(c.name, style: TextStyle(color: dc.text)),
                              subtitle: Text(alreadyMember ? '${c.phone} · Already added' : c.phone, style: TextStyle(color: alreadyMember ? Colors.orange : dc.textMuted, fontSize: 13)),
                              trailing: alreadyMember ? Icon(Icons.check_circle, color: Colors.green.shade400, size: 20) : null,
                              onTap: alreadyMember ? null : () {
                                debugPrint('[AddMember] Selected: ${c.name} id=${c.id}');
                                Navigator.of(context).pop(<String, String>{'id': c.id.toString()});
                              },
                            ),
                          );
                        },
                      ),
              ),
              Divider(color: dc.textHint.withValues(alpha: 0.2), height: 16),
              ListTile(
                dense: true,
                leading: const CircleAvatar(radius: 18, backgroundColor: AppColors.primaryBlue, child: Icon(Icons.person_add, color: Colors.white, size: 18)),
                title: const Text('Add manually', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () => setState(() => _showManualEntry = true),
              ),
              ListTile(
                dense: true,
                leading: CircleAvatar(radius: 18, backgroundColor: Colors.green.shade600, child: const Icon(Icons.chat, color: Colors.white, size: 18)),
                title: const Text('Invite via WhatsApp', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.of(context).pop();
                  Share.share('Hey! Join me on Private Samvad \u{1F512}\n\nDownload: $_playStoreLink');
                },
              ),
            ],

            // Manual entry form
            if (_showManualEntry) ...[
              TextField(
                controller: _nameCtrl,
                style: TextStyle(color: dc.text),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: dc.textMuted),
                  prefixIcon: const Icon(Icons.person, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: dc.text.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Text('Phone number', style: TextStyle(color: dc.textMuted, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final selected = await showCountryCodePicker(context);
                      if (selected != null) setState(() { _countryCode = selected.code; _phoneError = null; });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(color: dc.text.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('${CountryCodes.findByCode(_countryCode)?.flag ?? ''} $_countryCode', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                        Icon(Icons.arrow_drop_down, color: dc.textMuted, size: 18),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: dc.text),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(expectedDigits)],
                      onChanged: (_) { if (_phoneError != null) setState(() => _phoneError = null); },
                      decoration: InputDecoration(
                        hintText: '$expectedDigits digits',
                        hintStyle: TextStyle(color: dc.textHint),
                        filled: true,
                        fillColor: dc.text.withValues(alpha: 0.08),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
                        errorText: _phoneError,
                        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () => setState(() => _showManualEntry = false),
                  child: Text('Back', style: TextStyle(color: dc.textSecondary)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameCtrl.text.trim();
                    final phone = _phoneCtrl.text.trim();
                    if (name.isEmpty) return;
                    final validation = PhoneValidator.validate(phone, _countryCode);
                    if (validation != null) {
                      setState(() => _phoneError = validation);
                      return;
                    }
                    final cleanedPhone = PhoneValidator.cleanPhone(phone);
                    final fullPhone = '$_countryCode$cleanedPhone';
                    debugPrint('[AddMember] Manual add: name=$name, phone=$fullPhone');
                    Navigator.of(context).pop(<String, String>{'name': name, 'phone': fullPhone});
                  },
                  child: const Text('Add'),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
