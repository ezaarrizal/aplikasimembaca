// lib/providers/feedback_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/feedback.dart' as FeedbackModel;
import '../models/user.dart';
import '../services/api_service.dart';

class FeedbackProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  List<FeedbackModel.Feedback> _feedbacks = [];
  List<User> _siswaList = [];
  List<User> _children = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingSiswa = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasNextPage = false;
  int _unreadCount = 0;

  // Filters
  String _searchQuery = '';
  String _selectedSiswa = 'all';
  String _selectedKategori = 'all';
  String _selectedTingkat = 'all';
  bool _unreadOnly = false;

  Timer? _debounceTimer;

  // Getters
  List<FeedbackModel.Feedback> get feedbacks => _feedbacks;
  List<User> get siswaList => _siswaList;
  List<User> get children => _children;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingSiswa => _isLoadingSiswa;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  bool get hasNextPage => _hasNextPage;
  int get unreadCount => _unreadCount;

  String get searchQuery => _searchQuery;
  String get selectedSiswa => _selectedSiswa;
  String get selectedKategori => _selectedKategori;
  String get selectedTingkat => _selectedTingkat;
  bool get unreadOnly => _unreadOnly;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        loadFeedbacks(refresh: true);
      });
    }
  }

  // Set siswa filter
  void setSiswaFilter(String siswaId) {
    if (_selectedSiswa != siswaId) {
      _selectedSiswa = siswaId;
      loadFeedbacks(refresh: true);
    }
  }

  // Set kategori filter
  void setKategoriFilter(String kategori) {
    if (_selectedKategori != kategori) {
      _selectedKategori = kategori;
      loadFeedbacks(refresh: true);
    }
  }

  // Set tingkat filter
  void setTingkatFilter(String tingkat) {
    if (_selectedTingkat != tingkat) {
      _selectedTingkat = tingkat;
      loadFeedbacks(refresh: true);
    }
  }

  // Set unread only filter (for orangtua)
  void setUnreadFilter(bool unreadOnly) {
    if (_unreadOnly != unreadOnly) {
      _unreadOnly = unreadOnly;
      loadFeedbacksForParent(refresh: true);
    }
  }

  // Load feedbacks for Guru
  Future<void> loadFeedbacks({bool refresh = false}) async {
    print('🔍 DEBUG: loadFeedbacks called, refresh: $refresh');
    
    if (refresh) {
      _currentPage = 1;
      _feedbacks.clear();
      _hasNextPage = false;
    }

    if (_isLoading) return;

    _isLoading = refresh;
    _isLoadingMore = !refresh && _currentPage > 1;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getFeedbackList(
        page: _currentPage,
        siswaId: _selectedSiswa != 'all' ? _selectedSiswa : null,
        kategori: _selectedKategori != 'all' ? _selectedKategori : null,
        tingkat: _selectedTingkat != 'all' ? _selectedTingkat : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _feedbacks = response.data!.feedbacks;
        } else {
          _feedbacks.addAll(response.data!.feedbacks);
        }

        final pagination = response.data!.pagination;
        if (pagination != null) {
          _hasNextPage = pagination.hasNext;
        }
        
        print('✅ DEBUG: Loaded ${_feedbacks.length} feedbacks');
      } else {
        _errorMessage = response.message;
        print('❌ DEBUG: Load feedbacks error: ${response.message}');
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      print('💥 DEBUG: Load feedbacks exception: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load feedbacks for Orangtua (ALL feedbacks in system)
  Future<void> loadFeedbacksForParent({bool refresh = false}) async {
    print('🔍 DEBUG: loadFeedbacksForParent called, refresh: $refresh');
    
    if (refresh) {
      _currentPage = 1;
      _feedbacks.clear();
      _hasNextPage = false;
    }

    if (_isLoading) return;

    _isLoading = refresh;
    _isLoadingMore = !refresh && _currentPage > 1;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getFeedbackForParent(
        page: _currentPage,
        childId: _selectedSiswa != 'all' ? _selectedSiswa : null,
        unreadOnly: _unreadOnly,
      );

      print('🔍 DEBUG: getFeedbackForParent response: ${response.success}');

      if (response.success && response.data != null) {
        if (refresh) {
          _feedbacks = response.data!.feedbacks;
        } else {
          _feedbacks.addAll(response.data!.feedbacks);
        }

        _unreadCount = response.data!.unreadCount ?? 0;
        
        if (response.data!.children != null) {
          _children = response.data!.children!;
        }

        final pagination = response.data!.pagination;
        if (pagination != null) {
          _hasNextPage = pagination.hasNext;
        }
        
        print('✅ DEBUG: Loaded ${_feedbacks.length} feedbacks for parent, unread: $_unreadCount');
      } else {
        _errorMessage = response.message;
        print('❌ DEBUG: Load feedbacks for parent error: ${response.message}');
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      print('💥 DEBUG: Load feedbacks for parent exception: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load next page
  Future<void> loadNextPage({bool isParent = false}) async {
    if (!_hasNextPage || _isLoadingMore) return;

    _currentPage++;
    
    if (isParent) {
      await loadFeedbacksForParent();
    } else {
      await loadFeedbacks();
    }
  }

  // Load siswa list for dropdown
  Future<void> loadSiswaList() async {
    print('🔍 DEBUG: loadSiswaList() called');
    
    if (_isLoadingSiswa) {
      print('⚠️ DEBUG: loadSiswaList already in progress, skipping');
      return;
    }
    
    _isLoadingSiswa = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getSiswaList();
      print('🔍 DEBUG: Provider got response - Success: ${response.success}');

      if (response.success && response.data != null) {
        _siswaList = response.data!;
        print('✅ DEBUG: Updated _siswaList with ${_siswaList.length} items');
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
        print('❌ DEBUG: Error: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      print('💥 DEBUG: Provider Exception: $e');
    } finally {
      _isLoadingSiswa = false;
      notifyListeners();
      print('🔔 DEBUG: loadSiswaList completed, notifyListeners called');
    }
  }

  // Create feedback
  Future<bool> createFeedback({
    required String siswaId,
    required String judul,
    required String isiFeedback,
    required String kategori,
    required String tingkat,
  }) async {
    print('🔍 DEBUG: createFeedback called');
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.createFeedback(
        siswaId: siswaId,
        judul: judul,
        isiFeedback: isiFeedback,
        kategori: kategori,
        tingkat: tingkat,
      );

      if (response.success) {
        print('✅ DEBUG: Feedback created successfully');
        // Refresh feedback list
        await loadFeedbacks(refresh: true);
        return true;
      } else {
        _errorMessage = response.message;
        print('❌ DEBUG: Create feedback error: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      print('💥 DEBUG: Create feedback exception: $e');
      notifyListeners();
      return false;
    }
  }

  // Update feedback
  Future<bool> updateFeedback({
    required String feedbackId,
    required String judul,
    required String isiFeedback,
    required String kategori,
    required String tingkat,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.updateFeedback(
        feedbackId: feedbackId,
        judul: judul,
        isiFeedback: isiFeedback,
        kategori: kategori,
        tingkat: tingkat,
      );

      if (response.success) {
        // Update local feedback list
        final index = _feedbacks.indexWhere((f) => f.id.toString() == feedbackId);
        if (index != -1 && response.data != null) {
          _feedbacks[index] = response.data!.feedback;
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete feedback
  Future<bool> deleteFeedback(String feedbackId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.deleteFeedback(feedbackId);

      if (response.success) {
        // Remove from local list
        _feedbacks.removeWhere((f) => f.id.toString() == feedbackId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // Mark feedback as read
  Future<bool> markAsRead(String feedbackId) async {
    try {
      final response = await _apiService.markFeedbackAsRead(feedbackId);

      if (response.success) {
        // Update local feedback
        final index = _feedbacks.indexWhere((f) => f.id.toString() == feedbackId);
        if (index != -1) {
          final currentFeedback = _feedbacks[index];
          final updatedFeedback = FeedbackModel.Feedback(
            id: currentFeedback.id,
            guruId: currentFeedback.guruId,
            siswaId: currentFeedback.siswaId,
            judul: currentFeedback.judul,
            isiFeedback: currentFeedback.isiFeedback,
            kategori: currentFeedback.kategori,
            tingkat: currentFeedback.tingkat,
            isReadByParent: true,
            readAt: DateTime.now().toIso8601String(),
            createdAt: currentFeedback.createdAt,
            updatedAt: currentFeedback.updatedAt,
            formattedDate: currentFeedback.formattedDate,
            guru: currentFeedback.guru,
            siswa: currentFeedback.siswa,
          );
          
          _feedbacks[index] = updatedFeedback;
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}