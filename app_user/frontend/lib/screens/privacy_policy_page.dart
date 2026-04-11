import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        title: Text('Privacy Policy', style: TextStyle(color: c.text)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: TextStyle(color: c.text, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text('We collect your phone number for authentication and contacts (with your permission) to help you connect with friends on Samvad.', style: TextStyle(color: c.textSecondary, fontSize: 15, height: 1.5)),
            const SizedBox(height: 16),
            Text('Your messages are end-to-end encrypted. We never sell or share your personal data with third parties.', style: TextStyle(color: c.textSecondary, fontSize: 15, height: 1.5)),
            const SizedBox(height: 16),
            Text('You can delete your account and all data at any time from Settings.', style: TextStyle(color: c.textSecondary, fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
