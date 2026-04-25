import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import 'chat_service.dart';

class ContactsSyncService {
  static String get _baseUrl => AppConfig.backendBase;
  
  static Future<bool> requestContactsPermission() async {
    final status = await FlutterContacts.permissions.request(PermissionType.readWrite);
    return status == PermissionStatus.granted || status == PermissionStatus.limited;
  }

  /// Sync phone contacts: reads from phone, adds to ChatService locally,
  /// and also pushes to the backend for server-side sync.
  static Future<Map<String, dynamic>> syncContacts({BuildContext? context}) async {
    try {
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone, ContactProperty.name},
      );
      
      // Filter to contacts that have a phone number
      final withPhone = contacts.where((c) => c.phones.isNotEmpty).toList();
      
      final contactData = withPhone.map((c) {
        return <String, dynamic>{
          'name': c.displayName, 
          'phone': c.phones.first.number,
        };
      }).toList();

      // ── 1. Add to local ChatService so they appear in the Home tab ──
      int addedLocally = 0;
      if (context != null) {
        try {
          final svc = context.read<ChatService>();
          final batch = withPhone.map((c) => <String, String>{
            'id': DateTime.now().millisecondsSinceEpoch.toString() + (c.displayName ?? '').hashCode.toString(),
            'name': c.displayName ?? '',
            'phone': c.phones.first.number.replaceAll(RegExp(r'[^0-9+]'), ''),
          }).toList();
          addedLocally = await svc.addContactsBatch(batch);
          debugPrint('[ContactsSync] Added $addedLocally contacts locally (${batch.length} total, ${batch.length - addedLocally} duplicates)');
        } catch (e) {
          debugPrint('[ContactsSync] Local add error: $e');
        }
      }

      // ── 2. Push to backend for server-side sync ──
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('firebase_token');
      
      try {
        await http.post(
          Uri.parse('$_baseUrl/api/sync-contacts'), 
          headers: {
            'Content-Type': 'application/json', 
            'Authorization': 'Bearer $token'
          }, 
          body: jsonEncode({'contacts': contactData})
        ).timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('[ContactsSync] Backend sync failed (contacts still added locally): $e');
      }

      await prefs.setBool('contacts_synced', true);
      return {
        'success': true, 
        'totalContacts': contactData.length,
        'addedLocally': addedLocally,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
