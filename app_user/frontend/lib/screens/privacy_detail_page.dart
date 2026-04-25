import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

class PrivacyDetailPage extends StatelessWidget {
  const PrivacyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('Privacy & Security', style: TextStyle(color: c.text, fontSize: Responsive.fontSize(context, 20))),
        backgroundColor: c.card,
        elevation: 0,
        iconTheme: IconThemeData(color: c.text),
      ),
      body: SingleChildScrollView(
        padding: Responsive.paddingAll(context, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: Responsive.paddingAll(context, 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
              ),
              child: Column(
                children: [
                  Icon(Icons.shield, size: Responsive.size(context, 48), color: Colors.white),
                  SizedBox(height: Responsive.vertical(context, 12)),
                  Text(
                    'Your Privacy is Our Priority',
                    style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 20), fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.vertical(context, 8)),
                  Text(
                    'Private Samvad is built from the ground up with security and privacy at its core.',
                    style: TextStyle(color: Colors.white70, fontSize: Responsive.fontSize(context, 14)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.vertical(context, 24)),

            _buildFeatureCard(context, c,
              icon: Icons.lock,
              color: Colors.blue,
              title: 'End-to-End Encryption',
              description: 'All messages are encrypted using AES-256-GCM, one of the strongest encryption standards available. Only you and your recipient can read the messages — not even our servers can decrypt them.',
            ),

            _buildFeatureCard(context, c,
              icon: Icons.no_photography,
              color: Colors.red,
              title: 'Screenshot Protection',
              description: 'Screenshots are completely blocked within the app. This prevents anyone from capturing your private conversations, protecting your messages from being saved or shared without your knowledge.',
            ),

            _buildFeatureCard(context, c,
              icon: Icons.block,
              color: Colors.orange,
              title: 'No Message Sharing',
              description: 'Messages cannot be forwarded, copied, or shared to other apps. Your conversations stay exactly where they belong — between you and your contact.',
            ),

            _buildFeatureCard(context, c,
              icon: Icons.timer,
              color: Colors.purple,
              title: 'Auto-Delete Messages',
              description: 'Private chat messages are automatically deleted after 30 minutes of inactivity. This ensures your sensitive conversations don\'t linger on any device.',
            ),

            _buildFeatureCard(context, c,
              icon: Icons.cloud_off,
              color: Colors.teal,
              title: 'No Server Storage',
              description: 'We do not store your messages on our servers. Messages are delivered in real-time through secure WebSocket connections and exist only on the sender and receiver devices.',
            ),

            _buildFeatureCard(context, c,
              icon: Icons.person_off,
              color: Colors.indigo,
              title: 'Block & Report',
              description: 'You can block any contact at any time. Blocked users cannot send you messages or see your online status. You have full control over who can reach you.',
            ),

            _buildFeatureCard(context, c,
              icon: Icons.visibility_off,
              color: Colors.grey,
              title: 'Online Status Control',
              description: 'You can hide your online status from other users in Settings. When disabled, nobody can see whether you are currently active or offline.',
            ),

            _buildFeatureCard(context, c,
              icon: Icons.delete_forever,
              color: Colors.red.shade700,
              title: 'Data Deletion',
              description: 'You can delete your entire account and all associated data at any time from your Profile. We don\'t retain any data after deletion.',
            ),

            SizedBox(height: Responsive.vertical(context, 16)),

            // Footer
            Container(
              width: double.infinity,
              padding: Responsive.paddingAll(context, 16),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                border: Border.all(color: c.textHint.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text('Have concerns?', style: TextStyle(color: c.text, fontWeight: FontWeight.bold, fontSize: Responsive.fontSize(context, 16))),
                  SizedBox(height: Responsive.vertical(context, 8)),
                  Text(
                    'Contact us at support@uponlytech.com\nWe take your privacy seriously.',
                    style: TextStyle(color: c.textMuted, fontSize: Responsive.fontSize(context, 14)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.vertical(context, 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, AppColorSet c, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.vertical(context, 12)),
      padding: Responsive.paddingAll(context, 16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: Responsive.paddingAll(context, 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Responsive.radius(context, 10)),
            ),
            child: Icon(icon, color: color, size: Responsive.size(context, 24)),
          ),
          SizedBox(width: Responsive.horizontal(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: c.text, fontSize: Responsive.fontSize(context, 16), fontWeight: FontWeight.w600)),
                SizedBox(height: Responsive.vertical(context, 6)),
                Text(description, style: TextStyle(color: c.textSecondary, fontSize: Responsive.fontSize(context, 13), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
