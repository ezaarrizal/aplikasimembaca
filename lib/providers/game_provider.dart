// lib/providers/game_provider.dart - FIXED VERSION

import 'package:flutter/foundation.dart';
import '../models/game.dart';
import '../services/game_service.dart';
import '../models/detective_answer_submission.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();

  // State variables
  List<Game> _games = [];
  bool _isLoading = false;
  String? _error;

  // Current game session state
  GameSession? _currentSession;
  GameQuestion? _currentQuestion;
  List<LetterOption> _currentOptions = [];
  QuestionProgress? _currentProgress;

  // ⚡ NEW: Additional data for spelling game
  Map<String, dynamic> _additionalData = {};

  // Video state (optional now)
  bool _hasVideo = false;
  String? _videoPath;
  bool _videoWatched = false;

  // Student badges
  List<StudentBadge> _badges = [];
  bool _badgesLoading = false;

  // Getters
  List<Game> get games => _games;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GameSession? get currentSession => _currentSession;
  GameQuestion? get currentQuestion => _currentQuestion;
  List<LetterOption> get currentOptions => _currentOptions;
  QuestionProgress? get currentProgress => _currentProgress;

  // ⚡ NEW: Additional data getter for spelling game
  Map<String, dynamic> get additionalData => _additionalData;
  String? get wordPattern => _additionalData['word_pattern'] as String?;
  String? get fullWord => _additionalData['full_word'] as String?;
  List<String>? get correctSequence =>
      _additionalData['correct_sequence'] as List<String>?;

  // Video getters (optional)
  bool get hasVideo => _hasVideo;
  String? get videoPath => _videoPath;
  bool get videoWatched => _videoWatched;

  List<StudentBadge> get badges => _badges;
  bool get badgesLoading => _badgesLoading;

  // Helper getters
  bool get hasError => _error != null;
  bool get hasGames => _games.isNotEmpty;
  bool get hasCurrentSession => _currentSession != null;
  bool get hasCurrentQuestion => _currentQuestion != null;
  bool get hasBadges => _badges.isNotEmpty;

  // ⚡ NEW: Game type detection
  bool get isSpellingGame => _currentSession?.game?.title == 'Belajar Mengeja';
  bool get isDetectiveGame => _currentSession?.game?.title == 'Detektif Huruf';
  bool get isVocalGame =>
      _currentSession?.game?.title == 'Permainan Huruf Vokal';

  // Load games method
  Future<void> loadGames() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _gameService.getGames();

      if (response.success && response.data != null) {
        _games = response.data!;
        _setError(null);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Start game method
  Future<bool> startGame(int gameId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _gameService.startGame(gameId);

      if (response.success && response.session != null) {
        _currentSession = response.session;
        _hasVideo = response.hasVideo;
        _videoPath = response.videoPath;
        _videoWatched = false;

        _setError(null);
        notifyListeners();

        await loadCurrentQuestion();

        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mark video as watched
  Future<bool> markVideoWatched() async {
    if (_currentSession == null) return false;

    try {
      final response = await _gameService.markVideoWatched(_currentSession!.id);

      if (response.success) {
        _videoWatched = true;
        notifyListeners();
        return true;
      } else {
        debugPrint('Video tracking failed: ${response.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Video tracking error: $e');
      return false;
    }
  }

  // Load current question - UPDATED with additional data support
  Future<bool> loadCurrentQuestion() async {
    if (_currentSession == null) return false;

    try {
      print(
          '🎮 DEBUG: Loading current question for session ${_currentSession!.id}...');

      final response =
          await _gameService.getCurrentQuestion(_currentSession!.id);

      print(
          '🎮 DEBUG: getCurrentQuestion response success: ${response.success}');

      if (response.success) {
        if (response.allCompleted) {
          print('🎮 DEBUG: All questions completed');
          _currentQuestion = null;
          _currentOptions = [];
          _currentProgress = null;
          _additionalData = {}; // ⚡ NEW: Clear additional data
          if (response.session != null) {
            _currentSession = response.session;
          }
        } else {
          print('🎮 DEBUG: Got question: ${response.question?.id}');
          print('🎮 DEBUG: Got ${response.options.length} options');

          if (response.question == null) {
            throw Exception('Question data is null despite success response');
          }

          if (response.options.isEmpty &&
              response.question!.safeQuestionType != 'read_sentence') {
            // Only require options for non-reading questions
            throw Exception(
                'No options received for question ${response.question!.id}');
          }

          // Log options for debugging
          for (int i = 0; i < response.options.length; i++) {
            final option = response.options[i];
            print('🔍 DEBUG: Option $i: ${option.letter}');
          }

          _currentQuestion = response.question;
          _currentOptions = response.options;
          _currentProgress = response.progress;
          _additionalData =
              response.additionalData; // ⚡ NEW: Store additional data

          if (response.session != null) {
            _currentSession = response.session;
          }

          // ⚡ NEW: Log additional data for spelling game
          if (isSpellingGame) {
            print('📚 DEBUG: Spelling game additional data: $_additionalData');
          }
        }

        _setError(null);
        notifyListeners();
        return true;
      } else {
        print('🚨 ERROR: getCurrentQuestion failed: ${response.message}');
        _setError(response.message);
        return false;
      }
    } catch (e, stackTrace) {
      print('🚨 ERROR: Exception in loadCurrentQuestion: $e');
      print('🚨 STACK: $stackTrace');
      _setError('Terjadi kesalahan saat memuat pertanyaan: $e');
      return false;
    }
  }

  // Submit answer for regular games (vocal game)
  Future<AnswerResult?> submitAnswer(String selectedLetter,
      {String? teacherObservation}) async {
    if (_currentSession == null || _currentQuestion == null) {
      print('🚨 ERROR: Cannot submit answer - session or question is null');
      _setError('Session atau pertanyaan tidak valid');
      return null;
    }

    try {
      print(
          '🎮 DEBUG: Submitting answer: $selectedLetter for question ${_currentQuestion!.id}');

      final submission = AnswerSubmission(
        selectedLetter: selectedLetter,
        teacherObservation: teacherObservation,
      );

      print('🎮 DEBUG: Submission data: ${submission.toJson()}');

      final response = await _gameService.submitAnswer(
        _currentSession!.id,
        _currentQuestion!.id,
        submission,
      );

      print('🎮 DEBUG: Submit answer response success: ${response.success}');
      print('🎮 DEBUG: Is correct: ${response.isCorrect}');

      if (response.success) {
        final result = AnswerResult(
          isCorrect: response.isCorrect,
          correctAnswer: response.correctAnswer ?? '',
          sessionCompleted: response.sessionCompleted,
          message: response.message,
        );

        if (response.isCorrect) {
          print('🎮 DEBUG: Answer is correct, updating session state');

          List<int> completed = List.from(_currentSession!.questionsCompleted);
          if (!completed.contains(_currentQuestion!.id)) {
            completed.add(_currentQuestion!.id);
            print(
                '🎮 DEBUG: Added question ${_currentQuestion!.id} to completed list');
          }

          _currentSession = GameSession(
            id: _currentSession!.id,
            studentId: _currentSession!.studentId,
            gameId: _currentSession!.gameId,
            startedAt: _currentSession!.startedAt,
            completedAt: response.sessionCompleted
                ? DateTime.now().toIso8601String()
                : _currentSession!.completedAt,
            videoWatched: _currentSession!.videoWatched,
            videoCompletedAt: _currentSession!.videoCompletedAt,
            questionsCompleted: completed,
            status: response.sessionCompleted
                ? 'completed'
                : _currentSession!.status,
            teacherNotes: _currentSession!.teacherNotes,
            createdAt: _currentSession!.createdAt,
            updatedAt: _currentSession!.updatedAt,
            game: _currentSession!.game,
          );

          print(
              '🎮 DEBUG: Updated session with ${completed.length} completed questions');

          if (response.sessionCompleted) {
            print('🎮 DEBUG: Session completed!');
          }
        }

        _setError(null);
        notifyListeners();
        return result;
      } else {
        print('🚨 ERROR: Submit answer failed: ${response.message}');
        _setError(response.message);
        return null;
      }
    } catch (e, stackTrace) {
      print('🚨 ERROR: Exception in submitAnswer: $e');
      print('🚨 STACK: $stackTrace');
      _setError('Terjadi kesalahan saat mengirim jawaban: $e');
      return null;
    }
  }

  // Submit answer for Detective Game (use dedicated DetectiveAnswerSubmission)
  Future<AnswerResult?> submitDetectiveAnswer(
    String selectedLetter, {
    required bool isCorrect,
    String? teacherObservation,
  }) async {
    if (_currentSession == null || _currentQuestion == null) {
      print(
          '🚨 ERROR: Cannot submit detective answer - session or question is null');
      _setError('Session atau pertanyaan tidak valid');
      return null;
    }

    try {
      print(
          '🕵️ DEBUG: Submitting detective answer: $selectedLetter (teacher says: ${isCorrect ? "CORRECT" : "WRONG"})');

      final submission = DetectiveAnswerSubmission(
        selectedLetter: selectedLetter,
        isCorrect: isCorrect,
        teacherObservation: teacherObservation,
      );

      print('🕵️ DEBUG: Detective submission data: ${submission.toJson()}');

      final response = await _gameService.submitDetectiveAnswer(
        _currentSession!.id,
        _currentQuestion!.id,
        submission,
      );

      print(
          '🕵️ DEBUG: Submit detective answer response success: ${response.success}');
      print('🕵️ DEBUG: Can retry: ${response.canRetry}');

      if (response.success) {
        final result = AnswerResult(
          isCorrect: response.isCorrect,
          correctAnswer: response.correctAnswer ?? '',
          sessionCompleted: response.sessionCompleted,
          message: response.message,
          canRetry: response.canRetry,
        );

        // DETECTIVE LOGIC: Always mark as attempted (regardless of correctness)
        print('🕵️ DEBUG: Marking question as attempted for detective game');

        List<int> completed = List.from(_currentSession!.questionsCompleted);
        if (!completed.contains(_currentQuestion!.id)) {
          completed.add(_currentQuestion!.id);
          print(
              '🕵️ DEBUG: Added question ${_currentQuestion!.id} to completed list');
        }

        _currentSession = GameSession(
          id: _currentSession!.id,
          studentId: _currentSession!.studentId,
          gameId: _currentSession!.gameId,
          startedAt: _currentSession!.startedAt,
          completedAt: response.sessionCompleted
              ? DateTime.now().toIso8601String()
              : _currentSession!.completedAt,
          videoWatched: _currentSession!.videoWatched,
          videoCompletedAt: _currentSession!.videoCompletedAt,
          questionsCompleted: completed,
          status:
              response.sessionCompleted ? 'completed' : _currentSession!.status,
          teacherNotes: _currentSession!.teacherNotes,
          createdAt: _currentSession!.createdAt,
          updatedAt: _currentSession!.updatedAt,
          game: _currentSession!.game,
        );

        print(
            '🕵️ DEBUG: Updated detective session with ${completed.length} completed questions');

        if (response.sessionCompleted) {
          print('🕵️ DEBUG: Detective session completed!');
        }

        _setError(null);
        notifyListeners();
        return result;
      } else {
        print('🚨 ERROR: Submit detective answer failed: ${response.message}');
        _setError(response.message);
        return null;
      }
    } catch (e, stackTrace) {
      print('🚨 ERROR: Exception in submitDetectiveAnswer: $e');
      print('🚨 STACK: $stackTrace');
      _setError('Terjadi kesalahan saat mengirim jawaban detektif: $e');
      return null;
    }
  }

  // ⚡ FIXED: Submit answer for Spelling Game - using SpellingAnswerSubmission from game_service.dart
  Future<AnswerResult?> submitSpellingAnswer({
    String? selectedLetter,
    List<String>? selectedSequence,
    String? teacherObservation,
    String actionType = 'answer',
  }) async {
    if (_currentSession == null || _currentQuestion == null) {
      print(
          '🚨 ERROR: Cannot submit spelling answer - session or question is null');
      _setError('Session atau pertanyaan tidak valid');
      return null;
    }

    try {
      print('📚 DEBUG: Submitting spelling answer...');
      print('📚 DEBUG: Selected letter: $selectedLetter');
      print('📚 DEBUG: Selected sequence: $selectedSequence');
      print('📚 DEBUG: Action type: $actionType');

      final submission = SpellingAnswerSubmission(
        selectedLetter: selectedLetter,
        selectedSequence: selectedSequence,
        teacherObservation: teacherObservation,
        actionType: actionType,
      );

      print('📚 DEBUG: Spelling submission data: ${submission.toJson()}');

      final response = await _gameService.submitSpellingAnswer(
        _currentSession!.id,
        _currentQuestion!.id,
        submission,
      );

      print(
          '📚 DEBUG: Submit spelling answer response success: ${response.success}');
      print('📚 DEBUG: Is correct: ${response.isCorrect}');

      if (response.success) {
        final result = AnswerResult(
          isCorrect: response.isCorrect,
          correctAnswer: response.correctAnswer ?? '',
          sessionCompleted: response.sessionCompleted,
          message: response.message,
          canRetry: response.canRetry,
        );

        // SPELLING LOGIC: Update based on question type
        final questionType = _currentQuestion!.safeQuestionType;

        if (questionType == 'read_sentence' || response.isCorrect) {
          // Mark as completed for reading sentences or correct answers
          print('📚 DEBUG: Marking question as completed');

          List<int> completed = List.from(_currentSession!.questionsCompleted);
          if (!completed.contains(_currentQuestion!.id)) {
            completed.add(_currentQuestion!.id);
            print(
                '📚 DEBUG: Added question ${_currentQuestion!.id} to completed list');
          }

          _currentSession = GameSession(
            id: _currentSession!.id,
            studentId: _currentSession!.studentId,
            gameId: _currentSession!.gameId,
            startedAt: _currentSession!.startedAt,
            completedAt: response.sessionCompleted
                ? DateTime.now().toIso8601String()
                : _currentSession!.completedAt,
            videoWatched: _currentSession!.videoWatched,
            videoCompletedAt: _currentSession!.videoCompletedAt,
            questionsCompleted: completed,
            status: response.sessionCompleted
                ? 'completed'
                : _currentSession!.status,
            teacherNotes: _currentSession!.teacherNotes,
            createdAt: _currentSession!.createdAt,
            updatedAt: _currentSession!.updatedAt,
            game: _currentSession!.game,
          );

          print(
              '📚 DEBUG: Updated spelling session with ${completed.length} completed questions');

          if (response.sessionCompleted) {
            print('📚 DEBUG: Spelling session completed!');
          }
        }

        _setError(null);
        notifyListeners();
        return result;
      } else {
        print('🚨 ERROR: Submit spelling answer failed: ${response.message}');
        _setError(response.message);
        return null;
      }
    } catch (e, stackTrace) {
      print('🚨 ERROR: Exception in submitSpellingAnswer: $e');
      print('🚨 STACK: $stackTrace');
      _setError('Terjadi kesalahan saat mengirim jawaban spelling: $e');
      return null;
    }
  }

  // Get session results
  Future<SessionResult?> getSessionResults() async {
    if (_currentSession == null) return null;

    try {
      final response =
          await _gameService.getSessionResults(_currentSession!.id);

      if (response.success) {
        if (response.session != null) {
          _currentSession = response.session;
        }

        _setError(null);
        notifyListeners();

        return SessionResult(
          session: response.session!,
          badge: response.badge,
          canReplay: response.canReplay,
        );
      } else {
        _setError(response.message);
        return null;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
      return null;
    }
  }

  // Load student badges
  Future<void> loadBadges() async {
    _setBadgesLoading(true);

    try {
      final response = await _gameService.getStudentBadges();

      if (response.success && response.data != null) {
        _badges = response.data!;
      } else {
        debugPrint('Failed to load badges: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error loading badges: $e');
    } finally {
      _setBadgesLoading(false);
    }
  }

  // Reset current game state
  void resetCurrentGame() {
    _currentSession = null;
    _currentQuestion = null;
    _currentOptions = [];
    _currentProgress = null;
    _additionalData = {}; // ⚡ NEW: Clear additional data
    _hasVideo = false;
    _videoPath = null;
    _videoWatched = false;
    _clearError();
    notifyListeners();
  }

  // Refresh games and badges
  Future<void> refresh() async {
    await Future.wait([
      loadGames(),
      loadBadges(),
    ]);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setBadgesLoading(bool loading) {
    _badgesLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Helper methods
  Game? getGameById(int gameId) {
    try {
      return _games.firstWhere((game) => game.id == gameId);
    } catch (e) {
      return null;
    }
  }

  int getBadgeCountForGame(int gameId) {
    return _badges.where((badge) => badge.gameId == gameId).length;
  }

  bool hasCompletedGame(int gameId) {
    final game = getGameById(gameId);
    return game?.isCompleted ?? false;
  }

  int get totalBadges => _badges.length;
}

// Helper classes
class AnswerResult {
  final bool isCorrect;
  final String correctAnswer;
  final bool sessionCompleted;
  final String message;
  final bool canRetry; // For detective game

  AnswerResult({
    required this.isCorrect,
    required this.correctAnswer,
    required this.sessionCompleted,
    required this.message,
    this.canRetry = false, // Default false for regular games
  });
}

class SessionResult {
  final GameSession session;
  final StudentBadge? badge;
  final bool canReplay;

  SessionResult({
    required this.session,
    this.badge,
    required this.canReplay,
  });
}

// ⚡ REMOVED: SpellingAnswerSubmission class (use the one from game_service.dart)
