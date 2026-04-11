import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'models/contact.dart' as app;
import 'services/chat_service.dart';
import 'utils/phone_validator.dart';
import 'utils/country_code_picker.dart';
import 'utils/country_codes.dart';
import 'theme/app_colors.dart';
import 'utils/responsive.dart';

class AddContactDialog extends StatefulWidget {
  final Function(app.Contact) onAdd;
  const AddContactDialog({super.key, required this.onAdd});
  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  bool _loading = false;
  bool _showSuccess = false;
  String _successMessage = '';
  String? _phoneError;
  String _countryCode = '+91';
  bool _isSyncing = false;

  // Phone contacts
  List<Contact> _phoneContacts = [];
  List<Contact> _filteredContacts = [];
  bool _contactsLoading = false;
  bool _contactsPermissionDenied = false;
  bool _contactsLoaded = false;

  // Tab: 0 = phone contacts, 1 = manual
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPhoneContacts();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPhoneContacts() async {
    setState(() => _contactsLoading = true);

    final status = await Permission.contacts.status;
    if (!status.isGranted) {
      final result = await Permission.contacts.request();
      if (!result.isGranted) {
        if (mounted) {
          setState(() {
            _contactsLoading = false;
            _contactsPermissionDenied = true;
          });
        }
        return;
      }
    }

    try {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      // Filter to contacts that have at least one phone number
      final withPhone = contacts.where((c) => c.phones.isNotEmpty).toList();
      // Sort alphabetically
      withPhone.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

      if (mounted) {
        setState(() {
          _phoneContacts = withPhone;
          _filteredContacts = withPhone;
          _contactsLoading = false;
          _contactsLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _contactsLoading = false;
          _contactsPermissionDenied = true;
        });
      }
    }
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredContacts = _phoneContacts);
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _filteredContacts = _phoneContacts.where((c) {
        final nameMatch = c.displayName.toLowerCase().contains(q);
        final phoneMatch = c.phones.any((p) => p.number.replaceAll(RegExp(r'[^0-9]'), '').contains(q));
        return nameMatch || phoneMatch;
      }).toList();
    });
  }

  void _selectPhoneContact(Contact contact) {
    final name = contact.displayName;
    final phone = contact.phones.first.number.replaceAll(RegExp(r'[^0-9+]'), '');

    // Detect country code from phone number
    String detectedCode = '+91';
    String localNumber = phone;

    if (phone.startsWith('+')) {
      // Try to match known country codes (longest first)
      for (final cc in CountryCodes.all) {
        final ccDigits = cc.code;
        if (phone.startsWith(ccDigits)) {
          detectedCode = ccDigits;
          localNumber = phone.substring(ccDigits.length);
          break;
        }
      }
    } else if (phone.startsWith('0')) {
      localNumber = phone.substring(1);
    } else {
      localNumber = phone;
    }

    // Add contact directly
    _addContact(name, detectedCode, localNumber);
  }

  Future<void> _addContact(String name, String code, String phone) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a contact name'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() { _loading = true; _phoneError = null; });
    
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final fullPhone = '$code$cleanedPhone';
    final contact = app.Contact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      phone: fullPhone,
    );
    widget.onAdd(contact);
    if (!mounted) return;
    setState(() { _loading = false; _showSuccess = true; });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _addManual() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a contact name'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final phoneValidation = PhoneValidator.validate(_phoneCtrl.text, _countryCode);
    if (phoneValidation != null) {
      setState(() => _phoneError = phoneValidation);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(phoneValidation), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3)),
      );
      return;
    }

    final cleanedPhone = PhoneValidator.cleanPhone(_phoneCtrl.text);
    await _addContact(_nameCtrl.text, _countryCode, cleanedPhone);
  }

  /// Sync ALL phone contacts to Samvad in one batch
  Future<void> _syncAllContacts() async {
    if (_phoneContacts.isEmpty) return;

    setState(() => _isSyncing = true);

    try {
      final svc = context.read<ChatService>();

      // Build batch list from ALL phone contacts
      final batch = <Map<String, String>>[];
      for (final contact in _phoneContacts) {
        if (contact.phones.isNotEmpty) {
          final phone = contact.phones.first.number.replaceAll(RegExp(r'[^0-9+]'), '');
          batch.add({
            'id': contact.id,
            'name': contact.displayName,
            'phone': phone,
          });
        }
      }

      int added = 0;
      if (batch.isNotEmpty) {
        added = await svc.addContactsBatch(batch);
      }

      if (!mounted) return;
      setState(() {
        _isSyncing = false;
        _showSuccess = true;
        _successMessage = '$added new contacts synced!';
      });

      // Show snackbar with details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $added contacts added (${batch.length - added} already existed)'),
          backgroundColor: AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sync: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(children: [
      Dialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 24))),
        child: Container(
          padding: Responsive.paddingAll(context, 20),
          height: screenHeight * 0.65,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Add Contact', style: TextStyle(color: c.text, fontSize: Responsive.fontSize(context, 24), fontWeight: FontWeight.bold)),
              SizedBox(height: Responsive.vertical(context, 16)),

              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: c.text.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: c.textMuted,
                  labelStyle: TextStyle(fontSize: Responsive.fontSize(context, 13), fontWeight: FontWeight.w600),
                  unselectedLabelStyle: TextStyle(fontSize: Responsive.fontSize(context, 13)),
                  tabs: const [
                    Tab(text: '📱 Phone Contacts'),
                    Tab(text: '✏️ Manual Entry'),
                  ],
                ),
              ),

              SizedBox(height: Responsive.vertical(context, 12)),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Phone Contacts
                    _buildPhoneContactsTab(c),
                    // Tab 2: Manual Entry
                    _buildManualTab(c),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Success overlay
      if (_showSuccess) Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Center(
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 400),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.elasticOut,
              builder: (context, double value, child) => Transform.scale(
                scale: value,
                child: Container(
                  width: Responsive.size(context, 120), height: Responsive.size(context, 120),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF5B7FFF), Color(0xFF4A6FEE)]),
                    boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 5)],
                  ),
                  child: Center(
                    child: Container(
                      width: Responsive.size(context, 60), height: Responsive.size(context, 60),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12)],
                      ),
                      child: Icon(Icons.check, color: AppColors.success, size: Responsive.size(context, 42)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildPhoneContactsTab(AppColorSet c) {
    if (_contactsLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryBlue),
            SizedBox(height: Responsive.vertical(context, 12)),
            Text('Loading contacts...', style: TextStyle(color: c.textMuted, fontSize: Responsive.fontSize(context, 14))),
          ],
        ),
      );
    }

    if (_contactsPermissionDenied) {
      return Center(
        child: Padding(
          padding: Responsive.paddingAll(context, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.contacts_outlined, color: c.textMuted, size: 48),
              SizedBox(height: Responsive.vertical(context, 12)),
              Text(
                'Contact permission needed',
                style: TextStyle(color: c.text, fontSize: Responsive.fontSize(context, 16), fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.vertical(context, 8)),
              Text(
                'Grant access to your phone contacts to quickly find and add friends.',
                style: TextStyle(color: c.textMuted, fontSize: Responsive.fontSize(context, 13)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.vertical(context, 20)),
              ElevatedButton.icon(
                onPressed: () async {
                  setState(() => _contactsPermissionDenied = false);
                  await _loadPhoneContacts();
                },
                icon: const Icon(Icons.sync),
                label: const Text('Grant Permission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(height: Responsive.vertical(context, 8)),
              TextButton(
                onPressed: () => openAppSettings(),
                child: Text('Open Settings', style: TextStyle(color: AppColors.primaryBlue, fontSize: Responsive.fontSize(context, 13))),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        TextField(
          controller: _searchCtrl,
          style: TextStyle(color: c.text, fontSize: Responsive.fontSize(context, 14)),
          decoration: InputDecoration(
            hintText: 'Search name or phone...',
            hintStyle: TextStyle(color: c.textHint, fontSize: Responsive.fontSize(context, 14)),
            prefixIcon: Icon(Icons.search, color: c.textHint, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: c.textMuted, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      _filterContacts('');
                    },
                  )
                : null,
            filled: true,
            fillColor: c.text.withValues(alpha: 0.06),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: _filterContacts,
        ),

        SizedBox(height: Responsive.vertical(context, 8)),

        // Contact count & sync button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_filteredContacts.length} contacts',
              style: TextStyle(color: c.textMuted, fontSize: Responsive.fontSize(context, 12)),
            ),
            ElevatedButton.icon(
              onPressed: (_contactsLoading || _isSyncing || _phoneContacts.isEmpty) ? null : _syncAllContacts,
              icon: _isSyncing
                  ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.sync, size: 16),
              label: Text(
                _isSyncing ? 'Syncing...' : 'Sync Contacts',
                style: TextStyle(fontSize: Responsive.fontSize(context, 12)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),

        SizedBox(height: Responsive.vertical(context, 4)),

        // Contact list
        Expanded(
          child: _filteredContacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_search, color: c.textMuted, size: 36),
                      SizedBox(height: Responsive.vertical(context, 8)),
                      Text(
                        _searchCtrl.text.isNotEmpty ? 'No contacts match your search' : 'No contacts found',
                        style: TextStyle(color: c.textMuted, fontSize: Responsive.fontSize(context, 14)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredContacts.length,
                  itemBuilder: (_, i) {
                    final contact = _filteredContacts[i];
                    final phone = contact.phones.isNotEmpty
                        ? contact.phones.first.number
                        : '';
                    final initial = contact.displayName.isNotEmpty
                        ? contact.displayName[0].toUpperCase()
                        : '?';

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _loading ? null : () => _selectPhoneContact(contact),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.avatarColor(contact.displayName),
                                child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact.displayName,
                                      style: TextStyle(color: c.text, fontSize: Responsive.fontSize(context, 14), fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (phone.isNotEmpty)
                                      Text(
                                        phone,
                                        style: TextStyle(color: c.textMuted, fontSize: Responsive.fontSize(context, 12)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildManualTab(AppColorSet c) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: Responsive.vertical(context, 8)),
          TextField(
            controller: _nameCtrl,
            enabled: !_loading,
            style: TextStyle(color: c.text),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Name',
              hintStyle: TextStyle(color: c.textMuted),
              prefixIcon: Icon(Icons.person, color: c.textMuted, size: 20),
              filled: true,
              fillColor: c.text.withValues(alpha: 0.08),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 16)), borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: Responsive.vertical(context, 16)),
          Row(
            children: [
              GestureDetector(
                onTap: _loading ? null : () async {
                  final selected = await showCountryCodePicker(context);
                  if (selected != null) setState(() => _countryCode = selected.code);
                },
                child: Container(
                  padding: Responsive.paddingSymmetric(context, h: 12, v: 14),
                  decoration: BoxDecoration(
                    color: c.text.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${CountryCodes.findByCode(_countryCode)?.flag ?? ''} $_countryCode', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: Responsive.fontSize(context, 14))),
                      Icon(Icons.arrow_drop_down, color: c.textMuted, size: Responsive.size(context, 18)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: Responsive.horizontal(context, 8)),
              Expanded(
                child: TextField(
                  controller: _phoneCtrl,
                  enabled: !_loading,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: c.text),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(PhoneValidator.getExpectedDigits(_countryCode)),
                  ],
                  onChanged: (_) {
                    if (_phoneError != null) setState(() => _phoneError = null);
                  },
                  decoration: InputDecoration(
                    hintText: 'Phone (${PhoneValidator.getExpectedDigits(_countryCode)} digits)',
                    hintStyle: TextStyle(color: c.textMuted),
                    prefixIcon: Icon(Icons.phone, color: c.textMuted, size: 20),
                    filled: true,
                    fillColor: c.text.withValues(alpha: 0.08),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 16)), borderSide: BorderSide.none),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 16)), borderSide: const BorderSide(color: Colors.red)),
                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 16)), borderSide: const BorderSide(color: Colors.red, width: 2)),
                    errorText: _phoneError,
                    errorStyle: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.vertical(context, 28)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _loading ? null : () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: c.textMuted)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _loading ? null : _addManual,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 14))),
                  padding: Responsive.paddingSymmetric(context, h: 32, v: 16),
                ),
                child: _loading
                    ? SizedBox(width: Responsive.size(context, 20), height: Responsive.size(context, 20), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
