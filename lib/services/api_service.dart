import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/user.dart';
import '../models/api_response.dart';
// import '../models/feedback.dart' as FeedbackModel;
import '../models/feedback_list_response.dart';
import '../models/feedback_response.dart';
import 'storage_service.dart';

class ApiService {
  // 🚀 FIXED: Direct Railway URL instead of ApiConfig
  static const String baseUrl =
      'https://echo-web-production-5353.up.railway.app/api/v1';

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
    print('🔍 Making login request to: $baseUrl/auth/login');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('🔍 Login response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return AuthResponse.fromJson(responseData);
    } catch (e) {
      print('❌ Login error: $e');
      return AuthResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Get current user
  Future<ApiResponse<User>> getCurrentUser() async {
    print('🔍 Making getCurrentUser request to: $baseUrl/auth/user');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/user'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 getCurrentUser response status: ${response.statusCode}');
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
      print('❌ getCurrentUser error: $e');
      return ApiResponse<User>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Logout
  Future<ApiResponse<void>> logout() async {
    print('🔍 Making logout request to: $baseUrl/auth/logout');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 Logout response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      return ApiResponse<void>(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Logout failed',
      );
    } catch (e) {
      print('❌ Logout error: $e');
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
    print('🔍 Making registerUser request to: $baseUrl/guru/users');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guru/users'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'nama': nama,
          'role': role,
        }),
      );

      print('🔍 registerUser response status: ${response.statusCode}');
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
      print('❌ registerUser error: $e');
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
    print('🔍 Making changePassword request to: $baseUrl/auth/change-password');
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

      print('🔍 changePassword response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      return ApiResponse<void>(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Password change failed',
      );
    } catch (e) {
      print('❌ changePassword error: $e');
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
    print('🔍 Making getFeedbackList request to: $baseUrl/guru/feedback');
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

      print('🔍 getFeedbackList response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return FeedbackListResponse.fromJson(responseData);
    } catch (e) {
      print('❌ getFeedbackList error: $e');
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
    print(
        '🔍 Making getFeedbackForParent request to: $baseUrl/orangtua/feedback');
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

      print('🔍 getFeedbackForParent URL: $uri');

      final response = await http.get(
        uri,
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 getFeedbackForParent response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return FeedbackListResponse.fromJson(responseData);
    } catch (e) {
      print('❌ getFeedbackForParent error: $e');
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
    print('🔍 Making createFeedback request to: $baseUrl/guru/feedback');
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

      print('🔍 createFeedback response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return FeedbackResponse.fromJson(responseData);
    } catch (e) {
      print('❌ createFeedback error: $e');
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
    print(
        '🔍 Making updateFeedback request to: $baseUrl/guru/feedback/$feedbackId');
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

      print('🔍 updateFeedback response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return FeedbackResponse.fromJson(responseData);
    } catch (e) {
      print('❌ updateFeedback error: $e');
      return FeedbackResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Delete feedback (Guru only)
  Future<ApiResponse<void>> deleteFeedback(String feedbackId) async {
    print(
        '🔍 Making deleteFeedback request to: $baseUrl/guru/feedback/$feedbackId');
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/guru/feedback/$feedbackId'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 deleteFeedback response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      return ApiResponse<void>(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Delete failed',
      );
    } catch (e) {
      print('❌ deleteFeedback error: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Get feedback detail
  Future<FeedbackResponse> getFeedbackDetail(String feedbackId) async {
    print(
        '🔍 Making getFeedbackDetail request to: $baseUrl/guru/feedback/$feedbackId');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/guru/feedback/$feedbackId'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 getFeedbackDetail response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return FeedbackResponse.fromJson(responseData);
    } catch (e) {
      print('❌ getFeedbackDetail error: $e');
      return FeedbackResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Mark feedback as read (Orangtua only)
  Future<ApiResponse<void>> markFeedbackAsRead(String feedbackId) async {
    print(
        '🔍 Making markFeedbackAsRead request to: $baseUrl/orangtua/feedback/$feedbackId/mark-read');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orangtua/feedback/$feedbackId/mark-read'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 markFeedbackAsRead response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      return ApiResponse<void>(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Mark as read failed',
      );
    } catch (e) {
      print('❌ markFeedbackAsRead error: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Get siswa list for feedback dropdown (Guru only)
  Future<ApiResponse<List<User>>> getSiswaList() async {
    print('🔍 Making getSiswaList request to: $baseUrl/guru/siswa-list');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/guru/siswa-list'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 getSiswaList response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        List<User> siswaList = (responseData['data']['siswa'] as List)
            .map((siswa) => User.fromJson(siswa))
            .toList();

        print('✅ Parsed ${siswaList.length} siswa');

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
      print('❌ getSiswaList error: $e');
      return ApiResponse<List<User>>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // ============================================
  // GAME ENDPOINTS (SISWA) - ADDED
  // ============================================

  // Get available games
  Future<ApiResponse<Map<String, dynamic>>> getGames() async {
    print('🔍 Making getGames request to: $baseUrl/siswa/games');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/siswa/games'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 getGames response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: responseData['message'] ?? 'Success',
          data: responseData['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: responseData['message'] ?? 'Failed to get games',
        );
      }
    } catch (e) {
      print('❌ getGames error: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Get student badges
  Future<ApiResponse<Map<String, dynamic>>> getStudentBadges() async {
    print('🔍 Making getStudentBadges request to: $baseUrl/siswa/badges');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/siswa/badges'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 getStudentBadges response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: responseData['message'] ?? 'Success',
          data: responseData['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: responseData['message'] ?? 'Failed to get badges',
        );
      }
    } catch (e) {
      print('❌ getStudentBadges error: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Start new game session
  Future<ApiResponse<Map<String, dynamic>>> startGame(String gameId) async {
    print('🔍 Making startGame request to: $baseUrl/siswa/games/$gameId/start');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/siswa/games/$gameId/start'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🔍 startGame response status: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success']) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: responseData['message'] ?? 'Game started successfully',
          data: responseData['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: responseData['message'] ?? 'Failed to start game',
        );
      }
    } catch (e) {
      print('❌ startGame error: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }
}
