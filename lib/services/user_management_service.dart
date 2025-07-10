import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/api_response.dart';
import '../models/user_statistics.dart';
// import '../models/pagination_info.dart';
import '../models/user_list_response.dart';
import 'storage_service.dart';

class UserManagementService {
  static const String baseUrl =
      'https://echo-web-production-5353.up.railway.app/api/v1';
  final StorageService _storageService = StorageService();

  // Headers untuk API calls
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all users with pagination and filtering
  Future<ApiResponse<UserListResponse>> getUsers({
    String? role,
    String? search,
    String? status,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (role != null && role != 'all') queryParams['role'] = role;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/guru/users')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: await _getHeaders());
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return ApiResponse<UserListResponse>(
          success: true,
          message: responseData['message'],
          data: UserListResponse.fromJson(responseData['data']),
        );
      } else {
        return ApiResponse<UserListResponse>(
          success: false,
          message: responseData['message'] ?? 'Failed to get users',
        );
      }
    } catch (e) {
      return ApiResponse<UserListResponse>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Create new user
  Future<ApiResponse<User>> createUser({
    required String username,
    required String password,
    required String nama,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guru/users'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'username': username,
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
          message: responseData['message'] ?? 'Failed to create user',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Get specific user
  Future<ApiResponse<User>> getUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/guru/users/$userId'),
        headers: await _getHeaders(),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return ApiResponse<User>(
          success: true,
          message: responseData['message'],
          data: User.fromJson(responseData['data']['user']),
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: responseData['message'] ?? 'Failed to get user',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Update user
  Future<ApiResponse<User>> updateUser({
    required int userId,
    required String username,
    String? password,
    required String nama,
    required String role,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{
        'username': username,
        'nama': nama,
        'role': role,
      };

      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      if (isActive != null) {
        body['is_active'] = isActive;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/guru/users/$userId'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return ApiResponse<User>(
          success: true,
          message: responseData['message'],
          data: User.fromJson(responseData['data']['user']),
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: responseData['message'] ?? 'Failed to update user',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Delete/Deactivate user
  Future<ApiResponse<void>> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/guru/users/$userId'),
        headers: await _getHeaders(),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      return ApiResponse<void>(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Failed to delete user',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Toggle user status
  Future<ApiResponse<User>> toggleUserStatus(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guru/users/$userId/toggle-status'),
        headers: await _getHeaders(),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return ApiResponse<User>(
          success: true,
          message: responseData['message'],
          data: User.fromJson(responseData['data']['user']),
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: responseData['message'] ?? 'Failed to toggle user status',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }

  // Get user statistics
  Future<ApiResponse<UserStatistics>> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/guru/users/statistics'),
        headers: await _getHeaders(),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return ApiResponse<UserStatistics>(
          success: true,
          message: responseData['message'],
          data: UserStatistics.fromJson(responseData['data']),
        );
      } else {
        return ApiResponse<UserStatistics>(
          success: false,
          message: responseData['message'] ?? 'Failed to get statistics',
        );
      }
    } catch (e) {
      return ApiResponse<UserStatistics>(
        success: false,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }
}
