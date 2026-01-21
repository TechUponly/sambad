import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF18181B), Color(0xFF23272F), Color(0xFF00FFC2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Color(0xFF00FFC2), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48, color: Color(0xFF00FFC2)),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    labelStyle: const TextStyle(color: Color(0xFF00FFC2)),
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFF7C3AED)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF00FFC2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFC2),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    elevation: 8,
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
