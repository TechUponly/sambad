import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const Color kPrimaryBlue = Color(0xFF5B7FFF);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;
  String _selectedCountryCode = '+91';

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(Uri.parse('http://10.0.2.2:3000/send-otp'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'phone': '$_selectedCountryCode${_phoneController.text}'}));
      setState(() => _isLoading = false);
      if (response.statusCode == 200) setState(() => _isOtpSent = true);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(Uri.parse('http://10.0.2.2:3000/verify-otp'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'phone': '$_selectedCountryCode${_phoneController.text}', 'otp': _otpController.text}));
      setState(() => _isLoading = false);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', data['token']);
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: kPrimaryBlue, shape: BoxShape.circle, boxShadow: [BoxShadow(color: kPrimaryBlue.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)]), child: const Icon(Icons.lock, size: 64, color: Colors.white)),
                const SizedBox(height: 32),
                const Text('Private Sambad', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Secure Chat Login', style: TextStyle(color: Colors.white60, fontSize: 16)),
                const SizedBox(height: 48),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF23272F), borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                            child: Center(child: Text(_selectedCountryCode, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                              cursorColor: kPrimaryBlue,
                              decoration: InputDecoration(
                                hintText: 'Mobile number',
                                hintStyle: const TextStyle(color: Colors.white54),
                                prefixIcon: const Icon(Icons.phone, color: kPrimaryBlue),
                                filled: true,
                                fillColor: Colors.white10,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryBlue, width: 2)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_isOtpSent) ...[
                        const SizedBox(height: 20),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          cursorColor: kPrimaryBlue,
                          decoration: InputDecoration(
                            hintText: 'Enter OTP',
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.lock_outline, color: kPrimaryBlue),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryBlue, width: 2)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp), style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_isOtpSent ? 'Verify & Login' : 'Continue', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('or', style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 56, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.g_mobiledata, size: 28), label: const Text('Sign in with Google'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 56, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.apple, size: 28), label: const Text('Sign in with Apple'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                const SizedBox(height: 32),
                const Text('By continuing, you agree to the Privacy Policy.', style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
