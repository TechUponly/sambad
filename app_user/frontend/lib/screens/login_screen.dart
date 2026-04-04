import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '../utils/phone_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ...existing code...
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../home_page.dart';
import 'privacy_policy_page.dart';
import 'terms_page.dart';
import '../services/chat_service.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

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
    final rawPhone = _phoneController.text.trim();
    
    // Validate phone number
    final validationError = PhoneValidator.validate(rawPhone, _countryCode);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    final phone = _countryCode + PhoneValidator.cleanPhone(rawPhone);
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
      if (!mounted) return;
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
        if (!mounted) return;
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
      
      if (!mounted) return;
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
      
      // Extract name: use Firebase displayName, or saved name, or phone number
      String? displayName = user.displayName;
      if (displayName == null || displayName.isEmpty) {
        displayName = prefs.getString('current_user_name');
      }
      if (displayName == null || displayName.isEmpty) {
        // Use a clean phone number as fallback name
        displayName = user.phoneNumber?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
        if (displayName.length > 10) displayName = displayName.substring(displayName.length - 10);
      }
      
      // Login to backend with name
      if (mounted) {
        await context.read<ChatService>().loginUser(
          user.phoneNumber ?? '',
          name: displayName,
        );
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
      debugPrint('[LoginScreen] Error syncing contacts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.paddingAll(context, 24),
          child: Column(
            children: [
              SizedBox(height: Responsive.vertical(context, 60)),
              Container(
                width: Responsive.size(context, 80), height: Responsive.size(context, 80),
                decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                child: Icon(Icons.chat_bubble, color: Colors.white, size: Responsive.size(context, 40)),
              ),
              SizedBox(height: Responsive.vertical(context, 24)),
              Text('Welcome to Samvad', style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 28), fontWeight: FontWeight.bold)),
              SizedBox(height: Responsive.vertical(context, 8)),
              Text('Private & secure messaging', style: TextStyle(color: Colors.white60, fontSize: Responsive.fontSize(context, 16))),
              SizedBox(height: Responsive.vertical(context, 48)),
              Container(
                padding: Responsive.paddingAll(context, 24),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(Responsive.radius(context, 20))),
                child: Column(
                  children: [
                    if (!_codeSent) ...[
                      // Full-width phone number input
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 20), letterSpacing: 2),
                        cursorColor: AppColors.primaryBlue,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(PhoneValidator.getExpectedDigits(_countryCode)),
                        ],
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          hintStyle: TextStyle(color: Colors.white30, fontSize: Responsive.fontSize(context, 18), letterSpacing: 0),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          prefixIcon: GestureDetector(
                            onTap: () async {
                              final codes = ['+91', '+1', '+44', '+61', '+86', '+81', '+49', '+33', '+971', '+92', '+880', '+65'];
                              final selected = await showDialog<String>(
                                context: context,
                                builder: (ctx) => SimpleDialog(
                                  backgroundColor: AppColors.bgCard,
                                  title: Text('Select Country Code', style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 18))),
                                  children: codes.map((c) => SimpleDialogOption(
                                    onPressed: () => Navigator.pop(ctx, c),
                                    child: Text(c, style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 16))),
                                  )).toList(),
                                ),
                              );
                              if (selected != null) setState(() => _countryCode = selected);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: Responsive.horizontal(context, 12)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_countryCode, style: TextStyle(color: AppColors.primaryBlue, fontSize: Responsive.fontSize(context, 18), fontWeight: FontWeight.bold)),
                                  Icon(Icons.arrow_drop_down, color: Colors.white54, size: Responsive.size(context, 20)),
                                ],
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 14)), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 14)), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
                          contentPadding: Responsive.paddingSymmetric(context, h: 16, v: 18),
                        ),
                      ),
                      SizedBox(height: Responsive.vertical(context, 6)),
                      // Digit count helper
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_phoneController.text.length}/${PhoneValidator.getExpectedDigits(_countryCode)} digits',
                          style: TextStyle(color: Colors.white38, fontSize: Responsive.fontSize(context, 12)),
                        ),
                      ),
                      SizedBox(height: Responsive.vertical(context, 24)),
                      SizedBox(
                        width: double.infinity, height: Responsive.size(context, 56),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOTP,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 16)))),
                          child: _isLoading
                              ? SizedBox(width: Responsive.size(context, 24), height: Responsive.size(context, 24), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('Send OTP', style: TextStyle(fontSize: Responsive.fontSize(context, 16), fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ] else ...[
                      Text('Enter OTP', style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 20), fontWeight: FontWeight.bold)),
                      SizedBox(height: Responsive.vertical(context, 8)),
                      Text('Sent to $_countryCode${_phoneController.text}', style: TextStyle(color: Colors.white60, fontSize: Responsive.fontSize(context, 14))),
                      SizedBox(height: Responsive.vertical(context, 24)),
                      
                      // Smart OTP Input Fields — responsive width
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final fieldWidth = (constraints.maxWidth - 5 * 8) / 6; // 6 fields, 5 gaps of 8px
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: fieldWidth.clamp(36, 56),
                                height: Responsive.size(context, 56),
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _otpFocusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 20), fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: Colors.white10,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                                      borderSide: const BorderSide(color: Colors.white24),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                                      borderSide: const BorderSide(color: Colors.white24),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                                      borderSide: const BorderSide(color: Colors.red, width: 2),
                                    ),
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) => _onOtpChanged(index, value),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      
                      if (_errorMessage != null) ...[
                        SizedBox(height: Responsive.vertical(context, 12)),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: Responsive.fontSize(context, 14)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      
                      SizedBox(height: Responsive.vertical(context, 16)),
                      
                      // Paste OTP Button
                      TextButton.icon(
                        onPressed: _pasteOtp,
                        icon: Icon(Icons.content_paste, size: Responsive.size(context, 18), color: AppColors.primaryBlue),
                        label: Text('Paste OTP', style: TextStyle(color: AppColors.primaryBlue, fontSize: Responsive.fontSize(context, 14))),
                      ),
                      
                      SizedBox(height: Responsive.vertical(context, 8)),
                      
                      if (_isLoading)
                        const CircularProgressIndicator(color: AppColors.primaryBlue)
                      else ...[
                        // Resend OTP
                        if (_canResend)
                          TextButton(
                            onPressed: _sendOTP,
                            child: Text('Resend OTP', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: Responsive.fontSize(context, 14))),
                          )
                        else
                          Text(
                            'Resend OTP in $_resendSeconds seconds',
                            style: TextStyle(color: Colors.white54, fontSize: Responsive.fontSize(context, 14)),
                          ),
                        
                        SizedBox(height: Responsive.vertical(context, 8)),
                        
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
                          child: Text('Change number', style: TextStyle(color: Colors.white60, fontSize: Responsive.fontSize(context, 14))),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              SizedBox(height: Responsive.vertical(context, 32)),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.white54, fontSize: Responsive.fontSize(context, 12)),
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our\n'),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: Responsive.fontSize(context, 12), decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage())),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: Responsive.fontSize(context, 12), decoration: TextDecoration.underline),
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
