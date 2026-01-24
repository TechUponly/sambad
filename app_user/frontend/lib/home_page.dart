import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'services/chat_service.dart';
import 'models/contact.dart';
import 'widgets/contact_tile.dart';
import 'chat_page.dart';
import 'ai_bot_chat_page.dart';
import 'add_contact_dialog.dart';
import 'profile_section_page.dart';
import 'create_group_dialog.dart';

const Color kPrimaryBlue = Color(0xFF5B7FFF);
const Color kAccentGreen = Color(0xFF00C853);
const Color kBgDark = Color(0xFF181A20);
const Color kBgCard = Color(0xFF23272F);

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
    setState(() => _profileName = 'Shamrai');
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
      backgroundColor: kBgDark,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _buildBody()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kBgCard,
      elevation: 0,
      leadingWidth: 56,
      leading: IconButton(
        icon: CircleAvatar(
          backgroundColor: kPrimaryBlue,
          child: Text(_profileName?.substring(0, 1).toUpperCase() ?? 'S', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSectionPage())),
      ),
      actions: [
        Container(
          width: 240,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search chats...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white10,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: kPrimaryBlue, width: 2)),
              prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
              suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.white54, size: 18), onPressed: () { setState(() { _searchQuery = ''; _searchController.clear(); }); _searchFocus.unfocus(); }) : null,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
      ],
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
        final allContacts = chatService.contacts;
        final filteredContacts = _searchQuery.isEmpty ? allContacts : allContacts.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()) || c.phone.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimaryBlue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: kPrimaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Row(
                children: [
                  Expanded(child: Text('Private Sambad welcomes you!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [kPrimaryBlue.withOpacity(0.2), kPrimaryBlue.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kPrimaryBlue.withOpacity(0.3), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(icon: Icons.person_add_outlined, label: 'Add Contact', onTap: () { showDialog(context: context, builder: (ctx) => AddContactDialog(onAdd: (contact) async { final svc = context.read<ChatService>(); await svc.addContact(contact); })); }),
                  _buildActionButton(icon: Icons.group_add_outlined, label: 'New Group', onTap: () => _createGroup(context)),
                  _buildActionButton(icon: Icons.share_outlined, label: 'Invite Friends', onTap: () async { await Share.share('Join me on Sambad! Secure messaging app. Download now!'); }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (allContacts.isEmpty) _buildEmptyState() else Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: filteredContacts.length, itemBuilder: (context, index) { final contact = filteredContacts[index]; final unread = index % 4 == 0; return Container(margin: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: kBgCard, borderRadius: BorderRadius.circular(12), border: unread ? const Border(left: BorderSide(color: kPrimaryBlue, width: 2)) : null), child: ContactTile(contact: contact, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(name: contact.name, isPrivate: true))); }, unreadCount: unread ? 2 : 0)); })),
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
          borderRadius: BorderRadius.circular(12),
          splashColor: kPrimaryBlue.withOpacity(0.3),
          highlightColor: kPrimaryBlue.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(height: 6),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
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
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: kPrimaryBlue.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.chat_bubble_outline, size: 64, color: kPrimaryBlue)),
              const SizedBox(height: 24),
              const Text('No chats yet', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Start a conversation by adding a contact', style: TextStyle(color: Colors.white60, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () { showDialog(context: context, builder: (ctx) => AddContactDialog(onAdd: (contact) async { final svc = context.read<ChatService>(); await svc.addContact(contact); })); },
                icon: const Icon(Icons.person_add),
                label: const Text('Add Your First Contact'),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    return Consumer<ChatService>(builder: (context, chatService, _) { final groups = chatService.groups.where((g) => !chatService.blockedGroups.contains(g)).toList(); if (groups.isEmpty) { return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ const Icon(Icons.groups, size: 64, color: Colors.white54), const SizedBox(height: 16), const Text('No groups yet', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 12), const Text('Create a group to chat with multiple people', style: TextStyle(color: Colors.white60)), const SizedBox(height: 24), ElevatedButton.icon(onPressed: () => _createGroup(context), icon: const Icon(Icons.group_add), label: const Text('Create Group'), style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))), ])); } return ListView.builder(padding: const EdgeInsets.all(16), itemCount: groups.length, itemBuilder: (context, index) { final group = groups[index]; return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: kBgCard, borderRadius: BorderRadius.circular(12)), child: ListTile(leading: CircleAvatar(backgroundColor: kPrimaryBlue.withOpacity(0.2), child: const Icon(Icons.group, color: kPrimaryBlue)), title: Text(group, style: const TextStyle(color: Colors.white)), subtitle: const Text('Tap to open', style: TextStyle(color: Colors.white60)), onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(name: group, isPrivate: false))); })); }); });
  }

  Widget _buildAIBotTab() {
    return const AIBotChatPage();
  }

  Widget _buildSettingsTab() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [ Icon(Icons.settings, size: 64, color: Colors.white54), SizedBox(height: 16), Text('Settings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text('Coming soon', style: TextStyle(color: Colors.white60)), ]));
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: Colors.black87, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, -2))]),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', 8),
              _buildNavItem(1, Icons.groups_outlined, Icons.groups, 'Groups', 0),
              _buildNavItem(2, Icons.auto_awesome_outlined, Icons.auto_awesome, 'AI Notes', 0),
              _buildNavItem(3, Icons.settings_outlined, Icons.settings, 'Settings', 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconOutline, IconData iconFilled, String label, int badge) {
    final bool isSelected = _currentIndex == index;
    return Expanded(child: InkWell(onTap: () { setState(() => _currentIndex = index); _fabAnimController.forward(from: 0); }, child: Stack(alignment: Alignment.topCenter, children: [ Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: isSelected ? const BoxDecoration(border: Border(top: BorderSide(color: kPrimaryBlue, width: 2))) : null, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(isSelected ? iconFilled : iconOutline, color: isSelected ? kPrimaryBlue : Colors.white70, size: 24), const SizedBox(height: 4), Text(label, style: TextStyle(color: isSelected ? kPrimaryBlue : Colors.white70, fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)), ])), if (badge > 0) Positioned(top: 4, right: MediaQuery.of(context).size.width / 8 - 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: kPrimaryBlue, borderRadius: BorderRadius.circular(10)), constraints: const BoxConstraints(minWidth: 18), child: Text(badge.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center))), ])));
  }
}
