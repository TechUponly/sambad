import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RightsScreen extends StatelessWidget {
  const RightsScreen({Key? key}) : super(key: key);

  static const roles = ['super_admin', 'admin', 'moderator', 'viewer'];
  static const roleLabels = {'super_admin': 'Super Admin', 'admin': 'Admin', 'moderator': 'Moderator', 'viewer': 'Viewer'};

  static const permissions = [
    {'feature': 'Dashboard', 'icon': Icons.dashboard, 'allowed': ['super_admin', 'admin', 'moderator', 'viewer']},
    {'feature': 'View App Users', 'icon': Icons.people, 'allowed': ['super_admin', 'admin', 'moderator', 'viewer']},
    {'feature': 'Send Notifications', 'icon': Icons.notifications_active, 'allowed': ['super_admin', 'admin']},
    {'feature': 'Analytics', 'icon': Icons.analytics, 'allowed': ['super_admin', 'admin', 'moderator', 'viewer']},
    {'feature': 'Manage Admin Users', 'icon': Icons.manage_accounts, 'allowed': ['super_admin']},
    {'feature': 'App Config', 'icon': Icons.tune, 'allowed': ['super_admin']},
    {'feature': 'View Rights Matrix', 'icon': Icons.admin_panel_settings, 'allowed': ['super_admin', 'admin']},
    {'feature': 'Audit Trail', 'icon': Icons.history, 'allowed': ['super_admin', 'admin']},
    {'feature': 'Profile & Password', 'icon': Icons.person, 'allowed': ['super_admin', 'admin', 'moderator', 'viewer']},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentRole = AdminAuthState.role;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.admin_panel_settings, color: theme.colorScheme.primary, size: 36),
            const SizedBox(width: 14),
            Text('Role Permissions', style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary, fontSize: 32, fontWeight: FontWeight.w900,
            )),
          ]),
          const SizedBox(height: 8),
          Text('Your role: ${roleLabels[currentRole] ?? currentRole}', 
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 24),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withOpacity(0.08)),
                columns: [
                  const DataColumn(label: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold))),
                  ...roles.map((r) => DataColumn(
                    label: Text(roleLabels[r] ?? r, style: const TextStyle(fontWeight: FontWeight.bold)),
                  )),
                ],
                rows: permissions.map((p) {
                  final allowed = p['allowed'] as List<String>;
                  return DataRow(cells: [
                    DataCell(Row(children: [
                      Icon(p['icon'] as IconData, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(p['feature'] as String),
                    ])),
                    ...roles.map((r) => DataCell(
                      Center(child: Icon(
                        allowed.contains(r) ? Icons.check_circle : Icons.cancel,
                        color: allowed.contains(r) ? Colors.green : Colors.red[300],
                        size: 22,
                      )),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 28),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Role Descriptions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _roleDesc('Super Admin', 'Full access to all features. Can manage admin users, app config, and view audit trail.', Colors.red[700]!),
                  _roleDesc('Admin', 'Can view data, send notifications, and view audit logs. Cannot manage admin users or config.', Colors.blue[700]!),
                  _roleDesc('Moderator', 'Can view dashboard, users, and analytics. Read-only access.', Colors.green[700]!),
                  _roleDesc('Viewer', 'Minimal access — dashboard and user list only.', Colors.grey[600]!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleDesc(String role, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(role, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
