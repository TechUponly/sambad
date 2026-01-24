import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF5B7FFF);
const Color kBgDark = Color(0xFF181A20);

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Text('We collect your phone number for authentication and contacts (with your permission) to help you connect with friends on Sambad.', style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
            SizedBox(height: 16),
            Text('Your messages are end-to-end encrypted. We never sell or share your personal data with third parties.', style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
            SizedBox(height: 16),
            Text('You can delete your account and all data at any time from Settings.', style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
