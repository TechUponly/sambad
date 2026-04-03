import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({Key? key}) : super(key: key);
  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  List<dynamic> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    try {
      _logs = await ApiService().fetchAuditLogs();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'LOGIN': return Icons.login;
      case 'CREATE_ADMIN': return Icons.person_add;
      case 'UPDATE_ADMIN': return Icons.edit;
      case 'DELETE_ADMIN': return Icons.person_remove;
      case 'CHANGE_PASSWORD': return Icons.lock_reset;
      case 'SEND_NOTIFICATION': return Icons.notifications;
      case 'UPDATE_SETTING': return Icons.tune;
      default: return Icons.history;
    }
  }

  Color _actionColor(String action) {
    if (action.startsWith('DELETE')) return Colors.red;
    if (action.startsWith('CREATE') || action == 'LOGIN') return Colors.green;
    if (action.startsWith('UPDATE') || action == 'CHANGE_PASSWORD') return Colors.orange;
    if (action == 'SEND_NOTIFICATION') return Colors.blue;
    return Colors.grey;
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
        Row(children: [
          Icon(Icons.history, color: theme.colorScheme.primary, size: 36),
          const SizedBox(width: 14),
          Text('Audit Trail', style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary, fontSize: 32, fontWeight: FontWeight.w900,
          )),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadLogs,
          ),
        ]),
        const SizedBox(height: 20),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_logs.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(children: [
              Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text('No audit logs yet', style: TextStyle(color: Colors.grey[500])),
            ]),
          ))
        else
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, i) {
                final log = _logs[i];
                final action = log['action'] ?? '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _actionColor(action).withOpacity(0.12),
                      child: Icon(_actionIcon(action), color: _actionColor(action), size: 20),
                    ),
                    title: Text(action.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('By: ${log['admin_username'] ?? 'Unknown'}', style: const TextStyle(fontSize: 12)),
                        if (log['details'] != null)
                          Text('${log['details']}', style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    trailing: Text(_formatDate(log['timestamp']), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
