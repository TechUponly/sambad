import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/chat_service.dart';
import 'widgets/contact_tile.dart';
import 'chat_page.dart';
import 'ai_bot_chat_page.dart';
import 'add_contact_dialog.dart';
import 'profile_section_page.dart';
import 'create_group_dialog.dart';
import 'screens/login_screen.dart';
import 'theme/app_colors.dart';
import 'utils/responsive.dart';
import 'services/contacts_sync_service.dart';
import 'services/theme_provider.dart';
import 'screens/privacy_detail_page.dart';
import 'config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String? _profileName;
  late AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _loadProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('current_user_name') ?? 
                 prefs.getString('profile_name') ?? 
                 'User';
    if (mounted) setState(() => _profileName = name);
  }

  void _createGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const CreateGroupDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _buildBody()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.bgCard,
      elevation: 0,
      leadingWidth: Responsive.size(context, 56),
      leading: IconButton(
        icon: CircleAvatar(
          radius: Responsive.size(context, 18),
          backgroundColor: AppColors.avatarColor(_profileName ?? 'U'),
          child: Text(_profileName?.substring(0, 1).toUpperCase() ?? 'U', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.fontSize(context, 14))),
        ),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSectionPage()));
          _loadProfile(); // Refresh name after returning from profile
        },
      ),
      title: SizedBox(
        height: Responsive.size(context, 40),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 14)),
          decoration: InputDecoration(
            hintText: 'Search contacts...',
            hintStyle: TextStyle(color: Colors.white54, fontSize: Responsive.fontSize(context, 14)),
            filled: true,
            fillColor: Colors.white10,
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: Responsive.horizontal(context, 12)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 24)), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 24)), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
            prefixIcon: Icon(Icons.search, color: Colors.white54, size: Responsive.size(context, 20)),
            suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.clear, color: Colors.white54, size: Responsive.size(context, 18)), onPressed: () { setState(() { _searchQuery = ''; _searchController.clear(); }); _searchFocus.unfocus(); }) : null,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildChatsTab();
      case 1: return _buildGroupsTab();
      case 2: return _buildAIBotTab();
      case 3: return _buildSettingsTab();
      default: return _buildChatsTab();
    }
  }

  Widget _buildChatsTab() {
    return Consumer<ChatService>(
      builder: (context, chatService, _) {
        final allContacts = chatService.contacts
            .where((c) => !chatService.blockedContacts.contains(c.id))
            .toList();
        final filteredContacts = _searchQuery.isEmpty ? allContacts : allContacts.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()) || c.phone.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        return Column(
          children: [
            Container(
              margin: Responsive.paddingAll(context, 16),
              padding: Responsive.paddingAll(context, 20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
                boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Expanded(child: Text('Private Samvad welcomes you!', style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 18), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            Container(
              margin: Responsive.paddingSymmetric(context, h: 16),
              padding: Responsive.paddingAll(context, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primaryBlue.withValues(alpha: 0.2), AppColors.primaryBlue.withValues(alpha: 0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(Responsive.radius(context, 20)),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(icon: Icons.person_add_outlined, label: 'Add Contact', onTap: () { showDialog(context: context, builder: (ctx) => AddContactDialog(onAdd: (contact) async { final svc = context.read<ChatService>(); await svc.addContact(contact); })); }),
                  _buildActionButton(icon: Icons.group_add_outlined, label: 'New Group', onTap: () => _createGroup(context)),
                  _buildActionButton(icon: Icons.share_outlined, label: 'Invite Friends', onTap: () async {
                    try {
                      final chatService = context.read<ChatService>();
                      await Share.share(chatService.inviteText);
                    } catch (_) {}
                  }),
                ],
              ),
            ),
            SizedBox(height: Responsive.vertical(context, 16)),
            if (allContacts.isEmpty) _buildEmptyState() else Expanded(child: ListView.builder(padding: Responsive.paddingSymmetric(context, h: 12), itemCount: filteredContacts.length, itemBuilder: (context, index) { final contact = filteredContacts[index]; return Container(margin: EdgeInsets.symmetric(vertical: Responsive.vertical(context, 4)), decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(Responsive.radius(context, 12))), child: ContactTile(contact: contact, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(name: contact.name, isPrivate: true, contact: contact))); }, unreadCount: 0)); })),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
          splashColor: AppColors.primaryBlue.withValues(alpha: 0.3),
          highlightColor: AppColors.primaryBlue.withValues(alpha: 0.2),
          child: Container(
            padding: Responsive.paddingSymmetric(context, v: 16, h: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(Responsive.radius(context, 12))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: Responsive.size(context, 28)),
                SizedBox(height: Responsive.vertical(context, 6)),
                Text(label, style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 12), fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: Responsive.paddingAll(context, 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: Responsive.paddingAll(context, 24), decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(Icons.chat_bubble_outline, size: Responsive.size(context, 64), color: AppColors.primaryBlue)),
              SizedBox(height: Responsive.vertical(context, 24)),
              Text('No chats yet', style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 24), fontWeight: FontWeight.bold)),
              SizedBox(height: Responsive.vertical(context, 12)),
              Text('Start a conversation by adding a contact', style: TextStyle(color: Colors.white60, fontSize: Responsive.fontSize(context, 16)), textAlign: TextAlign.center),
              SizedBox(height: Responsive.vertical(context, 32)),
              ElevatedButton.icon(
                onPressed: () { showDialog(context: context, builder: (ctx) => AddContactDialog(onAdd: (contact) async { final svc = context.read<ChatService>(); await svc.addContact(contact); })); },
                icon: const Icon(Icons.person_add),
                label: const Text('Add Your First Contact'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, padding: Responsive.paddingSymmetric(context, h: 24, v: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12)))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    return Consumer<ChatService>(builder: (context, chatService, _) {
      final groups = chatService.groups.where((g) => !chatService.blockedGroups.contains(g)).toList();
      if (groups.isEmpty) {
        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.groups, size: Responsive.size(context, 64), color: Colors.white54),
          SizedBox(height: Responsive.vertical(context, 16)),
          Text('No groups yet', style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 24), fontWeight: FontWeight.bold)),
          SizedBox(height: Responsive.vertical(context, 12)),
          Text('Create a group to chat with multiple people', style: TextStyle(color: Colors.white60, fontSize: Responsive.fontSize(context, 16))),
          SizedBox(height: Responsive.vertical(context, 24)),
          ElevatedButton.icon(
            onPressed: () => _createGroup(context),
            icon: const Icon(Icons.group_add),
            label: const Text('Create Group'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, padding: Responsive.paddingSymmetric(context, h: 24, v: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12)))),
          ),
        ]));
      }
      return ListView.builder(
        padding: Responsive.paddingAll(context, 16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return Container(
            margin: EdgeInsets.only(bottom: Responsive.vertical(context, 8)),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(Responsive.radius(context, 12))),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2), child: const Icon(Icons.group, color: AppColors.primaryBlue)),
              title: Text(group, style: const TextStyle(color: Colors.white)),
              subtitle: Text('Tap to open', style: TextStyle(color: Colors.white60, fontSize: Responsive.fontSize(context, 14))),
              onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(name: group, isPrivate: false))); },
            ),
          );
        },
      );
    });
  }

  Widget _buildAIBotTab() {
    return const AIBotChatPage();
  }

  Widget _buildSettingsTab() {
    final c = AppColors.of(context);
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final prefs = snapshot.data!;
        bool notifEnabled = prefs.getBool('notifications_enabled') ?? true;
        bool contactsSynced = prefs.getBool('contacts_synced') ?? false;
        bool showOnline = prefs.getBool('show_online_status') ?? true;

        return StatefulBuilder(
          builder: (context, setInnerState) {
            final themeProvider = context.watch<ThemeProvider>();

            return ListView(
              padding: Responsive.paddingAll(context, 16),
              children: [
                // ── Account ──
                _settingsHeader('Account'),
                _settingsTile(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: _profileName ?? 'Edit your profile',
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSectionPage()));
                    _loadProfile();
                  },
                ),

                SizedBox(height: Responsive.vertical(context, 16)),

                // ── Contacts ──
                _settingsHeader('Contacts'),
                _settingsTile(
                  icon: Icons.contacts_outlined,
                  title: 'Sync Phone Contacts',
                  subtitle: contactsSynced ? 'Contacts synced ✅' : 'Find friends on Samvad',
                  onTap: () async {
                    try {
                      final hasPermission = await ContactsSyncService.requestContactsPermission();
                      if (!hasPermission) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contact permission denied'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Syncing contacts...'), backgroundColor: AppColors.primaryBlue, duration: Duration(seconds: 1)),
                      );
                      final result = await ContactsSyncService.syncContacts();
                      if (!context.mounted) return;
                      if (result['success'] == true) {
                        setInnerState(() => contactsSynced = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✅ Synced ${result['totalContacts']} contacts'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),

                SizedBox(height: Responsive.vertical(context, 16)),

                // ── Preferences ──
                _settingsHeader('Preferences'),
                _settingsTile(
                  icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  title: 'Dark Mode',
                  subtitle: themeProvider.isDarkMode ? 'Dark theme active' : 'Light theme active',
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (val) => themeProvider.setDarkMode(val),
                    activeThumbColor: AppColors.primaryBlue,
                  ),
                ),
                _settingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: notifEnabled ? 'Notifications enabled' : 'Notifications disabled',
                  trailing: Switch(
                    value: notifEnabled,
                    onChanged: (val) async {
                      await prefs.setBool('notifications_enabled', val);
                      setInnerState(() => notifEnabled = val);
                    },
                    activeThumbColor: AppColors.primaryBlue,
                  ),
                ),
                _settingsTile(
                  icon: Icons.visibility,
                  title: 'Show Online Status',
                  subtitle: showOnline ? 'Others can see when you\'re online' : 'Your online status is hidden',
                  trailing: Switch(
                    value: showOnline,
                    onChanged: (val) async {
                      await prefs.setBool('show_online_status', val);
                      setInnerState(() => showOnline = val);
                    },
                    activeThumbColor: AppColors.primaryBlue,
                  ),
                ),
                _settingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('More languages coming soon!'), backgroundColor: AppColors.primaryBlue),
                    );
                  },
                ),

                SizedBox(height: Responsive.vertical(context, 16)),

                // ── Privacy & Security ──
                _settingsHeader('Privacy & Security'),
                _settingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'How we protect your data',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyDetailPage()));
                  },
                ),
                _settingsTile(
                  icon: Icons.block,
                  title: 'Blocked Contacts',
                  subtitle: 'Manage blocked users',
                  onTap: () {
                    final chatService = context.read<ChatService>();
                    final blocked = chatService.blockedContacts;
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: c.card,
                        title: Text('Blocked Contacts', style: TextStyle(color: c.text)),
                        content: blocked.isEmpty
                            ? Text('No blocked contacts', style: TextStyle(color: c.textMuted))
                            : SizedBox(
                                width: double.maxFinite,
                                height: 200,
                                child: ListView.builder(
                                  itemCount: blocked.length,
                                  itemBuilder: (_, i) => ListTile(
                                    title: Text(blocked[i], style: TextStyle(color: c.text)),
                                    trailing: TextButton(
                                      onPressed: () {
                                        chatService.unblockContact(blocked[i]);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Unblock', style: TextStyle(color: AppColors.primaryBlue)),
                                    ),
                                  ),
                                ),
                              ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close', style: TextStyle(color: AppColors.primaryBlue)),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: Responsive.vertical(context, 16)),

                // ── Feedback ──
                _settingsHeader('Feedback'),
                _settingsTile(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Help us improve Private Samvad',
                  onTap: () => _showFeedbackDialog(context, c),
                ),

                SizedBox(height: Responsive.vertical(context, 16)),

                // ── About ──
                _settingsHeader('About'),
                _settingsTile(
                  icon: Icons.info_outline,
                  title: 'About Private Samvad',
                  subtitle: 'Version 1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Private Samvad',
                      applicationVersion: '1.0.0',
                      applicationIcon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.lock, color: Colors.white, size: 32),
                      ),
                      children: [const Text('A secure, private messaging app with end-to-end encryption.')],
                    );
                  },
                ),
                _settingsTile(
                  icon: Icons.description_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: Text('Privacy Policy', style: TextStyle(color: c.text)), backgroundColor: c.card, iconTheme: IconThemeData(color: c.text)),
                        backgroundColor: c.bg,
                        body: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Private Samvad respects your privacy.\n\n'
                            '• Messages are end-to-end encrypted\n'
                            '• We do not read or store your messages\n'
                            '• Private conversations auto-delete\n'
                            '• Your data is never shared with third parties\n'
                            '• You can delete your account at any time\n\n'
                            'For questions, contact us at support@uponlytech.com',
                            style: TextStyle(color: c.textSecondary, fontSize: 16, height: 1.6),
                          ),
                        ),
                      ),
                    ));
                  },
                ),

                SizedBox(height: Responsive.vertical(context, 24)),

                // ── Sign Out ──
                Container(
                  margin: Responsive.paddingSymmetric(context, h: 4),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: c.card,
                          title: Text('Sign Out', style: TextStyle(color: c.text)),
                          content: Text('Are you sure you want to sign out?', style: TextStyle(color: c.textMuted)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm != true || !mounted) return;
                      await context.read<ChatService>().purgePrivateMessages();
                      final p = await SharedPreferences.getInstance();
                      await p.clear();
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: Text('Sign Out', style: TextStyle(color: Colors.red, fontSize: Responsive.fontSize(context, 16))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: Responsive.paddingSymmetric(context, v: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 12))),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.vertical(context, 40)),
              ],
            );
          },
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context, AppColorSet c) {
    String category = 'general';
    int rating = 5;
    final msgController = TextEditingController();
    int wordCount = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: c.card,
          title: Text('Send Feedback', style: TextStyle(color: c.text)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Text('Category', style: TextStyle(color: c.textMuted, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  dropdownColor: c.card,
                  style: TextStyle(color: c.text),
                  decoration: InputDecoration(
                    filled: true, fillColor: c.bg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(value: 'bug', child: Text('Bug Report')),
                    DropdownMenuItem(value: 'feature', child: Text('Feature Request')),
                    DropdownMenuItem(value: 'security', child: Text('Security')),
                  ],
                  onChanged: (v) => setDialogState(() => category = v ?? 'general'),
                ),
                const SizedBox(height: 14),

                // Rating
                Text('Rating', style: TextStyle(color: c.textMuted, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => GestureDetector(
                    onTap: () => setDialogState(() => rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        color: i < rating ? Colors.amber : c.textHint,
                        size: 32,
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 14),

                // Message
                Text('Your Feedback', style: TextStyle(color: c.textMuted, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: msgController,
                  maxLines: 4,
                  style: TextStyle(color: c.text),
                  decoration: InputDecoration(
                    hintText: 'Tell us what you think...',
                    hintStyle: TextStyle(color: c.textHint),
                    filled: true, fillColor: c.bg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) {
                    setDialogState(() {
                      wordCount = v.trim().isEmpty ? 0 : v.trim().split(RegExp(r'\s+')).length;
                    });
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$wordCount/100 words',
                      style: TextStyle(
                        color: wordCount > 100 ? Colors.red : c.textHint,
                        fontSize: 12,
                        fontWeight: wordCount > 100 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: c.textMuted)),
            ),
            ElevatedButton(
              onPressed: wordCount == 0 || wordCount > 100 ? null : () async {
                Navigator.pop(ctx);
                await _submitFeedback(context, msgController.text.trim(), category, rating);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback(BuildContext context, String message, String category, int rating) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      final userName = prefs.getString('current_user_name') ?? prefs.getString('profile_name');
      final userPhone = prefs.getString('current_user_phone');
      final token = prefs.getString('firebase_token');

      final resp = await http.post(
        Uri.parse('${AppConfig.apiBase}/feedback'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'userName': userName,
          'userPhone': userPhone,
          'message': message,
          'category': category,
          'rating': rating,
        }),
      );
      if (!context.mounted) return;
      if (resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Thank you for your feedback!'), backgroundColor: Colors.green),
        );
      } else if (resp.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback is currently disabled'), backgroundColor: Colors.orange),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send feedback: ${resp.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _settingsHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: Responsive.horizontal(context, 4), bottom: Responsive.vertical(context, 8)),
      child: Text(title, style: TextStyle(color: AppColors.primaryBlue, fontSize: Responsive.fontSize(context, 13), fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    );
  }

  Widget _settingsTile({required IconData icon, required String title, String? subtitle, VoidCallback? onTap, Widget? trailing}) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.vertical(context, 4)),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(Responsive.radius(context, 12))),
      child: ListTile(
        leading: Container(
          padding: Responsive.paddingAll(context, 8),
          decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(Responsive.radius(context, 10))),
          child: Icon(icon, color: AppColors.primaryBlue, size: Responsive.size(context, 22)),
        ),
        title: Text(title, style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 15), fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.white54, fontSize: Responsive.fontSize(context, 13))) : null,
        trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: Colors.white38, size: Responsive.size(context, 22)) : null),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: Colors.black87, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, -2))]),
      child: SafeArea(
        child: SizedBox(
          height: Responsive.size(context, 65),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', 0),
              _buildNavItem(1, Icons.groups_outlined, Icons.groups, 'Groups', 0),
              _buildNavItem(2, Icons.auto_awesome_outlined, Icons.auto_awesome, 'AI Bot', 0),
              _buildNavItem(3, Icons.settings_outlined, Icons.settings, 'Settings', 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconOutline, IconData iconFilled, String label, int badge) {
    final bool isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () { setState(() => _currentIndex = index); _fabAnimController.forward(from: 0); },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              padding: Responsive.paddingSymmetric(context, v: 8),
              decoration: isSelected ? const BoxDecoration(border: Border(top: BorderSide(color: AppColors.primaryBlue, width: 2))) : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isSelected ? iconFilled : iconOutline, color: isSelected ? AppColors.primaryBlue : Colors.white70, size: Responsive.size(context, 24)),
                  SizedBox(height: Responsive.vertical(context, 4)),
                  Text(label, style: TextStyle(color: isSelected ? AppColors.primaryBlue : Colors.white70, fontSize: Responsive.fontSize(context, 11), fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                ],
              ),
            ),
            if (badge > 0) Positioned(
              top: 4,
              right: Responsive.width(context) / 8 - 20,
              child: Container(
                padding: Responsive.paddingSymmetric(context, h: 6, v: 2),
                decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(Responsive.radius(context, 10))),
                constraints: BoxConstraints(minWidth: Responsive.size(context, 18)),
                child: Text(badge.toString(), style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, 10), fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
