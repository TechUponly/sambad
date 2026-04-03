import 'package:dio/dio.dart';

class AdminAuthState {
  static String? token;
  static Map<String, dynamic>? currentAdmin;
  
  static String get role => currentAdmin?['role'] ?? 'viewer';
  static String get username => currentAdmin?['username'] ?? '';
  static bool get isLoggedIn => token != null && currentAdmin != null;
  
  static bool hasRole(List<String> allowedRoles) => allowedRoles.contains(role);
  static bool get isSuperAdmin => role == 'super_admin';
  static bool get isAdminOrAbove => hasRole(['super_admin', 'admin']);
  
  static void clear() {
    token = null;
    currentAdmin = null;
  }
}

class ApiService {
  static const String baseUrl = 'https://web.uponlytech.com/sambad-admin-backend';
  
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (AdminAuthState.token != null) {
          options.headers['Authorization'] = 'Bearer ${AdminAuthState.token}';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          AdminAuthState.clear();
        }
        return handler.next(error);
      },
    ));
  }

  // ── Auth ──
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post('$baseUrl/auth/login', data: {
      'username': username,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    AdminAuthState.token = data['token'];
    AdminAuthState.currentAdmin = data['admin'];
    return data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('$baseUrl/auth/me');
    AdminAuthState.currentAdmin = response.data;
    return response.data;
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _dio.post('$baseUrl/auth/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  // ── Dashboard ──
  Future<Map<String, dynamic>> fetchDashboardAnalytics() async {
    final response = await _dio.get('$baseUrl/analytics');
    return response.data;
  }

  Future<List<dynamic>> fetchRecentActivity() async {
    final response = await _dio.get('$baseUrl/activity');
    return response.data;
  }

  // ── App Users (from user backend) ──
  Future<List<dynamic>> fetchUsers() async {
    final response = await _dio.get('$baseUrl/users');
    return response.data;
  }

  // ── Admin Users (RBAC management) ──
  Future<List<dynamic>> fetchAdminUsers() async {
    final response = await _dio.get('$baseUrl/admin-users');
    return response.data;
  }

  Future<Map<String, dynamic>> createAdminUser({
    required String username,
    required String password,
    String? email,
    String role = 'moderator',
  }) async {
    final response = await _dio.post('$baseUrl/admin-users', data: {
      'username': username,
      'password': password,
      if (email != null) 'email': email,
      'role': role,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateAdminUser(String id, {
    String? email,
    String? role,
    bool? isActive,
    String? password,
  }) async {
    final response = await _dio.put('$baseUrl/admin-users/$id', data: {
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (password != null) 'password': password,
    });
    return response.data;
  }

  Future<void> deleteAdminUser(String id) async {
    await _dio.delete('$baseUrl/admin-users/$id');
  }

  // ── Notifications ──
  Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String body,
    String audience = 'all',
    List<String>? targetUserIds,
  }) async {
    final response = await _dio.post('$baseUrl/notifications/send', data: {
      'title': title,
      'body': body,
      'audience': audience,
      if (targetUserIds != null) 'target_user_ids': targetUserIds,
    });
    return response.data;
  }

  Future<List<dynamic>> fetchNotifications() async {
    final response = await _dio.get('$baseUrl/notifications');
    return response.data;
  }

  // ── Audit Logs ──
  Future<List<dynamic>> fetchAuditLogs() async {
    final response = await _dio.get('$baseUrl/audit-logs');
    return response.data;
  }

  // ── Settings ──
  Future<List<dynamic>> fetchSettings() async {
    final response = await _dio.get('$baseUrl/settings');
    return response.data;
  }

  Future<void> updateSetting(String key, dynamic value) async {
    await _dio.put('$baseUrl/settings/$key', data: {'value': value});
  }
}
