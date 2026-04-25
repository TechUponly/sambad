import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.card,
        title: Text('Terms of Service', style: TextStyle(color: c.text)),
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
            Text('Terms of Service', style: TextStyle(color: c.text, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text('By using Samvad, you agree not to use the app for illegal activities. We may suspend accounts that violate terms.', style: TextStyle(color: c.textSecondary, fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
