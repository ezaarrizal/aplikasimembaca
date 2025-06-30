import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_statistics.dart';
import '../models/pagination_info.dart';
import '../services/user_management_service.dart';

class UserManagementProvider with ChangeNotifier {
  final UserManagementService _service = UserManagementService();

  List<User> _users = [];
  PaginationInfo? _pagination;
  UserStatistics? _statistics;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filters
  String _selectedRole = 'all';
  String _searchQuery = '';
  String _selectedStatus = 'all';
  int _currentPage = 1;

  // Debounce timer
  Timer? _debounceTimer;
  bool _disposed = false;

  // Getters
  List<User> get users => _users;
  PaginationInfo? get pagination => _pagination;
  UserStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedRole => _selectedRole;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  int get currentPage => _currentPage;

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Load users with filters
  Future<void> loadUsers({bool refresh = false}) async {
    if (_disposed) return;

    if (refresh) {
      _currentPage = 1;
      _users.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final response = await _service.getUsers(
        role: _selectedRole,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _selectedStatus != 'all' ? _selectedStatus : null,
        page: _currentPage,
        perPage: 10,
      );

      if (_disposed) return;

      if (response.success && response.data != null) {
        if (refresh) {
          _users = response.data!.users;
        } else {
          _users.addAll(response.data!.users);
        }
        _pagination = response.data!.pagination;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = 'Gagal memuat data: $e';
      }
    }

    if (!_disposed) {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (_pagination?.hasNext == true && !_isLoading && !_disposed) {
      _currentPage++;
      await loadUsers();
    }
  }

  // Set filters with debouncing
  void setRoleFilter(String role) {
    if (_disposed) return;
    _selectedRole = role;
    _debounceLoadUsers();
  }

  void setStatusFilter(String status) {
    if (_disposed) return;
    _selectedStatus = status;
    _debounceLoadUsers();
  }

  void setSearchQuery(String query) {
    if (_disposed) return;
    _searchQuery = query;
    _debounceLoadUsers();
  }

  void _debounceLoadUsers() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_disposed) {
        loadUsers(refresh: true);
      }
    });
  }

  // Create user
  Future<bool> createUser({
    required String username,
    required String password,
    required String nama,
    required String role,
  }) async {
    if (_disposed) return false;
    
    _errorMessage = null;

    try {
      final response = await _service.createUser(
        username: username,
        password: password,
        nama: nama,
        role: role,
      );

      if (_disposed) return false;

      if (response.success) {
        // Delay untuk memastikan backend sudah update
        await Future.delayed(const Duration(milliseconds: 500));
        if (!_disposed) {
          await loadUsers(refresh: true);
          await loadStatistics();
        }
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = 'Gagal menambah user: $e';
      }
      return false;
    }
  }

  // Update user
  Future<bool> updateUser({
    required int userId,
    required String username,
    String? password,
    required String nama,
    required String role,
    bool? isActive,
  }) async {
    if (_disposed) return false;
    
    _errorMessage = null;

    try {
      final response = await _service.updateUser(
        userId: userId,
        username: username,
        password: password,
        nama: nama,
        role: role,
        isActive: isActive,
      );

      if (_disposed) return false;

      if (response.success) {
        // Delay untuk memastikan backend sudah update
        await Future.delayed(const Duration(milliseconds: 500));
        if (!_disposed) {
          await loadUsers(refresh: true);
          await loadStatistics();
        }
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = 'Gagal mengupdate user: $e';
      }
      return false;
    }
  }

  // Delete user - Simplified with better error handling
  Future<bool> deleteUser(int userId) async {
    if (_disposed) return false;
    
    _errorMessage = null;

    try {
      final response = await _service.deleteUser(userId);

      if (_disposed) return false;

      if (response.success) {
        // Simple delay then refresh
        await Future.delayed(const Duration(milliseconds: 300));
        if (!_disposed) {
          await loadUsers(refresh: true);
          await loadStatistics();
        }
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = 'Gagal menghapus user: $e';
      }
      return false;
    }
  }

  // Toggle user status - Simplified with better error handling
  Future<bool> toggleUserStatus(int userId) async {
    if (_disposed) return false;
    
    _errorMessage = null;

    try {
      final response = await _service.toggleUserStatus(userId);

      if (_disposed) return false;

      if (response.success) {
        // Simple delay then refresh
        await Future.delayed(const Duration(milliseconds: 300));
        if (!_disposed) {
          await loadUsers(refresh: true);
          await loadStatistics();
        }
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = 'Gagal mengubah status user: $e';
      }
      return false;
    }
  }

  // Load statistics
  Future<void> loadStatistics() async {
    if (_disposed) return;
    
    try {
      final response = await _service.getStatistics();
      if (!_disposed && response.success && response.data != null) {
        _statistics = response.data;
        _safeNotifyListeners();
      }
    } catch (e) {
      // Silent fail for statistics
      debugPrint('Failed to load statistics: $e');
    }
  }

  // Clear error
  void clearError() {
    if (_disposed) return;
    _errorMessage = null;
    _safeNotifyListeners();
  }

  // Reset filters
  void resetFilters() {
    if (_disposed) return;
    _selectedRole = 'all';
    _searchQuery = '';
    _selectedStatus = 'all';
    _currentPage = 1;
    loadUsers(refresh: true);
  }
}