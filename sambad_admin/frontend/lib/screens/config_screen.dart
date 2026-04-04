import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  final Map<String, dynamic> _settings = {};

  // Default config keys with labels and descriptions
  static const _configItems = [
    _ConfigItem('otp_login_enabled', 'Enable OTP Login', 'Allow users to login with phone OTP', 'bool'),
    _ConfigItem('google_login_enabled', 'Enable Google Login', 'Allow users to login with Google account', 'bool'),
    _ConfigItem('apple_login_enabled', 'Enable Apple Login', 'Allow users to login with Apple ID', 'bool'),
    _ConfigItem('registration_enabled', 'Allow New Registrations', 'When disabled, new users cannot sign up', 'bool'),
    _ConfigItem('maintenance_mode', 'Maintenance Mode', 'Show maintenance screen to all app users', 'bool'),
    _ConfigItem('invite_text', 'Invite Text', 'Default invite message shared by users', 'text'),
    _ConfigItem('min_app_version', 'Min App Version', 'Force update below this version (e.g. 1.0.0)', 'string'),
    _ConfigItem('max_group_members', 'Max Group Members', 'Maximum members per group chat', 'number'),
    _ConfigItem('private_session_timeout', 'Private Session Timeout', 'Minutes before private messages auto-clear', 'number'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await ApiService().fetchSettings();
      _settings.clear();
      for (final s in list) {
        _settings[s['key']] = s['value'];
      }
      // Apply defaults for missing keys
      for (final item in _configItems) {
        if (!_settings.containsKey(item.key)) {
          _settings[item.key] = item.type == 'bool' ? 'false' : '';
        }
      }
    } catch (e) {
      _error = 'Failed to load settings: $e';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    setState(() => _saving = true);
    try {
      await ApiService().updateSetting(key, value.toString());
      _settings[key] = value.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ "$key" updated'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  bool _getBool(String key) => _settings[key]?.toString().toLowerCase() == 'true';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadSettings,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tune, color: theme.colorScheme.primary, size: 32),
                  const SizedBox(width: 12),
                  Text('App Configuration', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reload',
                    onPressed: _loadSettings,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Changes are saved immediately and pushed to the app.', style: theme.textTheme.bodySmall),
              const SizedBox(height: 24),
              // Auth section
              _sectionHeader(theme, Icons.login, 'Authentication'),
              ..._configItems.where((i) => i.key.contains('login') || i.key.contains('registration')).map((item) => _buildConfigTile(theme, item)),
              const SizedBox(height: 20),
              // App behavior section
              _sectionHeader(theme, Icons.settings_applications, 'App Behavior'),
              ..._configItems.where((i) => i.key == 'maintenance_mode' || i.key == 'min_app_version' || i.key == 'max_group_members' || i.key == 'private_session_timeout').map((item) => _buildConfigTile(theme, item)),
              const SizedBox(height: 20),
              // Content section
              _sectionHeader(theme, Icons.message, 'Content'),
              ..._configItems.where((i) => i.key == 'invite_text').map((item) => _buildConfigTile(theme, item)),
              const SizedBox(height: 40),
            ],
          ),
        ),
        if (_saving)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _sectionHeader(ThemeData theme, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _buildConfigTile(ThemeData theme, _ConfigItem item) {
    if (item.type == 'bool') {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SwitchListTile.adaptive(
          value: _getBool(item.key),
          onChanged: (v) => _saveSetting(item.key, v),
          title: Text(item.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(item.description, style: theme.textTheme.bodySmall),
          activeColor: theme.colorScheme.primary,
        ),
      );
    }

    if (item.type == 'text') {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(item.description, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _settings[item.key]?.toString() ?? '',
                maxLines: 3,
                onFieldSubmitted: (v) => _saveSetting(item.key, v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      // Will be triggered from onFieldSubmitted or manually
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // string or number
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(item.description, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            SizedBox(
              width: 140,
              child: TextFormField(
                initialValue: _settings[item.key]?.toString() ?? '',
                keyboardType: item.type == 'number' ? TextInputType.number : TextInputType.text,
                textAlign: TextAlign.center,
                onFieldSubmitted: (v) => _saveSetting(item.key, v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigItem {
  final String key;
  final String label;
  final String description;
  final String type; // 'bool', 'string', 'number', 'text'
  const _ConfigItem(this.key, this.label, this.description, this.type);
}
