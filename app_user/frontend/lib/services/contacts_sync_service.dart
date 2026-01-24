import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsSyncService {
  static const String _baseUrl = 'http://10.0.2.2:3000';
  
  static Future<bool> requestContactsPermission() async {
    return await FlutterContacts.requestPermission();
  }
  
  static Future<Map<String, dynamic>> syncContactsWithBackend() async {
    try {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final contactData = contacts.map((c) => {'name': c.displayName, 'phone': c.phones.isNotEmpty ? c.phones.first.number : ''}).toList();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      final response = await http.post(Uri.parse('$_baseUrl/sync-contacts'), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode({'contacts': contactData}));
      if (response.statusCode == 200) {
        await prefs.setBool('contacts_synced', true);
        return {'success': true, 'totalContacts': contactData.length};
      }
      return {'success': false, 'error': 'Failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
