
import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;
import '../models/contact.dart';
import '../models/message.dart';
import 'api_service.dart';




class ChatService extends ChangeNotifier {

    Future<void> blockContact(String contactId) async {
      if (!_blockedContacts.contains(contactId)) {
        _blockedContacts.add(contactId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_blockedKey, jsonEncode(_blockedContacts));
        notifyListeners();
      }
    }
  // Inactivity timer for auto-clear
  Timer? _inactivityTimer;
  // AES-GCM for strong encryption
  final Cipher _cipher = AesGcm.with256bits();
  SecretKey? _secretKey;
  // Cached admin settings
  Map<String, dynamic>? _adminSettings;
  final String _adminApiBase = 'https://admin.sambad.com/api';

  /// Push a message or user activity to the admin portal for audit/sync
  Future<void> syncToAdminPortal({String? event, Map<String, dynamic>? data}) async {
    try {
      final uri = Uri.parse('$_adminApiBase/sync');
      final payload = {
        'event': event ?? 'activity',
        'timestamp': DateTime.now().toIso8601String(),
        'data': data ?? {},
      };
      final resp = await http.post(uri, body: jsonEncode(payload), headers: {'Content-Type': 'application/json'});
      if (resp.statusCode == 200) {
        debugPrint('[AdminSync] Synced event: $event');
      } else {
        debugPrint('[AdminSync] Failed to sync: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      debugPrint('[AdminSync] Error: $e');
    }
  }

  /// Fetch admin settings (encryption, auto-clear, timeouts, etc.)
  Future<void> fetchAdminSettings() async {
    try {
      final uri = Uri.parse('$_adminApiBase/settings');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        _adminSettings = jsonDecode(resp.body) as Map<String, dynamic>;
        debugPrint('[AdminSync] Admin settings loaded: $_adminSettings');
        // TODO: Apply settings to local config (encryption, timeouts, etc.)
      } else {
        debugPrint('[AdminSync] Failed to fetch settings: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('[AdminSync] Error fetching settings: $e');
    }
  }


  Future<void> unblockContact(String contactId) async {
    if (_blockedContacts.remove(contactId)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_blockedKey, jsonEncode(_blockedContacts));
      notifyListeners();
    }
  }

  final String _blockedKey = 'chat_blocked_v1';
  List<String> _blockedContacts = [];

  List<String> get blockedContacts => _blockedContacts;
  Future<void> deleteContact(String contactId) async {
    debugPrint('[ChatService] Deleting contact: $contactId');
    _contacts.removeWhere((c) => c.id == contactId);
    _messages.remove(contactId);
    await _saveContacts();
    await _saveMessages();
    debugPrint(
      '[ChatService] Contacts after delete: \n${_contacts.map((c) => c.toJson())}',
    );
    notifyListeners();
  }

  final String _contactsKey = 'chat_contacts_v1';
  final String _messagesKey = 'chat_messages_v1';
  final String _privateKeyPref = 'private_key_v1';
  final String privateConversationId = 'private';

  String? _currentUserPhone;
  String? _currentUserId;
  
  Future<void> loginUser(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:4000/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _currentUserPhone = phone;
        _currentUserId = userData['id'];
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user_phone', phone);
        await prefs.setString('current_user_id', userData['id']);
        
        debugPrint('[ChatService] Logged in as: $phone (${userData['id']})');
      }
    } catch (e) {
      debugPrint('[ChatService] Login error: $e');
    }
  }
  final int _privateTtlMs = 30 * 60 * 1000; // 30 minutes
  final String _privateSessionKey = 'private_session_last_v1';
  final String _groupsKey = 'chat_groups_v1';
  final String _groupMembersKey = 'chat_group_members_v1';
  final String _blockedGroupsKey = 'chat_blocked_groups_v1';

  List<Contact> _contacts = [];
  Map<String, List<Message>> _messages = {};
  List<String> _groups = [];
  Map<String, List<String>> _groupMembers = {};
  List<String> _blockedGroups = [];
  int? _lastPrivateActivity; // millisSinceEpoch of last private chat activity
  // Removed old encrypter fields
  Timer? _cleanupTimer;

  ChatService() {
    // periodic cleanup every minute
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _cleanupOldPrivateMessages(),
    );
    _initKey();
    _resetInactivityTimer();
    fetchAdminSettings().then((_) => _applyAdminSettings());
  }

  void _applyAdminSettings() {
    if (_adminSettings == null) return;
    // Example: apply admin-controlled timeouts and encryption
    if (_adminSettings!.containsKey('inactivityTimeoutMs')) {
      // You may want to make _inactivityTimeoutMs non-const and update timer
      // For demo, just print the value
      debugPrint('[AdminSync] Inactivity timeout set to: ${_adminSettings!['inactivityTimeoutMs']} ms');
    }
    if (_adminSettings!.containsKey('encryptionEnabled')) {
      debugPrint('[AdminSync] Encryption enabled: ${_adminSettings!['encryptionEnabled']}');
      // You could enable/disable encryption logic here
    }
    if (_adminSettings!.containsKey('autoClearEnabled')) {
      debugPrint('[AdminSync] Auto-clear enabled: ${_adminSettings!['autoClearEnabled']}');
      // You could enable/disable auto-clear logic here
    }
    // Add more settings as needed
  }

  // Call this on any user interaction or navigation to chat
  void userActive() {
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(
      const Duration(minutes: 5),
      () async {
        await clearAllMessages(reason: 'inactivity');
      },
    );
  }

  Future<void> _initKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? keyB64 = prefs.getString(_privateKeyPref);
    if (keyB64 == null) {
      final newKey = await _cipher.newSecretKey();
      final newKeyData = await newKey.extractBytes();
      keyB64 = base64Encode(newKeyData);
      await prefs.setString(_privateKeyPref, keyB64);
      _secretKey = newKey;
    } else {
      final keyBytes = base64Decode(keyB64);
      _secretKey = SecretKey(keyBytes);
    }
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    _inactivityTimer?.cancel();
    super.dispose();
  }
  /// Clear all messages for all contacts/groups (used for inactivity, logout, etc)
  Future<void> clearAllMessages({String? reason}) async {
    _messages.clear();
    await _saveMessages();
    notifyListeners();
    debugPrint('[ChatService] All messages cleared. Reason: [33m${reason ?? 'unspecified'}[0m');
  }

  List<Contact> get contacts => _contacts;
  List<String> get groups => _groups;
  Map<String, List<String>> get groupMembers => _groupMembers;
  List<String> get blockedGroups => _blockedGroups;

  List<String> membersForGroup(String name) => _groupMembers[name] ?? const [];

  // messagesFor is implemented below (returns decrypted copy)

  Future<void> init() async {
    debugPrint('[ChatService] Initializing ChatService...');
    final prefs = await SharedPreferences.getInstance();
    // ensure private key exists
    String? keyB64 = prefs.getString(_privateKeyPref);
    if (keyB64 == null) {
      final newKey = await _cipher.newSecretKey();
      final newKeyData = await newKey.extractBytes();
      keyB64 = base64Encode(newKeyData);
      await prefs.setString(_privateKeyPref, keyB64);
      _secretKey = newKey;
    } else {
      final keyBytes = base64Decode(keyB64);
      _secretKey = SecretKey(keyBytes);
    }
    
    // Load local contacts first
    final cJson = prefs.getString(_contactsKey);
    if (cJson != null) {
      final arr = jsonDecode(cJson) as List<dynamic>;
      _contacts = arr
          .map((e) => Contact.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      debugPrint(
        '[ChatService] Loaded local contacts: \n${_contacts.map((c) => c.toJson())}',
      );
    } else {
      _contacts = [];
      debugPrint('[ChatService] No local contacts found.');
    }
    
    // Also fetch contacts from API and merge
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:4000/api/contacts'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> apiContacts = jsonDecode(response.body);
        final Set<String> existingIds = _contacts.map((c) => c.id).toSet();
        
        for (final apiContact in apiContacts) {
          final contactUser = apiContact['contact_user'];
          if (contactUser != null) {
            final username = contactUser['username'] ?? '';
            final contactId = apiContact['id'] ?? '';
            // Extract phone number from username (e.g., +919876543210 -> 9876543210)
            final phone = username.replaceAll(RegExp(r'[^\d]'), '').substring(username.replaceAll(RegExp(r'[^\d]'), '').length - 10);
            final name = phone; // Use phone as name for now
            
            if (!existingIds.contains(contactId)) {
              _contacts.add(Contact(
                id: contactId,
                name: name,
                phone: phone,
              ));
              existingIds.add(contactId);
            }
          }
        }
        await _saveContacts();
        debugPrint('[ChatService] Synced contacts from API. Total: ${_contacts.length}');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ChatService] Failed to fetch contacts from API: $e');
      // Continue with local contacts if API fails
    }
    
    final mJson = prefs.getString(_messagesKey);
    final bJson = prefs.getString(_blockedKey);
    final gJson = prefs.getString(_groupsKey);
    final gmJson = prefs.getString(_groupMembersKey);
    final bgJson = prefs.getString(_blockedGroupsKey);
    final sessionJson = prefs.getString(_privateSessionKey);
    if (mJson != null) {
      final map = jsonDecode(mJson) as Map<String, dynamic>;
      _messages = map.map(
        (k, v) => MapEntry(
          k,
          (v as List<dynamic>)
              .map((e) => Message.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        ),
      );
    } else {
      _messages = {};
    }
    if (bJson != null) {
      final arr = jsonDecode(bJson) as List<dynamic>;
      _blockedContacts = arr.cast<String>();
    } else {
      _blockedContacts = [];
    }
    if (gJson != null) {
      final arr = jsonDecode(gJson) as List<dynamic>;
      _groups = arr.cast<String>();
    } else {
      _groups = [];
    }
    if (gmJson != null) {
      try {
        final map = jsonDecode(gmJson) as Map<String, dynamic>;
        _groupMembers = map.map(
          (key, value) =>
              MapEntry(key, (value as List<dynamic>).cast<String>()),
        );
      } catch (e) {
        debugPrint('[ChatService] Error loading group members: $e');
        _groupMembers = {};
      }
    } else {
      _groupMembers = {};
    }
    if (bgJson != null) {
      final arr = jsonDecode(bgJson) as List<dynamic>;
      _blockedGroups = arr.cast<String>();
    } else {
      _blockedGroups = [];
    }
    if (sessionJson != null) {
      try {
        _lastPrivateActivity = int.parse(sessionJson);
      } catch (_) {
        _lastPrivateActivity = null;
      }
    } else {
      _lastPrivateActivity = null;
    }
    notifyListeners();
  }

  /// Mark that user interacted with the private chat "session" just now.
  Future<void> markPrivateActivity() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    _lastPrivateActivity = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_privateSessionKey, now.toString());
  }

  Future<void> sendMessage(
    String contactId,
    String from,
    String text, {
    bool private = false,
  }) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    String storedText = text;
    if (_secretKey != null) {
      try {
        final nonce = _cipher.newNonce();
        final encrypted = await _cipher.encrypt(
          utf8.encode(text),
          secretKey: _secretKey!,
          nonce: nonce,
        );
        // Store nonce:cipherText:mac as base64
        storedText = '${base64Encode(nonce)}:${base64Encode(encrypted.cipherText)}:${base64Encode(encrypted.mac.bytes)}';
      } catch (e) {
        // fallback to plain text
        storedText = text;
      }
    }
    final msg = Message(
      id: '${contactId}_$ts',
      from: from,
      text: storedText,
      timestamp: ts,
      private: private,
    );
    _messages.putIfAbsent(contactId, () => []).add(msg);
    await _saveMessages();
    notifyListeners();
    
    // Send message via API for WebSocket sync
    try {
      final prefs = await SharedPreferences.getInstance();
      String? currentUserId = prefs.getString('current_user_id');
      
      if (currentUserId == null) {
        // Get/create current user (default to 9999999999 for now)
        final currentUserResponse = await http.post(
          Uri.parse('http://10.0.2.2:4000/api/users/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'mobileNumber': _currentUserPhone ?? '9999999999',
            'countryCode': '+91',
          }),
        );
        
        if (currentUserResponse.statusCode == 200) {
          final currentUserData = jsonDecode(currentUserResponse.body);
          currentUserId = currentUserData['id'];
          await prefs.setString('current_user_id', currentUserId!);
        }
      }
      
      if (currentUserId != null) {
        // Find contact user ID from contacts list
        final contact = _contacts.firstWhere(
          (c) => c.id == contactId,
          orElse: () => Contact(id: contactId, name: '', phone: ''),
        );
        
        // Try to find the contact to get their phone number
        final targetContact = _contacts.firstWhere(
          (c) => c.id == contactId,
          orElse: () => Contact(id: contactId, name: '', phone: contactId),
        );
        
        // Send message via API for WebSocket sync
        final messageResponse = await http.post(
          Uri.parse('http://10.0.2.2:4000/api/messages'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'fromUserId': currentUserId,
            'toUserId': targetContact.phone, // Send phone number, backend will look up UUID
            'content': text, // Send plain text to backend (encryption is local only)
            'type': 'text',
          }),
        );
        
        if (messageResponse.statusCode == 201) {
          debugPrint('[ChatService] Message sent via API for WebSocket sync');
        } else {
          debugPrint('[ChatService] Failed to send message via API: ${messageResponse.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('[ChatService] Error sending message via API: $e');
      // Continue even if API fails - message is saved locally
    }
    
    // Push to admin portal for audit/sync (legacy method)
    await syncToAdminPortal(event: 'send_message', data: msg.toJson());
  }

  // Decrypt message text
  Future<String> decryptMessage(String storedText) async {
    if (_secretKey == null) return storedText;
    try {
      final parts = storedText.split(':');
      if (parts.length != 3) return storedText;
      final nonce = base64Decode(parts[0]);
      final cipherText = base64Decode(parts[1]);
      final mac = Mac(base64Decode(parts[2]));
      final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
      final clear = await _cipher.decrypt(
        secretBox,
        secretKey: _secretKey!,
      );
      return utf8.decode(clear);
    } catch (_) {
      return storedText;
    }
  }

  /// Helper to compute a stable group conversation id from a group name
    String groupIdForName(String name) =>
      'chat_${name.toLowerCase().replaceAll(' ', '_')}';

  /// Return decrypted messages copy for read-only use
  Future<List<Message>> messagesFor(String contactId) async {
    final list = _messages[contactId] ?? [];
    List<Message> result = [];
    for (final m in list) {
      String text = m.text;
      if (_secretKey != null) {
        text = await decryptMessage(m.text);
      }
      result.add(Message(
        id: m.id,
        from: m.from,
        text: text,
        timestamp: m.timestamp,
        private: m.private,
      ));
    }
    return result;
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _messages.map(
      (k, v) => MapEntry(k, v.map((m) => m.toJson()).toList()),
    );
    await prefs.setString(_messagesKey, jsonEncode(map));
  }

  Future<void> _cleanupOldPrivateMessages() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    var changed = false;
    for (final key in _messages.keys.toList()) {
      final list = _messages[key]!;
      final before = list.length;
      list.removeWhere((m) => m.private && (now - m.timestamp) > _privateTtlMs);
      if (list.length != before) changed = true;
    }
    if (changed) {
      await _saveMessages();
      notifyListeners();
    }

    // Also enforce a 30-minute private session timeout: if there has been
    // no private activity for more than _privateTtlMs, wipe all private chat.
    final last = _lastPrivateActivity;
    if (last != null && (now - last) > _privateTtlMs) {
      await purgePrivateMessages();
      _lastPrivateActivity = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_privateSessionKey);
    }
  }

  /// Purge all private messages immediately (used when app goes to background/offline)
  Future<void> purgePrivateMessages() async {
    var changed = false;
    for (final key in _messages.keys.toList()) {
      final list = _messages[key]!;
      final before = list.length;
      list.removeWhere((m) => m.private);
      if (list.length != before) changed = true;
    }
    if (changed) {
      await _saveMessages();
      notifyListeners();
    }

    // Reset private session marker when we purge everything.
    _lastPrivateActivity = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_privateSessionKey);
  }

  /// Called by lifecycle watcher to clear all on leaving app or inactivity
  void handleAppLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      clearAllMessages(reason: 'app_inactive');
    }
  }

  // Add contact locally (for bulk import from phone)
  Future<void> addContactLocally({required String id, required String name, required String phone}) async {
    final contact = Contact(id: id, name: name, phone: phone);
    if (!_contacts.any((c) => c.phone == phone)) {
      _contacts.add(contact);
      await _saveContacts();
      notifyListeners();
      print('[ChatService] Adding contact: $contact');
    }
  }

  Future<void> addContact(Contact contact) async {
    // Also add contact via API
    try {
      final prefs = await SharedPreferences.getInstance();
      String? currentUserId = prefs.getString('current_user_id');
      
      if (currentUserId == null) {
        // Get/create current user
        final loginResponse = await http.post(
          Uri.parse('http://10.0.2.2:4000/api/users/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'mobileNumber': contact.phone,
            'countryCode': '+91',
          }),
        );
        
        if (loginResponse.statusCode == 200) {
          final loginData = jsonDecode(loginResponse.body);
          final contactUserId = loginData['user']?['id'];
          
          // Get current user (default to 9999999999 for now)
          final currentUserResponse = await http.post(
            Uri.parse('http://10.0.2.2:4000/api/users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'mobileNumber': _currentUserPhone ?? '9999999999',
              'countryCode': '+91',
            }),
          );
          
          if (currentUserResponse.statusCode == 200) {
            final currentUserData = jsonDecode(currentUserResponse.body);
            currentUserId = currentUserData['id'];
            await prefs.setString('current_user_id', currentUserId!);
            
            // Add contact via API
            await http.post(
              Uri.parse('http://10.0.2.2:4000/api/contacts'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'userId': currentUserId,
                'contactUserId': contactUserId,
              }),
            );
            debugPrint('[ChatService] Contact added via API: ${contact.phone}');
          }
        }
      }
    } catch (e) {
      debugPrint('[ChatService] Failed to add contact via API: $e');
      // Continue with local add even if API fails
    }
    
    debugPrint('[ChatService] Adding contact: ${contact.toJson()}');
    _contacts.add(contact);
    await _saveContacts();
    debugPrint(
      '[ChatService] Contacts after add: \\n${_contacts.map((c) => c.toJson())}',
    );
    
    // Sync to backend via GraphQL
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id') ?? '11111111-1111-1111-1111-111111111111'; // Default test user
      
      final apiService = ApiService();
      
      // Get or create contact user first
      final contactUserResponse = await apiService.loginUser(contact.phone);
      final contactUserId = contactUserResponse["id"];
      
      final result = await apiService.createContactChannel(
        userId: userId,
        contactUserId: contactUserId,
      );
      
      if (result != null) {
        debugPrint('[ChatService] Contact synced to backend: $result');
        // Push to admin portal for audit/sync
        await syncToAdminPortal(
          event: 'add_contact',
          data: {
            'contact_id': result['id'],
            'name': contact.name,
            'phone': contact.phone,
          },
        );
      } else {
        debugPrint('[ChatService] Failed to sync contact to backend');
      }
    } catch (e) {
      debugPrint('[ChatService] Error syncing contact: $e');
    }
    
    notifyListeners();
  }

  /// Load contacts from REST API
  Future<void> _loadContactsFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:4000/api/contacts'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _contacts = data.map((contact) {
          // Convert API contact format to Contact model
          final contactUser = contact['contact_user']?['username'] ?? '';
          final contactId = contact['id'] ?? '';
          // Extract phone number from username (format: +91XXXXXXXXXX)
          final phone = contactUser.replaceAll('+91', '');
          // Extract name if available, otherwise use phone
          final name = contact['contact_user']?['name'] ?? phone;
          
          return Contact(
            id: contactId,
            name: name,
            phone: phone,
          );
        }).toList();
        
        // Save to local storage for offline access
        await _saveContacts();
        
        debugPrint('[ChatService] Loaded ${_contacts.length} contacts from API');
        notifyListeners();
      } else {
        debugPrint('[ChatService] Failed to load contacts from API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ChatService] Error loading contacts from API: $e');
      // Fallback to local storage (handled in init)
    }
  }

  /// Fetch contacts from REST API and sync with local storage
  Future<void> _fetchContactsFromAPI() async {
    try {
      debugPrint('[ChatService] Fetching contacts from API...');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:4000/api/contacts'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _contacts = data.map((contact) {
          // Convert API contact format to Contact model
          final contactUser = contact['contact_user']?['username'] ?? '';
          final contactId = contact['id'] ?? '';
          // Extract phone number from username (format: +91XXXXXXXXXX)
          final phone = contactUser.replaceAll(RegExp(r'[^\d]'), '');
          final name = contactUser; // Use username as name for now
          
          return Contact(
            id: contactId,
            name: name,
            phone: phone,
          );
        }).toList();
        
        // Save to local storage for offline access
        await _saveContacts();
        debugPrint('[ChatService] Fetched ${_contacts.length} contacts from API');
        notifyListeners();
      } else {
        debugPrint('[ChatService] API fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ChatService] Error fetching contacts from API: $e');
      // Continue with local storage if API fails
    }
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    // Check available space (approximate, since SharedPreferences is limited)
    // This is a placeholder: in real apps, use platform channels for disk info
    try {
      final contactsJson = jsonEncode(
        _contacts.map((c) => c.toJson()).toList(),
      );
      if (contactsJson.length > 500000) {
        debugPrint(
          '[ChatService] Warning: Contacts data is very large (${contactsJson.length} bytes).',
        );
      }
      await prefs.setString(_contactsKey, contactsJson);
    } catch (e) {
      debugPrint('[ChatService] Error saving contacts: $e');
    }
  }

  Future<void> addGroup(
    String name, {
    List<String> memberIds = const [],
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (_groups.contains(trimmed)) return;
    _groups.add(trimmed);
    if (memberIds.isNotEmpty) {
      _groupMembers[trimmed] = List<String>.from(memberIds);
      await _saveGroupMembers();
    }
    await _saveGroups();
    notifyListeners();
  }

  Future<void> deleteGroup(String name) async {
    if (_groups.remove(name)) {
      final id = groupIdForName(name);
      _messages.remove(id);
      _groupMembers.remove(name);
      _blockedGroups.remove(name);
      await _saveGroups();
      await _saveGroupMembers();
      await _saveBlockedGroups();
      await _saveMessages();
      notifyListeners();
    }
  }

  Future<void> _saveGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_groupsKey, jsonEncode(_groups));
    } catch (e) {
      debugPrint('[ChatService] Error saving groups: $e');
    }
  }

  Future<void> _saveGroupMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_groupMembersKey, jsonEncode(_groupMembers));
    } catch (e) {
      debugPrint('[ChatService] Error saving group members: $e');
    }
  }

  Future<void> _saveBlockedGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_blockedGroupsKey, jsonEncode(_blockedGroups));
    } catch (e) {
      debugPrint('[ChatService] Error saving blocked groups: $e');
    }
  }

  Future<void> blockGroup(String name) async {
    final trimmed = name.trim();
    if (!_blockedGroups.contains(trimmed)) {
      _blockedGroups.add(trimmed);
      await _saveBlockedGroups();
      notifyListeners();
    }
  }

  Future<void> unblockGroup(String name) async {
    if (_blockedGroups.remove(name)) {
      await _saveBlockedGroups();
      notifyListeners();
    }
  }
}
