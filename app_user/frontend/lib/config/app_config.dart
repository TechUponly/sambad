/// Centralized app configuration for backend URLs.
///
/// Toggle [useLocalBackend] to switch between local and production.
class AppConfig {
  // ──────────────────────────────────────────────
  //  TOGGLE THIS FLAG TO SWITCH ENVIRONMENTS
  // ──────────────────────────────────────────────
  static const bool useLocalBackend = false;

  // ── Local URLs (your machine) ──
  // Android Emulator → 10.0.2.2
  // iOS Simulator    → localhost
  // Physical device  → use your Mac's local IP (e.g. 192.168.1.X)
  static const String _localHost = '10.0.2.2';
  static const int    _localPort = 4000;
  static const String _localBase = 'http://$_localHost:$_localPort';

  // ── Production URLs ──
  static const String _prodBackend = 'https://web.uponlytech.com/sambad-backend';
  static const String _prodAdmin   = 'https://web.uponlytech.com/sambad-admin-backend';

  // ── Public getters ──
  /// Base URL for the user-facing backend (no trailing slash).
  static String get backendBase =>
      useLocalBackend ? _localBase : _prodBackend;

  /// Base URL for API endpoints (includes /api).
  static String get apiBase => '$backendBase/api';

  /// Base URL for the admin backend.
  static String get adminBase =>
      useLocalBackend ? '$_localBase/api/admin' : _prodAdmin;

  /// WebSocket URL for real-time messaging.
  static String get wsBase {
    if (useLocalBackend) {
      return 'ws://$_localHost:$_localPort/ws';
    }
    // Production: replace https with wss
    //return _prodBackend.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://') + '/ws';
    return 'ws://web.uponlytech.com:4000/ws';
  }
}
