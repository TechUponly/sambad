import 'package:flutter/material.dart';

class AdminControlPage extends StatefulWidget {
  const AdminControlPage({Key? key}) : super(key: key);

  @override
  State<AdminControlPage> createState() => _AdminControlPageState();
}

class _AdminControlPageState extends State<AdminControlPage> {
  // Example state for roles and users
  List<Map<String, dynamic>> users = [
    {'username': 'superadmin', 'role': 'superadmin'},
    {'username': 'mod1', 'role': 'moderator'},
    {'username': 'ops1', 'role': 'operator'},
    {'username': 'viewer1', 'role': 'viewer'},
  ];

  String? selectedUser;
  String? selectedRole;
  final List<String> roles = ['superadmin', 'moderator', 'operator', 'viewer'];

  void updateRole(String username, String newRole) {
    setState(() {
      users = users.map((u) => u['username'] == username ? {...u, 'role': newRole} : u).toList();
    });
    // TODO: Call backend API to update role
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Control Panel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Role Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      title: Text(user['username']),
                      subtitle: Text('Role: ${user['role']}'),
                      trailing: DropdownButton<String>(
                        value: user['role'],
                        items: roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                        onChanged: (role) {
                          if (role != null) updateRole(user['username'], role);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            const Text('Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Call backend API to clear all user chats
                  },
                  child: const Text('Clear All User Chats'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Call backend API to block a user
                  },
                  child: const Text('Block User'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Call backend API to push notification
                  },
                  child: const Text('Push Notification'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Call backend API to update settings
                  },
                  child: const Text('Update Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
