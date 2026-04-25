import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _changingPw = false;

  String _roleLabel(String role) {
    switch (role) {
      case 'super_admin': return 'Super Admin';
      case 'admin': return 'Admin';
      case 'moderator': return 'Moderator';
      case 'viewer': return 'Viewer';
      default: return role;
    }
  }

  void _changePassword() async {
    if (_newPwCtrl.text.isEmpty || _currentPwCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_newPwCtrl.text != _confirmPwCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_newPwCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _changingPw = true);
    try {
      await ApiService().changePassword(_currentPwCtrl.text, _newPwCtrl.text);
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Password changed successfully'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      String msg = 'Failed to change password';
      if (e is DioException && e.response?.statusCode == 401) {
        msg = 'Current password is incorrect';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $msg'), backgroundColor: Colors.red),
      );
    }
    if (mounted) setState(() => _changingPw = false);
  }

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final admin = AdminAuthState.currentAdmin ?? {};

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.person, color: theme.colorScheme.primary, size: 36),
            const SizedBox(width: 14),
            Text('My Profile', style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary, fontSize: 32, fontWeight: FontWeight.w900,
            )),
          ]),
          const SizedBox(height: 24),

          // Profile Info Card
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.person, color: Colors.white, size: 48),
                  ),
                  const SizedBox(width: 28),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(admin['username'] ?? 'Unknown', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(admin['email'] ?? 'No email set', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_roleLabel(admin['role'] ?? 'viewer'), style: TextStyle(
                          color: theme.colorScheme.primary, fontWeight: FontWeight.bold,
                        )),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Change Password Card
          Text('Change Password', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: _currentPwCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _newPwCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _confirmPwCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (_) => _changePassword(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _changingPw ? null : _changePassword,
                      icon: _changingPw
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save),
                      label: Text(_changingPw ? 'Updating...' : 'Update Password'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
