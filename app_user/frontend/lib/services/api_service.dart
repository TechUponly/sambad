import 'package:dio/dio.dart';

/// NOTE: Migrated from `http` to `dio` for advanced networking, scalability, and performance.
/// For apps with 1B+ users, dio is preferred for robust error handling, interceptors, and flexibility.
/// (Migration: 2025-12-31)

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:4000/api';
  final Dio _dio = Dio();

  Future<dynamic> get(String endpoint) async {
    final response = await _dio.get('$baseUrl/$endpoint');
    return response.data;
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await _dio.post(
      '$baseUrl/$endpoint',
      data: data,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return response.data;
  }

  // Contact channel creation for backend compatibility
  Future<dynamic> createContactChannel({
    required String userId,
    required String contactUserId,
  }) async {
    return await post('contacts', {
      'userId': userId,
      'contactUserId': contactUserId,
    });
  }

  // User login
  Future<dynamic> loginUser(String phone) async {
    return await post('users/login', {'phone': phone});
  }

  // Get contacts
  Future<List<dynamic>> getContacts() async {
    return await get('contacts');
  }

  // Get messages
  Future<List<dynamic>> getMessages() async {
    return await get('messages');
  }

  // Send message
  Future<dynamic> sendMessage(Map<String, dynamic> messageData) async {
    return await post('messages', messageData);
  }
}
