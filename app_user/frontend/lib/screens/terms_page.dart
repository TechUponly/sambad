import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF5B7FFF);
const Color kBgDark = Color(0xFF181A20);

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Terms of Service', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms of Service', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Text('By using Sambad, you agree not to use the app for illegal activities. We may suspend accounts that violate terms.', style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
