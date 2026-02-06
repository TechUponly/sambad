import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dashboard_screen.dart';


class AdminLoginPage extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final bool? isDark;
  const AdminLoginPage({Key? key, this.onThemeToggle, this.isDark}) : super(key: key);
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  // Real SHA-256 hashes for '7718811069' and 'Taksh@060921'
  static const String _userHash = 'f89c3fd145fddc2ea99723b9fc72866dffde05cd4a2fda7a855dc3f5f38d4c15';
  static const String _passHash = 'fd661efb2da05d9b281038591a1a4c8292663fdcfe7eeeb85e5b66eec4b83958';

  String _sha256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  void _login() async {
    setState(() { _isLoading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 500));
    final userInput = _usernameController.text.trim();
    final passInput = _passwordController.text;
    final userHash = _sha256(userInput);
    final passHash = _sha256(passInput);
    print('Entered username: ' + userInput);
    print('Entered password: ' + passInput);
    print('Username hash: ' + userHash);
    print('Password hash: ' + passHash);
    print('Expected username hash: ' + _userHash);
    print('Expected password hash: ' + _passHash);
    if (userHash == _userHash && passHash == _passHash) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminDashboardPage(),
        ),
      );
    } else {
      setState(() { _error = 'Invalid credentials'; });
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(widget.isDark == true ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Welcome Admin', style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: TextStyle(color: Colors.redAccent.withOpacity(0.7))),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.deepPurpleAccent,
                        elevation: 4,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
