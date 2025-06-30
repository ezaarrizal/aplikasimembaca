// lib/services/api_service.dart - COMPLETE VERSION
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/user.dart';
import '../models/api_response.dart';
// import '../models/feedback.dart' as FeedbackModel;
import '../models/feedback_list_response.dart';
import '../models/feedback_response.dart';
import 'storage_service.dart';
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl; // Ganti dengan URL server Anda
  
  final StorageService _storageService = StorageService();

  // Headers untuk API calls
  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      String? token = await _storageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Login
  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return AuthResponse.fromJson(responseData);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Get current user
  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/user'),
        headers: await _getHeaders(includeAuth: true),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['success']) {
        return ApiResponse<User>(
          success: true,
          message: responseData['message'] ?? 'Success',
          data: User.fromJson(responseData['data']['user']),
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: responseData['message'] ?? 'Failed to get user data',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Logout
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(includeAuth: true),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ApiResponse<void>(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Logout failed',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Register user (hanya untuk guru)
  Future<ApiResponse<User>> registerUser({
    required String username,
    String? email,
    required String password,
    required String nama,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guru/register-user'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'nama': nama,
          'role': role,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201 && responseData['success']) {
        return ApiResponse<User>(
          success: true,
          message: responseData['message'],
          data: User.fromJson(responseData['data']['user']),
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: responseData['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Change password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ApiResponse<void>(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Password change failed',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // ============================================
  // FEEDBACK ENDPOINTS
  // ============================================

  // Get feedback list for Guru
  Future<FeedbackListResponse> getFeedbackList({
    int page = 1,
    int perPage = 10,
    String? siswaId,
    String? kategori,
    String? tingkat,
    String? search,
  }) async {
    print('🔍 DEBUG: getFeedbackList called');
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (siswaId != null && siswaId.isNotEmpty) {
        queryParams['siswa_id'] = siswaId;
      }
      if (kategori != null && kategori.isNotEmpty) {
        queryParams['kategori'] = kategori;
      }
      if (tingkat != null && tingkat.isNotEmpty) {
        queryParams['tingkat'] = tingkat;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$baseUrl/guru/feedback').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 DEBUG: getFeedbackList response: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return FeedbackListResponse.fromJson(responseData);
    } catch (e) {
      print('💥 DEBUG: getFeedbackList error: $e');
      return FeedbackListResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Get feedback list for Orangtua (ALL feedbacks)
  Future<FeedbackListResponse> getFeedbackForParent({
    int page = 1,
    int perPage = 10,
    String? childId,
    bool unreadOnly = false,
  }) async {
    print('🔍 DEBUG: getFeedbackForParent called');
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (childId != null && childId.isNotEmpty) {
        queryParams['child_id'] = childId;
      }
      if (unreadOnly) {
        queryParams['unread_only'] = 'true';
      }

      final uri = Uri.parse('$baseUrl/orangtua/feedback').replace(
        queryParameters: queryParams,
      );

      print('🔍 DEBUG: getFeedbackForParent URL: $uri');

      final response = await http.get(
        uri,
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 DEBUG: getFeedbackForParent response: ${response.statusCode}');
      print('🔍 DEBUG: getFeedbackForParent body: ${response.body}');
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return FeedbackListResponse.fromJson(responseData);
    } catch (e) {
      print('💥 DEBUG: getFeedbackForParent error: $e');
      return FeedbackListResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Create feedback (Guru only)
  Future<FeedbackResponse> createFeedback({
    required String siswaId,
    required String judul,
    required String isiFeedback,
    required String kategori,
    required String tingkat,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guru/feedback'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'siswa_id': siswaId,
          'judul': judul,
          'isi_feedback': isiFeedback,
          'kategori': kategori,
          'tingkat': tingkat,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return FeedbackResponse.fromJson(responseData);
    } catch (e) {
      return FeedbackResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Update feedback (Guru only)
  Future<FeedbackResponse> updateFeedback({
    required String feedbackId,
    required String judul,
    required String isiFeedback,
    required String kategori,
    required String tingkat,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/guru/feedback/$feedbackId'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'judul': judul,
          'isi_feedback': isiFeedback,
          'kategori': kategori,
          'tingkat': tingkat,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return FeedbackResponse.fromJson(responseData);
    } catch (e) {
      return FeedbackResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Delete feedback (Guru only)
  Future<ApiResponse<void>> deleteFeedback(String feedbackId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/guru/feedback/$feedbackId'),
        headers: await _getHeaders(includeAuth: true),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ApiResponse<void>(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Delete failed',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Get feedback detail
  Future<FeedbackResponse> getFeedbackDetail(String feedbackId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/guru/feedback/$feedbackId'),
        headers: await _getHeaders(includeAuth: true),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return FeedbackResponse.fromJson(responseData);
    } catch (e) {
      return FeedbackResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Mark feedback as read (Orangtua only)
  Future<ApiResponse<void>> markFeedbackAsRead(String feedbackId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orangtua/feedback/$feedbackId/mark-read'),
        headers: await _getHeaders(includeAuth: true),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ApiResponse<void>(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Mark as read failed',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Get siswa list for feedback dropdown (Guru only)
  Future<ApiResponse<List<User>>> getSiswaList() async {
    print('🔍 DEBUG: getSiswaList called');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/guru/siswa-list'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 DEBUG: getSiswaList response: ${response.statusCode}');
      print('🔍 DEBUG: getSiswaList body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['success']) {
        List<User> siswaList = (responseData['data']['siswa'] as List)
            .map((siswa) => User.fromJson(siswa))
            .toList();
            
        print('✅ DEBUG: Parsed ${siswaList.length} siswa');
            
        return ApiResponse<List<User>>(
          success: true,
          message: responseData['message'] ?? 'Success',
          data: siswaList,
        );
      } else {
        return ApiResponse<List<User>>(
          success: false,
          message: responseData['message'] ?? 'Failed to get siswa list',
        );
      }
    } catch (e) {
      print('💥 DEBUG: getSiswaList error: $e');
      return ApiResponse<List<User>>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }
}