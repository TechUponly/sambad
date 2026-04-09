import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../config/app_config.dart';

class ContactsSyncService {
  static String get _baseUrl => AppConfig.backendBase;
  
  static Future<bool> requestContactsPermission() async {
    return await FlutterContacts.requestPermission();
  }
  
  static Future<Map<String, dynamic>> syncContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final contactData = contacts.map((c) {
        return <String, dynamic>{
          'name': c.displayName, 
          'phone': c.phones.isNotEmpty ? c.phones.first.number : '',
        };
      }).toList();
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('firebase_token');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sync-contacts'), 
        headers: {
          'Content-Type': 'application/json', 
          'Authorization': 'Bearer $token'
        }, 
        body: jsonEncode({'contacts': contactData})
      );
      
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
