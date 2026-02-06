import 'dart:convert';
import 'package:http/http.dart' as http;

class SambadContactService {
  final String apiBaseUrl;
  SambadContactService({required this.apiBaseUrl});

  Future<List<Map<String, dynamic>>> fetchContacts() async {
    // Use localhost for local development, or set apiBaseUrl accordingly
    final url = Uri.parse('$apiBaseUrl/api/contacts');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load contacts: ${response.statusCode} ${response.body}');
    }
  }
}
