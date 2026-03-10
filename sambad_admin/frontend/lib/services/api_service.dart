import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'https://web.uponlytech.com/sambad-admin-backend';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> fetchDashboardAnalytics() async {
    final response = await _dio.get('$baseUrl/analytics');
    return response.data;
  }

  Future<List<dynamic>> fetchRecentActivity() async {
    final response = await _dio.get('$baseUrl/activity');
    return response.data;
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await _dio.get('$baseUrl/users');
    return response.data;
  }

  Future<Map<String, dynamic>> fetchUserDetails(String userId) async {
    final response = await _dio.get('$baseUrl/users/$userId');
    return response.data;
  }

  Future<Map<String, dynamic>> fetchPersonaAnalytics(String userId) async {
    final response = await _dio.get('$baseUrl/users/$userId/analytics');
    return response.data;
  }

  Future<List<dynamic>> fetchUserChats(String userId) async {
    final response = await _dio.get('$baseUrl/users/$userId/chats');
    return response.data;
  }

  Future<Map<String, dynamic>> fetchUserLocation(String userId) async {
    final response = await _dio.get('$baseUrl/users/$userId/location');
    return response.data;
  }
}
