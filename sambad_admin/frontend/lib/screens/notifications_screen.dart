import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _sendingToAll = true;
  bool _isSending = false;
  List<dynamic> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await ApiService().fetchNotifications();
      setState(() {
        _history = data;
        _loadingHistory = false;
      });
    } catch (e) {
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body are required'), backgroundColor: Colors.red),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Confirm Send'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send this notification to ${_sendingToAll ? "ALL users" : "specific users"}?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_titleController.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(_bodyController.text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSending = true);
    try {
      final result = await ApiService().sendNotification(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        audience: _sendingToAll ? 'all' : 'specific',
      );
      setState(() => _isSending = false);
      _titleController.clear();
      _bodyController.clear();
      _loadHistory();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Sent to ${result['sent_count'] ?? 0} users (${result['failed_count'] ?? 0} failed)',
          ),
          backgroundColor: Colors.green[700],
        ),
      );
    } catch (e) {
      setState(() => _isSending = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.notifications_active, color: theme.colorScheme.primary, size: 36),
              const SizedBox(width: 14),
              Text(
                'Push Notifications',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Compose Card
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Compose Notification', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g. New Feature Available!',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _bodyController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Message Body',
                      hintText: 'e.g. Check out our new group chat feature...',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: Icon(Icons.message),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Audience Toggle
                  Row(
                    children: [
                      Icon(Icons.people, color: theme.colorScheme.secondary),
                      const SizedBox(width: 10),
                      Text('Audience:', style: theme.textTheme.titleMedium),
                      const SizedBox(width: 14),
                      ChoiceChip(
                        label: const Text('All Users'),
                        selected: _sendingToAll,
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: _sendingToAll ? Colors.white : theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => _sendingToAll = true),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Specific Users'),
                        selected: !_sendingToAll,
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: !_sendingToAll ? Colors.white : theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => _sendingToAll = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _sendNotification,
                      icon: _isSending
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send),
                      label: Text(_isSending ? 'Sending...' : 'Send Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // History
          Text('Notification History', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_loadingHistory)
            const Center(child: CircularProgressIndicator())
          else if (_history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.notifications_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('No notifications sent yet', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_history.length, (i) {
              final n = _history[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                    child: Icon(Icons.notifications, color: theme.colorScheme.primary),
                  ),
                  title: Text(n['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['body'] ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text('${n['sent_count'] ?? 0} sent', style: TextStyle(fontSize: 12, color: Colors.green[700])),
                          const SizedBox(width: 12),
                          if ((n['failed_count'] ?? 0) > 0) ...[
                            Icon(Icons.error, size: 14, color: Colors.red[700]),
                            const SizedBox(width: 4),
                            Text('${n['failed_count']} failed', style: TextStyle(fontSize: 12, color: Colors.red[700])),
                          ],
                          const Spacer(),
                          Text(
                            _formatDate(n['created_at']),
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr.toString());
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr.toString();
    }
  }
}
