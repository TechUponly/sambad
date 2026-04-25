import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  bool _loading = true;
  List<dynamic> _allFeedback = [];
  List<dynamic> _filtered = [];
  String _filterStatus = 'all';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService().fetchFeedback();
      setState(() {
        _allFeedback = data;
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _applyFilter() {
    if (_filterStatus == 'all') {
      _filtered = List.from(_allFeedback);
    } else {
      _filtered = _allFeedback.where((fb) => fb['status'] == _filterStatus).toList();
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await ApiService().updateFeedbackStatus(id, status);
      await _loadFeedback();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback marked as $status'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new': return Colors.blue;
      case 'read': return Colors.orange;
      case 'resolved': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'bug': return Colors.red;
      case 'feature': return Colors.purple;
      case 'security': return Colors.orange;
      default: return Colors.blue;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'bug': return Icons.bug_report;
      case 'feature': return Icons.lightbulb;
      case 'security': return Icons.security;
      default: return Icons.feedback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final newCount = _allFeedback.where((fb) => fb['status'] == 'new').length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text('User Feedback', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                if (newCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                    child: Text('$newCount new', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                const Spacer(),
                IconButton(onPressed: _loadFeedback, icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 8,
              children: [
                _filterChip('All', 'all', _allFeedback.length),
                _filterChip('New', 'new', _allFeedback.where((fb) => fb['status'] == 'new').length),
                _filterChip('Read', 'read', _allFeedback.where((fb) => fb['status'] == 'read').length),
                _filterChip('Resolved', 'resolved', _allFeedback.where((fb) => fb['status'] == 'resolved').length),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text('Error loading feedback', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(_error!, style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _loadFeedback, child: const Text('Retry')),
                        ],
                      ))
                    : _filtered.isEmpty
                        ? Center(child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: theme.disabledColor),
                              const SizedBox(height: 12),
                              Text('No feedback ${_filterStatus != 'all' ? 'with status "$_filterStatus"' : 'yet'}',
                                  style: theme.textTheme.titleMedium),
                            ],
                          ))
                        : RefreshIndicator(
                            onRefresh: _loadFeedback,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _buildFeedbackCard(_filtered[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String status, int count) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => setState(() { _filterStatus = status; _applyFilter(); }),
      selectedColor: _statusColor(status).withValues(alpha: 0.2),
      checkmarkColor: _statusColor(status),
      labelStyle: TextStyle(color: isSelected ? _statusColor(status) : null, fontWeight: isSelected ? FontWeight.bold : null),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> fb) {
    final theme = Theme.of(context);
    final status = fb['status'] ?? 'new';
    final category = fb['category'] ?? 'general';
    final rating = (fb['rating'] ?? 5) as int;
    final userName = fb['userName'] ?? 'Anonymous';
    final userPhone = fb['userPhone'] ?? '';
    final message = fb['message'] ?? '';
    final createdAt = fb['created_at'] != null
        ? DateFormat('MMM d, yyyy · h:mm a').format(DateTime.parse(fb['created_at']).toLocal())
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: status == 'new' ? 2 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: status == 'new' ? BorderSide(color: Colors.blue.withValues(alpha: 0.3), width: 1) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: user info + status
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _categoryColor(category).withValues(alpha: 0.15),
                  child: Icon(_categoryIcon(category), color: _categoryColor(category), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      if (userPhone.isNotEmpty) Text(userPhone, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _categoryColor(category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(category.toUpperCase(), style: TextStyle(color: _categoryColor(category), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status.toUpperCase(), style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Rating stars
            Row(
              children: [
                ...List.generate(5, (i) => Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: i < rating ? Colors.amber : Colors.grey,
                )),
                const SizedBox(width: 8),
                Text(createdAt, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 10),

            // Message
            Text(message, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),

            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'new')
                  TextButton.icon(
                    onPressed: () => _updateStatus(fb['id'], 'read'),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Mark Read'),
                  ),
                if (status != 'resolved')
                  TextButton.icon(
                    onPressed: () => _updateStatus(fb['id'], 'resolved'),
                    icon: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    label: const Text('Resolve', style: TextStyle(color: Colors.green)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
