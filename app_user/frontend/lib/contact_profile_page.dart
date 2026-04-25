import 'package:flutter/material.dart';
import 'models/contact.dart';
import 'package:provider/provider.dart';
import 'services/chat_service.dart';
import 'theme/app_colors.dart';
import 'utils/responsive.dart';

/// Read-only profile page for viewing another user's profile.
class ContactProfilePage extends StatelessWidget {
  final Contact contact;

  const ContactProfilePage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final svc = context.watch<ChatService>();
    final isOnline = svc.isOnline(contact.id);
    final initial = contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: c.text),
        title: Text('Contact Info', style: TextStyle(color: c.text, fontSize: Responsive.fontSize(context, 20))),
      ),
      body: SingleChildScrollView(
        padding: Responsive.paddingAll(context, 24),
        child: Column(
          children: [
            SizedBox(height: Responsive.vertical(context, 20)),

            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: Responsive.size(context, 56),
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 44),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.bg, width: 3),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: Responsive.vertical(context, 20)),

            // Name
            Text(
              contact.name,
              style: TextStyle(
                color: c.text,
                fontSize: Responsive.fontSize(context, 26),
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: Responsive.vertical(context, 8)),

            // Online status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isOnline
                    ? Colors.greenAccent.withValues(alpha: 0.2)
                    : c.text.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  color: isOnline ? Colors.greenAccent : c.textMuted,
                  fontSize: Responsive.fontSize(context, 13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: Responsive.vertical(context, 32)),

            // Info cards
            _InfoCard(
              icon: Icons.phone,
              label: 'Phone',
              value: contact.phone.isNotEmpty ? contact.phone : 'Not available',
              colors: c,
              context: context,
            ),

            SizedBox(height: Responsive.vertical(context, 12)),

            _InfoCard(
              icon: Icons.person,
              label: 'Contact Name',
              value: contact.name,
              colors: c,
              context: context,
            ),

            SizedBox(height: Responsive.vertical(context, 32)),

            // Action buttons
            SizedBox(
              width: double.infinity,
              height: Responsive.size(context, 50),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.chat),
                label: Text('Back to Chat', style: TextStyle(fontSize: Responsive.fontSize(context, 16))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppColorSet colors;
  final BuildContext context;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Responsive.paddingAll(context, 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(Responsive.radius(context, 14)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 22),
          ),
          SizedBox(width: Responsive.horizontal(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: Responsive.fontSize(context, 12),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: Responsive.fontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
