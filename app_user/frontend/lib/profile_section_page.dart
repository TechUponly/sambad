import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'services/chat_service.dart';
import 'screens/login_screen.dart';
import 'theme/app_colors.dart';
import 'utils/responsive.dart';
import 'config/app_config.dart';

class ProfileSectionPage extends StatefulWidget {
  const ProfileSectionPage({super.key});

  @override
  State<ProfileSectionPage> createState() => _ProfileSectionPageState();
}

class _ProfileSectionPageState extends State<ProfileSectionPage> {
  String? _profilePicPath;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _gender;
  bool _saving = false;
  String? _phone;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('current_user_id');
    _phone = prefs.getString('current_user_phone');

    // Load local first
    setState(() {
      _nameController.text = prefs.getString('profile_name') ?? prefs.getString('current_user_name') ?? '';
      _ageController.text = prefs.getString('profile_age') ?? '';
      _gender = prefs.getString('profile_gender') ?? 'Male';
      _profilePicPath = prefs.getString('profile_pic');
    });

    // Then try to fetch from server to get latest
    if (_userId != null && _userId!.isNotEmpty) {
      try {
        final headers = await _authHeaders();
        final resp = await http.get(
          Uri.parse('${AppConfig.apiBase}/users/$_userId'),
          headers: headers,
        );
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          if (mounted) {
            setState(() {
              if (data['name'] != null && data['name'].toString().isNotEmpty) {
                _nameController.text = data['name'];
              }
              if (data['age'] != null && data['age'].toString().isNotEmpty) {
                _ageController.text = data['age'];
              }
              if (data['gender'] != null && data['gender'].toString().isNotEmpty) {
                _gender = data['gender'];
              }
            });
            // Save server data locally
            await prefs.setString('profile_name', _nameController.text);
            await prefs.setString('current_user_name', _nameController.text);
            if (_ageController.text.isNotEmpty) await prefs.setString('profile_age', _ageController.text);
            if (_gender != null) await prefs.setString('profile_gender', _gender!);
          }
        }
      } catch (e) {
        debugPrint('[Profile] Failed to fetch from server: $e');
      }
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('firebase_token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _pickProfilePic() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _profilePicPath = picked.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_pic', picked.path);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final age = _ageController.text.trim();

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', name);
    await prefs.setString('current_user_name', name);
    await prefs.setString('profile_age', age);
    await prefs.setString('profile_gender', _gender ?? '');

    // Sync to backend
    if (_userId != null && _userId!.isNotEmpty) {
      try {
        final headers = await _authHeaders();
        final resp = await http.put(
          Uri.parse('${AppConfig.apiBase}/users/$_userId'),
          headers: headers,
          body: jsonEncode({
            'name': name,
            'age': age,
            'gender': _gender ?? '',
          }),
        );
        if (resp.statusCode == 200) {
          debugPrint('[Profile] Synced to server ✅');
        } else {
          debugPrint('[Profile] Server sync failed: ${resp.statusCode}');
        }
      } catch (e) {
        debugPrint('[Profile] Server sync error: $e');
      }
    }

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Profile saved!'), backgroundColor: AppColors.primaryBlue),
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Delete Account?', style: TextStyle(color: Colors.white)),
        content: const Text('This will delete all your data permanently.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    await context.read<ChatService>().purgePrivateMessages();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    await context.read<ChatService>().purgePrivateMessages();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 20))),
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.bgDark,
      body: SingleChildScrollView(
        padding: Responsive.paddingAll(context, 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickProfilePic,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: Responsive.size(context, 50),
                      backgroundColor: AppColors.primaryBlue,
                      backgroundImage: _profilePicPath != null ? FileImage(File(_profilePicPath!)) : null,
                      child: _profilePicPath == null
                          ? Text(_nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U', style: TextStyle(fontSize: Responsive.fontSize(context, 40), color: Colors.white))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: Responsive.paddingAll(context, 6),
                        decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                        child: Icon(Icons.camera_alt, size: Responsive.size(context, 16), color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.vertical(context, 12)),
              // Phone number display (read-only)
              if (_phone != null)
                Text(_phone!, style: TextStyle(color: Colors.white54, fontSize: Responsive.fontSize(context, 14))),
              SizedBox(height: Responsive.vertical(context, 24)),
              TextFormField(
                controller: _nameController,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.person, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: AppColors.bgCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12)), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: Responsive.vertical(context, 16)),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Age',
                  labelStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.cake, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: AppColors.bgCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12)), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: Responsive.vertical(context, 16)),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                dropdownColor: AppColors.bgCard,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Gender',
                  labelStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(Icons.wc, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: AppColors.bgCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12)), borderSide: BorderSide.none),
                ),
                items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _gender = v),
              ),
              SizedBox(height: Responsive.vertical(context, 24)),
              SizedBox(
                width: double.infinity,
                height: Responsive.size(context, 50),
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveProfile,
                  icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Save Profile', style: TextStyle(fontSize: Responsive.fontSize(context, 16))),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12)))),
                ),
              ),
              SizedBox(height: Responsive.vertical(context, 16)),
              SizedBox(
                width: double.infinity,
                height: Responsive.size(context, 50),
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.bgCard,
                        title: const Text('Privacy & Security', style: TextStyle(color: Colors.white)),
                        content: const Text(
                          'Your chats are end-to-end encrypted. Only you and your contacts can read your messages. We do not store your messages on our servers.',
                          style: TextStyle(color: Colors.white70, height: 1.5),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Got it', style: TextStyle(color: AppColors.primaryBlue)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.security, color: AppColors.primaryBlue),
                  label: Text('Privacy & Security', style: TextStyle(fontSize: Responsive.fontSize(context, 16), color: AppColors.primaryBlue)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12))),
                  ),
                ),
              ),
              SizedBox(height: Responsive.vertical(context, 24)),
              SizedBox(
                width: double.infinity,
                height: Responsive.size(context, 50),
                child: OutlinedButton(
                  onPressed: _signOut,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12))),
                  ),
                  child: Text('Sign Out', style: TextStyle(fontSize: Responsive.fontSize(context, 16), color: AppColors.primaryBlue)),
                ),
              ),
              SizedBox(height: Responsive.vertical(context, 12)),
              SizedBox(
                width: double.infinity,
                height: Responsive.size(context, 50),
                child: ElevatedButton(
                  onPressed: _deleteAccount,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12)))),
                  child: Text('Delete Account', style: TextStyle(fontSize: Responsive.fontSize(context, 16), color: Colors.white)),
                ),
              ),
              SizedBox(height: Responsive.vertical(context, 20)),
            ],
          ),
        ),
      ),
    );
  }
}
