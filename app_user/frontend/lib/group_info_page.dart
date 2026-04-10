import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/chat_service.dart';
import 'theme/app_colors.dart';
import 'utils/responsive.dart';
import 'config/app_config.dart';

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

  String? get resolvedGroupId {
    final svc = Provider.of<ChatService>(context, listen: false);
    return widget.groupId ?? svc.serverIdForGroup(widget.groupName);
  }

  @override
  void initState() {
    super.initState();
    _fetchGroupDetails();
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
      
      setState(() {
        _groupDetails = {
          'name': widget.groupName,
          'description': '',
          'members': localMembers.map((uid) {
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
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('[GroupInfo] Error: $e');
      setState(() => _loading = false);
    }
  }

  bool get isAdmin => _myRole == 'admin';

  Future<void> _editGroupName() async {
    final nameCtrl = TextEditingController(text: widget.groupName);
    final descCtrl = TextEditingController(text: _groupDetails?['description'] ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Group', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  labelStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.group, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.description, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
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
      ),
    );

    if (result != null && result['name']!.isNotEmpty && resolvedGroupId != null) {
      try {
        final svc = Provider.of<ChatService>(context, listen: false);
        final headers = await svc.authHeaders();
        headers['Content-Type'] = 'application/json';
        await http.put(
          Uri.parse('${AppConfig.apiBase}/groups/${resolvedGroupId}'),
          headers: headers,
          body: jsonEncode({'name': result['name'], 'description': result['description'], 'userId': svc.currentUserId}),
        );
        _fetchGroupDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Group updated'), backgroundColor: AppColors.primaryBlue));
        }
      } catch (e) {
        debugPrint('[GroupInfo] Edit error: $e');
      }
    }
  }

  Future<void> _addMember() async {
    final svc = Provider.of<ChatService>(context, listen: false);
    final contacts = svc.contacts;
    final currentMembers = (_groupDetails?['members'] as List? ?? []).map((m) => m['userId'] as String).toSet();

    final availableContacts = contacts.where((c) => !currentMembers.contains(c.id)).toList();

    if (availableContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All your contacts are already members')));
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Member', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableContacts.length,
                  itemBuilder: (_, i) {
                    final c = availableContacts[i];
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: AppColors.avatarColor(c.name), child: Text(c.name[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
                      title: Text(c.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(c.phone, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                      onTap: () => Navigator.pop(ctx, c.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      // Save locally first (works offline)
      await svc.addMemberToGroup(widget.groupName, selected);
      
      // Try backend sync
      if (resolvedGroupId != null) {
        try {
          final headers = await svc.authHeaders();
          headers['Content-Type'] = 'application/json';
          await http.post(
            Uri.parse('${AppConfig.apiBase}/groups/$resolvedGroupId/members'),
            headers: headers,
            body: jsonEncode({'userId': selected, 'addedBy': svc.currentUserId}),
          ).timeout(const Duration(seconds: 5));
        } catch (e) {
          debugPrint('[GroupInfo] Backend sync failed (local saved): $e');
        }
      }
      _fetchGroupDetails();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Member added'), backgroundColor: AppColors.primaryBlue));
    }
  }

  Future<void> _removeMember(String userId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Remove Member', style: TextStyle(color: Colors.white)),
        content: Text('Remove $name from this group?', style: const TextStyle(color: Colors.white70)),
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
        backgroundColor: AppColors.bgCard,
        title: const Text('Exit Group', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to leave this group?', style: TextStyle(color: Colors.white70)),
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
        backgroundColor: AppColors.bgCard,
        title: const Text('Delete Group', style: TextStyle(color: Colors.white)),
        content: const Text('This will permanently delete the group for all members. This cannot be undone.', style: TextStyle(color: Colors.white70)),
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

    if (confirm == true && resolvedGroupId != null) {
      try {
        final svc = Provider.of<ChatService>(context, listen: false);
        final headers = await svc.authHeaders();
        await http.delete(
          Uri.parse('${AppConfig.apiBase}/groups/${resolvedGroupId}?userId=${svc.currentUserId}'),
          headers: headers,
        );
        svc.removeGroupLocally(widget.groupName);
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group deleted'), backgroundColor: Colors.red));
        }
      } catch (e) {
        debugPrint('[GroupInfo] Delete error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = (_groupDetails?['members'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final description = _groupDetails?['description'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        foregroundColor: Colors.white,
        title: const Text('Group Info'),
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
                        CircleAvatar(
                          radius: Responsive.size(context, 48),
                          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                          child: Icon(Icons.group, size: Responsive.size(context, 48), color: AppColors.primaryBlue),
                        ),
                        SizedBox(height: Responsive.vertical(context, 16)),
                        Text(
                          _groupDetails?['name'] ?? widget.groupName,
                          style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 24), fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: Responsive.vertical(context, 4)),
                        Text(
                          '${members.length} members',
                          style: TextStyle(color: Colors.white60, fontSize: Responsive.fontSize(context, 14)),
                        ),
                        if (description.isNotEmpty) ...[
                          SizedBox(height: Responsive.vertical(context, 8)),
                          Text(description, style: TextStyle(color: Colors.white70, fontSize: Responsive.fontSize(context, 14)), textAlign: TextAlign.center),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.vertical(context, 24)),

                  // Members Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Members', style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 18), fontWeight: FontWeight.bold)),
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
                      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.avatarColor(name),
                          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Row(
                          children: [
                            Text(isMe ? '$name (You)' : name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                        subtitle: Text(phone, style: TextStyle(color: Colors.white60, fontSize: Responsive.fontSize(context, 13))),
                        trailing: isAdmin && !isMe
                            ? PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.white54),
                                color: AppColors.bgCard,
                                onSelected: (v) {
                                  if (v == 'remove') _removeMember(userId, name);
                                  if (v == 'role') _toggleRole(userId, role, name);
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'role',
                                    child: Text(role == 'admin' ? 'Demote to Member' : 'Make Admin', style: const TextStyle(color: Colors.white)),
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
