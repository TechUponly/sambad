import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../home_page.dart';
import 'privacy_policy_page.dart';
import 'terms_page.dart';
import '../services/chat_service.dart';

const Color kPrimaryBlue = Color(0xFF5B7FFF);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _codeSent = false;
  String _verificationId = '';
  String _countryCode = '+91';
  Timer? _resendTimer;
  int _resendSeconds = 60;
  bool _canResend = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendOTP() async {
    final phone = _countryCode + _phoneController.text.trim();
    if (_phoneController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // For web, we need to handle reCAPTCHA differently
      if (kIsWeb) {
        // Web phone auth with reCAPTCHA
        final confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(
          phone,
        );
        
        setState(() {
          _isLoading = false;
          _codeSent = true;
          _verificationId = confirmationResult.verificationId;
        });
        _startResendTimer();
        // Auto-focus first OTP field
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _otpFocusNodes[0].requestFocus();
        });
      } else {
        // Mobile phone auth
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
            await _saveAndNavigate();
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() {
              _isLoading = false;
              _errorMessage = e.message ?? 'Verification failed';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.message}'), backgroundColor: Colors.red),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _isLoading = false;
              _codeSent = true;
              _verificationId = verificationId;
            });
            _startResendTimer();
            // Auto-focus first OTP field
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _otpFocusNodes[0].requestFocus();
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      // Move to next field immediately
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      _otpFocusNodes[index - 1].requestFocus();
    }
    
    // Check if all fields are filled and auto-submit immediately
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      // Unfocus to hide keyboard
      FocusScope.of(context).unfocus();
      // Verify immediately without delay
      _verifyOTP(otp);
    }
  }

  Future<void> _pasteOtp() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      final text = data!.text!.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.length >= 6) {
        // Fill all fields
        for (int i = 0; i < 6; i++) {
          _otpControllers[i].text = text[i];
        }
        // Unfocus keyboard
        FocusScope.of(context).unfocus();
        // Verify immediately
        _verifyOTP(text.substring(0, 6));
      }
    }
  }

  Future<void> _verifyOTP(String otp) async {
    if (otp.length != 6) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _saveAndNavigate();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid OTP. Please try again.';
      });
      // Clear OTP fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _otpFocusNodes[0].requestFocus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('firebase_token', token ?? '');
      await prefs.setString('current_user_phone', user.phoneNumber ?? '');
      // Also login to backend
      if (mounted) {
        await context.read<ChatService>().loginUser(user.phoneNumber ?? '');
      }
    }
    // Request contacts permission and sync
    await _requestContactsAndSync();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  Future<void> _requestContactsAndSync() async {
    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        final contacts = await FlutterContacts.getContacts(withProperties: true);
        if (mounted) {
          final chatService = context.read<ChatService>();
          for (var contact in contacts) {
            if (contact.phones.isNotEmpty) {
              chatService.addContactLocally(
                id: contact.id,
                name: contact.displayName,
                phone: contact.phones.first.number.replaceAll(RegExp(r'[^0-9+]'), ''),
              );
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error syncing contacts: $e');
    }
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
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: kPrimaryBlue, shape: BoxShape.circle),
                child: const Icon(Icons.chat_bubble, color: Colors.white, size: 40),
              ),
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
                    if (!_codeSent) ...[
                      Row(
                        children: [
                          CountryCodePicker(
                            onChanged: (code) => setState(() => _countryCode = code.dialCode ?? '+91'),
                            initialSelection: 'IN',
                            favorite: const ['+91', 'IN'],
                            textStyle: const TextStyle(color: Colors.white),
                            dialogBackgroundColor: const Color(0xFF23272F),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                              cursorColor: kPrimaryBlue,
                              decoration: InputDecoration(
                                hintText: 'Phone number',
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white10,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryBlue, width: 2)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOTP,
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ] else ...[
                      const Text('Enter OTP', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Sent to $_countryCode${_phoneController.text}', style: const TextStyle(color: Colors.white60)),
                      const SizedBox(height: 24),
                      
                      // Smart OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            height: 56,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _otpFocusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white10,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white24),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red, width: 2),
                                ),
                              ),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (value) => _onOtpChanged(index, value),
                            ),
                          );
                        }),
                      ),
                      
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Paste OTP Button
                      TextButton.icon(
                        onPressed: _pasteOtp,
                        icon: const Icon(Icons.content_paste, size: 18, color: kPrimaryBlue),
                        label: const Text('Paste OTP', style: TextStyle(color: kPrimaryBlue)),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      if (_isLoading)
                        const CircularProgressIndicator(color: kPrimaryBlue)
                      else ...[
                        // Resend OTP
                        if (_canResend)
                          TextButton(
                            onPressed: _sendOTP,
                            child: const Text('Resend OTP', style: TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.w600)),
                          )
                        else
                          Text(
                            'Resend OTP in $_resendSeconds seconds',
                            style: const TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        
                        const SizedBox(height: 8),
                        
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _codeSent = false;
                              _errorMessage = null;
                              for (var controller in _otpControllers) {
                                controller.clear();
                              }
                            });
                            _resendTimer?.cancel();
                          },
                          child: const Text('Change number', style: TextStyle(color: Colors.white60)),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our\n'),
                    TextSpan(
                      text: 'Terms of Service',
                      style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage())),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
