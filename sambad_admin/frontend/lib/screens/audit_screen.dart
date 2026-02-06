import 'package:flutter/material.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 18),
              Text('Audit Trail', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Audit logs and activity will appear here.', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
