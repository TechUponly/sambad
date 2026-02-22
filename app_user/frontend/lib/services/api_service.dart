import 'package:dio/dio.dart';

/// Production backend URL - DO NOT change without updating deployment
class ApiService {
  static const String baseUrl = 'https://web.uponlytech.com/sambad-backend/api';
  
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

  Future<dynamic> createContactChannel({
    required String userId,
    required String contactUserId,
  }) async {
    return await post('contacts', {
      'userId': userId,
      'contactUserId': contactUserId,
    });
  }

  Future<dynamic> loginUser(String phone) async {
    return await post('users/login', {'phone': phone});
  }

  Future<List<dynamic>> getContacts() async {
    return await get('contacts');
  }

  Future<List<dynamic>> getMessages() async {
    return await get('messages');
  }

  Future<dynamic> sendMessage(Map<String, dynamic> messageData) async {
    return await post('messages', messageData);
  }
}
