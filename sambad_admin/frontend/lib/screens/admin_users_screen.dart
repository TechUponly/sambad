import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> _admins = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() { _loading = true; _error = null; });
    try {
      _admins = await ApiService().fetchAdminUsers();
    } catch (e) {
      _error = 'Failed to load admin users';
    }
    if (mounted) setState(() => _loading = false);
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'super_admin': return Colors.red[700]!;
      case 'admin': return Colors.blue[700]!;
      case 'moderator': return Colors.green[700]!;
      case 'viewer': return Colors.grey[600]!;
      default: return Colors.grey;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'super_admin': return 'Super Admin';
      case 'admin': return 'Admin';
      case 'moderator': return 'Moderator';
      case 'viewer': return 'Viewer';
      default: return role;
    }
  }

  void _showAddDialog() {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedRole = 'moderator';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Icon(Icons.person_add, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Add Admin User'),
          ]),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Username *',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email (optional)',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.admin_panel_settings),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['super_admin', 'admin', 'moderator', 'viewer']
                      .map((r) => DropdownMenuItem(value: r, child: Text(_roleLabel(r))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (usernameCtrl.text.trim().isEmpty || passwordCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username and password are required'), backgroundColor: Colors.red),
                  );
                  return;
                }
                try {
                  await ApiService().createAdminUser(
                    username: usernameCtrl.text.trim(),
                    password: passwordCtrl.text,
                    email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                    role: selectedRole,
                  );
                  Navigator.pop(ctx);
                  _loadAdmins();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Admin user created'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Failed: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> admin) {
    String selectedRole = admin['role'] ?? 'moderator';
    bool isActive = admin['is_active'] ?? true;
    final emailCtrl = TextEditingController(text: admin['email'] ?? '');
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Text('Edit: ${admin['username']}'),
          ]),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password (leave blank to keep)',
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.admin_panel_settings),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['super_admin', 'admin', 'moderator', 'viewer']
                      .map((r) => DropdownMenuItem(value: r, child: Text(_roleLabel(r))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  title: const Text('Account Active'),
                  subtitle: Text(isActive ? 'User can login' : 'User is blocked'),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await ApiService().updateAdminUser(
                    admin['id'],
                    email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                    role: selectedRole,
                    isActive: isActive,
                    password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
                  );
                  Navigator.pop(ctx);
                  _loadAdmins();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Admin updated'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Failed: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 10),
          const Text('Delete Admin'),
        ]),
        content: Text('Are you sure you want to delete "${admin['username']}"?\nThis cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await ApiService().deleteAdminUser(admin['id']);
                Navigator.pop(ctx);
                _loadAdmins();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin user deleted'), backgroundColor: Colors.orange),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Cannot delete: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic d) {
    if (d == null) return '-';
    try {
      final dt = DateTime.parse(d.toString()).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return d.toString(); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.manage_accounts, color: theme.colorScheme.primary, size: 36),
            const SizedBox(width: 14),
            Text('Admin Users', style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary, fontSize: 32, fontWeight: FontWeight.w900,
            )),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_loading) const Center(child: CircularProgressIndicator())
        else if (_error != null) Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
        else Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withOpacity(0.08)),
                columns: const [
                  DataColumn(label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Last Login', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _admins.map((admin) {
                  final role = admin['role'] ?? 'viewer';
                  final active = admin['is_active'] ?? true;
                  return DataRow(cells: [
                    DataCell(Text(admin['username'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(admin['email'] ?? '-')),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _roleColor(role).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_roleLabel(role), style: TextStyle(
                        color: _roleColor(role), fontWeight: FontWeight.bold, fontSize: 12,
                      )),
                    )),
                    DataCell(Row(children: [
                      Icon(active ? Icons.check_circle : Icons.block, 
                        color: active ? Colors.green : Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Text(active ? 'Active' : 'Disabled', style: TextStyle(
                        color: active ? Colors.green[700] : Colors.red[700], fontSize: 13,
                      )),
                    ])),
                    DataCell(Text(_formatDate(admin['last_login_at']))),
                    DataCell(Row(children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: theme.colorScheme.primary, size: 20),
                        tooltip: 'Edit',
                        onPressed: () => _showEditDialog(admin),
                      ),
                      if (admin['id'] != AdminAuthState.currentAdmin?['id'])
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          tooltip: 'Delete',
                          onPressed: () => _confirmDelete(admin),
                        ),
                    ])),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
