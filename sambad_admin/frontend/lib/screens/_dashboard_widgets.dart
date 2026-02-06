import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const StatCard({required this.title, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black, size: 28),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownFilter extends StatelessWidget {
  final String label;
  const DropdownFilter({required this.label});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: const [
          DropdownMenuItem(value: '', child: Text('All')),
        ],
        onChanged: (v) {},
      ),
    );
  }
}

class UserAnalyticsTile extends StatelessWidget {
  final String username;
  final bool online;
  const UserAnalyticsTile({required this.username, required this.online});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: online ? const Color(0xFFB9F6CA) : const Color(0xFFE1BEE7),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(online ? Icons.circle : Icons.circle_outlined, color: online ? Colors.green : Colors.grey, size: 16),
          const SizedBox(width: 8),
          Text(
            username,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark ? Colors.black : Colors.black,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Hear Microphone',
            onPressed: () {},
            color: theme.brightness == Brightness.dark ? Colors.black : Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            tooltip: 'See through Camera',
            onPressed: () {},
            color: theme.brightness == Brightness.dark ? Colors.black : Colors.black,
          ),
        ],
      ),
    );
  }
}