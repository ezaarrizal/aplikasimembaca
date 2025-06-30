import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  AuthStatus _status = AuthStatus.loading;
  User? _user;
  String? _errorMessage;
  bool _disposed = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Initialize auth state
  Future<void> initializeAuth() async {
    if (_disposed) return;
    
    _status = AuthStatus.loading;
    _safeNotifyListeners();

    try {
      bool loggedIn = await _storageService.isLoggedIn();
      if (_disposed) return;
      
      if (loggedIn) {
        _user = await _storageService.getUser();
        if (_disposed) return;
        
        if (_user != null) {
          // Verify token dengan server
          final response = await _apiService.getCurrentUser();
          if (_disposed) return;
          
          if (response.success && response.data != null) {
            _user = response.data;
            _status = AuthStatus.authenticated;
          } else {
            // Token invalid, logout
            await logout();
          }
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      if (!_disposed) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Failed to initialize auth: $e';
      }
    }

    _safeNotifyListeners();
  }

  // Login
  Future<bool> login(String username, String password) async {
    if (_disposed) return false;
    
    _status = AuthStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final response = await _apiService.login(username, password);
      if (_disposed) return false;
      
      if (response.success && response.data != null) {
        _user = response.data!.user;
        await _storageService.saveAuthData(response.data!.token, _user!);
        if (_disposed) return false;
        
        _status = AuthStatus.authenticated;
        _safeNotifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _status = AuthStatus.unauthenticated;
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = 'Login failed: $e';
        _status = AuthStatus.unauthenticated;
        _safeNotifyListeners();
      }
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    if (_disposed) return;
    
    try {
      // Call logout API
      await _apiService.logout();
    } catch (e) {
      // Even if API call fails, still logout locally
      debugPrint('Logout API failed: $e');
    }

    if (_disposed) return;

    // Clear local storage
    await _storageService.clearAuthData();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    _safeNotifyListeners();
  }

  // Register user (untuk guru)
  Future<bool> registerUser({
    required String username,
    String? email,
    required String password,
    required String nama,
    required String role,
  }) async {
    if (_disposed) return false;
    
    _errorMessage = null;
    
    try {
      final response = await _apiService.registerUser(
        username: username,
        email: email,
        password: password,
        nama: nama,
        role: role,
      );

      if (_disposed) return false;

      if (response.success) {
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = 'Registration failed: $e';
      }
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_disposed) return false;
    
    _errorMessage = null;

    if (newPassword != confirmPassword) {
      _errorMessage = 'Password baru tidak cocok';
      return false;
    }

    try {
      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: confirmPassword,
      );

      if (_disposed) return false;

      if (response.success) {
        // Force logout after password change
        await logout();
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = 'Change password failed: $e';
      }
      return false;
    }
  }

  // Clear error message
  void clearError() {
    if (_disposed) return;
    _errorMessage = null;
    _safeNotifyListeners();
  }
}