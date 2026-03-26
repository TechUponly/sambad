import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'services/chat_service.dart';
import 'screens/login_screen.dart';
import 'theme/app_colors.dart';
import 'utils/responsive.dart';

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
    setState(() {
      _nameController.text = prefs.getString('profile_name') ?? 'User';
      _ageController.text = prefs.getString('profile_age') ?? '';
      _gender = prefs.getString('profile_gender') ?? 'Male';
      _profilePicPath = prefs.getString('profile_pic');
    });
  }

  Future<void> _pickProfilePic() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profilePicPath = picked.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_pic', picked.path);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    final name = _nameController.text.trim();
    await prefs.setString('profile_name', name);
    await prefs.setString('current_user_name', name);
    await prefs.setString('profile_age', _ageController.text.trim());
    await prefs.setString('profile_gender', _gender ?? '');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved!'), backgroundColor: AppColors.primaryBlue),
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
      body: Padding(
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
              SizedBox(height: Responsive.vertical(context, 30)),
              TextField(
                controller: _nameController,
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
              TextField(
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
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12)))),
                  child: Text('Save Profile', style: TextStyle(fontSize: Responsive.fontSize(context, 16))),
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
              const Spacer(),
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12)))),
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
