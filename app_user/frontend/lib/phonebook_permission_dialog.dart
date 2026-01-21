import 'package:flutter/material.dart';

class PhonebookPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;
  const PhonebookPermissionDialog({super.key, required this.onAllow, required this.onDeny});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF23272F), Color(0xFF18181B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Color(0xFF00FFC2).withOpacity(0.18), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phonebook Access', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Montserrat')),
            const SizedBox(height: 18),
            const Text(
              'To extract contacts, the app needs access to your phone book. This is only used to add friends and is not stored or shared.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDeny,
                  style: TextButton.styleFrom(foregroundColor: Colors.white70, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  child: const Text('Deny'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onAllow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFC2),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    elevation: 6,
                    shadowColor: const Color(0xFF00FFC2).withOpacity(0.18),
                  ),
                  child: const Text('Allow'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
