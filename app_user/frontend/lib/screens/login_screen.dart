import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'privacy_policy_page.dart';
import 'terms_page.dart';
import '../home_page.dart';

const Color kPrimaryBlue = Color(0xFF5B7FFF);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _continue() async {
    if (_phoneController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(width: 80, height: 80, decoration: BoxDecoration(color: kPrimaryBlue, shape: BoxShape.circle), child: const Icon(Icons.chat_bubble, color: Colors.white, size: 40)),
              const SizedBox(height: 24),
              const Text('Welcome to Sambad', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Private & secure messaging', style: TextStyle(color: Colors.white60, fontSize: 16)),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFF23272F), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(width: 70, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)), child: const Text('+91', style: TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center)),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: _phoneController, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white, fontSize: 18), cursorColor: kPrimaryBlue, decoration: InputDecoration(hintText: 'Phone number', hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryBlue, width: 2))))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _isLoading ? null : _continue, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              RichText(textAlign: TextAlign.center, text: TextSpan(style: const TextStyle(color: Colors.white54, fontSize: 12), children: [const TextSpan(text: 'By continuing, you agree to our\n'), TextSpan(text: 'Terms of Service', style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.w600, decoration: TextDecoration.underline), recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage()))), const TextSpan(text: ' and '), TextSpan(text: 'Privacy Policy', style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.w600, decoration: TextDecoration.underline), recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())))])),
            ],
          ),
        ),
      ),
    );
  }
}
