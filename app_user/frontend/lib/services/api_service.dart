import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBase;
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // Always get fresh token from Firebase
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken(true); // force refresh
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              // Save fresh token
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('firebase_token', token);
            }
          } else {
            // Fallback to saved token
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('firebase_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
        } catch (e) {
          // Fallback to saved token if refresh fails
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('firebase_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
    ));
  }

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
