import 'package:dio/dio.dart';

/// NOTE: Migrated from `http` to `dio` for advanced networking, scalability, and performance.
/// For apps with 1B+ users, dio is preferred for robust error handling, interceptors, and flexibility.
/// (Migration: 2025-12-31)

class ApiService {
  static const String baseUrl = 'https://your-backend-api-url.com/api';
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

  // Add more API methods as needed...
}
