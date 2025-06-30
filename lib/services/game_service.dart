import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/game.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import 'storage_service.dart';
import '../models/detective_answer_submission.dart';

class GameService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      String? token = await _storageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        print('🔐 DEBUG: Using auth token: ${token.substring(0, 20)}...');
      } else {
        print('⚠️ WARNING: No auth token found');
      }
    }

    return headers;
  }

  T _safeJsonParse<T>(
    Map<String, dynamic> responseData,
    T Function(Map<String, dynamic>) parser,
    String context,
  ) {
    try {
      print('🔍 DEBUG: Parsing $context');
      print('🔍 DEBUG: Raw data: $responseData');

      final result = parser(responseData);
      print('✅ DEBUG: Successfully parsed $context');
      return result;
    } catch (e, stackTrace) {
      print('🚨 ERROR: Failed to parse $context');
      print('🚨 ERROR: $e');
      print('🚨 STACK: $stackTrace');
      print('🚨 DATA: $responseData');
      rethrow;
    }
  }

  dynamic _safeParseJsonResponse(String responseBody, String context) {
    try {
      print('🔍 DEBUG [$context]: Parsing response...');
      print('🔍 DEBUG [$context]: Response length: ${responseBody.length}');
      print(
          '🔍 DEBUG [$context]: First 200 chars: ${responseBody.substring(0, math.min(200, responseBody.length))}...');

      final decoded = jsonDecode(responseBody);
      print('🔍 DEBUG [$context]: Decoded type: ${decoded.runtimeType}');

      // ⚡ HANDLE DIFFERENT RESPONSE FORMATS
      if (decoded is List) {
        print(
            '📦 DEBUG [$context]: Server returned List with ${decoded.length} items');

        if (decoded.isEmpty) {
          return {
            'success': true,
            'data': {'all_completed': true}
          };
        }

        final firstItem = decoded[0];
        if (firstItem is Map) {
          print(
              '📦 DEBUG [$context]: Wrapping List item in expected structure');
          return {
            'success': true,
            'data': Map<String, dynamic>.from(firstItem)
          };
        } else {
          throw Exception(
              'List contains non-Map items: ${firstItem.runtimeType}');
        }
      }

      if (decoded is Map) {
        print('📦 DEBUG [$context]: Server returned Map');
        final map = Map<String, dynamic>.from(decoded);

        if (map.containsKey('success') && map.containsKey('data')) {
          return map;
        }

        print('📦 DEBUG [$context]: Wrapping raw Map in expected structure');
        return {'success': true, 'data': map};
      }

      throw Exception('Unexpected response type: ${decoded.runtimeType}');
    } catch (e) {
      print('❌ ERROR [$context]: Failed to parse JSON: $e');
      print('❌ ERROR [$context]: Raw response: $responseBody');
      throw Exception('JSON parsing failed for $context: $e');
    }
  }

  // ✅ EXISTING: Get all available games (unchanged)
  Future<ApiResponse<List<Game>>> getGames() async {
    try {
      print('🎮 DEBUG: Fetching games from API...');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/siswa/games'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🎮 DEBUG: API Response Status: ${response.statusCode}');
      print('🎮 DEBUG: API Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        List<Game> games = [];

        try {
          final gamesJsonList = responseData['data'] as List;
          print('🎮 DEBUG: Found ${gamesJsonList.length} games in response');

          for (int i = 0; i < gamesJsonList.length; i++) {
            try {
              final gameJson = gamesJsonList[i] as Map<String, dynamic>;
              print('🎮 DEBUG: Parsing game $i: ${gameJson['title']}');

              final game = _safeJsonParse(
                gameJson,
                (json) => Game.fromJson(json),
                'Game $i (${gameJson['title']})',
              );

              games.add(game);
              print('✅ DEBUG: Successfully added game: ${game.title}');
            } catch (e) {
              print('🚨 ERROR: Failed to parse game $i: $e');
            }
          }

          return ApiResponse<List<Game>>(
            success: true,
            message: responseData['message'] ?? 'Success',
            data: games,
          );
        } catch (e) {
          print('🚨 ERROR: Failed to parse games list: $e');
          return ApiResponse<List<Game>>(
            success: false,
            message: 'Failed to parse games data: $e',
          );
        }
      } else {
        return ApiResponse<List<Game>>(
          success: false,
          message: responseData['message'] ?? 'Failed to load games',
        );
      }
    } catch (e, stackTrace) {
      print('🚨 ERROR: Network error in getGames: $e');
      print('🚨 STACK: $stackTrace');

      return ApiResponse<List<Game>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // ✅ EXISTING: Start a new game session (unchanged)
  Future<GameStartResponse> startGame(int gameId) async {
    try {
      print('🎮 DEBUG: Starting game $gameId...');

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/siswa/games/$gameId/start'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🎮 DEBUG: Start game response: ${response.statusCode}');
      print('🎮 DEBUG: Start game body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        try {
          final sessionData =
              responseData['data']['session'] as Map<String, dynamic>;

          final session = _safeJsonParse(
            sessionData,
            (json) => GameSession.fromJson(json),
            'GameSession',
          );

          return GameStartResponse(
            success: true,
            message: responseData['message'],
            session: session,
            hasVideo: responseData['data']['has_video'] ?? false,
            videoPath: responseData['data']['video_path'],
          );
        } catch (e) {
          print('🚨 ERROR: Failed to parse game start response: $e');
          return GameStartResponse(
            success: false,
            message: 'Failed to parse session data: $e',
          );
        }
      } else {
        return GameStartResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to start game',
        );
      }
    } catch (e, stackTrace) {
      print('🚨 ERROR: Network error in startGame: $e');
      print('🚨 STACK: $stackTrace');

      return GameStartResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // ✅ EXISTING: Mark video as watched (unchanged)
  Future<ApiResponse<void>> markVideoWatched(int sessionId) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConstants.baseUrl}/siswa/games/sessions/$sessionId/mark-video-watched'),
        headers: await _getHeaders(includeAuth: true),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      return ApiResponse<void>(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'Video tracking failed',
      );
    } catch (e) {
      print('🚨 ERROR: markVideoWatched failed: $e');
      return ApiResponse<void>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // ✅ UPDATED: Get current question with additional data support
  Future<CurrentQuestionResponse> getCurrentQuestion(int sessionId) async {
    try {
      print('🎮 DEBUG: Getting current question for session $sessionId...');

      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/siswa/games/sessions/$sessionId/current-question'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🎮 DEBUG: Current question response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // ⚡ NEW: Safe parsing with format detection
        final responseData =
            _safeParseJsonResponse(response.body, 'getCurrentQuestion');

        if (responseData['success'] != true) {
          return CurrentQuestionResponse(
            success: false,
            message: responseData['message'] ?? 'Invalid response format',
          );
        }

        final data = responseData['data'] as Map<String, dynamic>;

        // Handle completion case
        if (data['all_completed'] == true) {
          print('✅ DEBUG: All questions completed');

          GameSession? session;
          if (data['session'] != null) {
            try {
              session = _safeJsonParse(
                Map<String, dynamic>.from(data['session']),
                (json) => GameSession.fromJson(json),
                'GameSession (completed)',
              );
            } catch (e) {
              print('⚠️ WARNING: Failed to parse completed session: $e');
            }
          }

          return CurrentQuestionResponse(
            success: true,
            message: 'All questions completed',
            allCompleted: true,
            session: session,
          );
        }

        // Parse question safely
        GameQuestion? question;
        if (data['question'] != null) {
          try {
            Map<String, dynamic> questionData;

            if (data['question'] is Map) {
              questionData = Map<String, dynamic>.from(data['question']);
            } else if (data['question'] is List &&
                (data['question'] as List).isNotEmpty) {
              questionData =
                  Map<String, dynamic>.from((data['question'] as List)[0]);
            } else {
              throw Exception(
                  'Invalid question format: ${data['question'].runtimeType}');
            }

            question = _safeJsonParse(
              questionData,
              (json) => GameQuestion.fromJson(json),
              'GameQuestion',
            );

            // print('✅ DEBUG: Question parsed successfully - ID: ${question.id}');
          } catch (e) {
            print('❌ ERROR: Failed to parse question: $e');
            return CurrentQuestionResponse(
              success: false,
              message: 'Failed to parse question data: $e',
            );
          }
        }

        // Parse options with enhanced safety
        List<LetterOption> options = [];
        if (data['options'] != null) {
          try {
            print('🔍 DEBUG: Processing options...');

            if (data['options'] is List) {
              final optionsList = data['options'] as List;

              for (int i = 0; i < optionsList.length; i++) {
                try {
                  final optionData = optionsList[i];

                  Map<String, dynamic> optionMap;
                  if (optionData is Map) {
                    optionMap = Map<String, dynamic>.from(optionData);
                  } else {
                    continue; // Skip invalid options
                  }

                  if (!optionMap.containsKey('letter')) {
                    continue; // Skip invalid options
                  }

                  final option = LetterOption.fromJson(optionMap);
                  options.add(option);
                } catch (e) {
                  print('❌ ERROR: Failed to parse option $i: $e');
                  // Continue with other options
                }
              }

              print('✅ DEBUG: Successfully parsed ${options.length} options');
            }
          } catch (e) {
            print('❌ ERROR: Failed to parse options: $e');
            options = [];
          }
        }

        // Parse progress safely
        QuestionProgress? progress;
        if (data['progress'] != null && data['progress'] is Map) {
          try {
            progress = _safeJsonParse(
              Map<String, dynamic>.from(data['progress']),
              (json) => QuestionProgress.fromJson(json),
              'QuestionProgress',
            );
          } catch (e) {
            print('⚠️ WARNING: Failed to parse progress: $e');
          }
        }

        // Parse session safely
        GameSession? session;
        if (data['session'] != null && data['session'] is Map) {
          try {
            session = _safeJsonParse(
              Map<String, dynamic>.from(data['session']),
              (json) => GameSession.fromJson(json),
              'GameSession',
            );
          } catch (e) {
            print('⚠️ WARNING: Failed to parse session: $e');
          }
        }

        // Extract additional data
        Map<String, dynamic> additionalData = {};
        if (data['additional_data'] is Map) {
          additionalData = Map<String, dynamic>.from(data['additional_data']);
        }

        // Check direct fields
        const directFields = [
          'word_pattern',
          'full_word',
          'correct_sequence',
          'level',
          'question_type'
        ];
        for (String field in directFields) {
          if (data.containsKey(field)) {
            additionalData[field] = data[field];
          }
        }

        return CurrentQuestionResponse(
          success: true,
          message: 'Question loaded successfully',
          allCompleted: false,
          question: question,
          options: options,
          progress: progress,
          session: session,
          additionalData: additionalData,
        );
      } else {
        print('❌ ERROR: HTTP ${response.statusCode}');

        String errorMessage = 'Server error (${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Use default error message
        }

        return CurrentQuestionResponse(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e, stackTrace) {
      print('❌ ERROR: Exception in getCurrentQuestion: $e');
      print('❌ STACK: $stackTrace');

      return CurrentQuestionResponse(
        success: false,
        message: 'Failed to load question: $e',
      );
    }
  }

  // ✅ EXISTING: Submit answer for regular games (unchanged)
  Future<AnswerResponse> submitAnswer(
    int sessionId,
    int questionId,
    AnswerSubmission submission,
  ) async {
    try {
      print(
          '🎮 DEBUG: Submitting answer for session $sessionId, question $questionId...');

      final response = await http.post(
        Uri.parse(
            '${AppConstants.baseUrl}/siswa/games/sessions/$sessionId/questions/$questionId/submit'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode(submission.toJson()),
      );

      print('🎮 DEBUG: Submit answer response: ${response.statusCode}');
      print('🎮 DEBUG: Submit answer body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return AnswerResponse(
          success: true,
          message: responseData['message'],
          isCorrect: responseData['data']['is_correct'] ?? false,
          correctAnswer: responseData['data']['correct_answer']?.toString(),
          sessionCompleted: responseData['data']['session_completed'] ?? false,
          feedbackAudio: responseData['data']['feedback_audio']?.toString(),
          canRetry: responseData['data']['can_retry'] ?? false,
        );
      } else {
        return AnswerResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to submit answer',
        );
      }
    } catch (e, stackTrace) {
      print('🚨 ERROR: Network error in submitAnswer: $e');
      print('🚨 STACK: $stackTrace');

      return AnswerResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // ✅ EXISTING: Submit answer for Detective Game (unchanged)
  Future<AnswerResponse> submitDetectiveAnswer(
    int sessionId,
    int questionId,
    DetectiveAnswerSubmission submission,
  ) async {
    try {
      print('🕵️ DEBUG: Submitting detective answer...');

      final response = await http.post(
        Uri.parse(
            '${AppConstants.baseUrl}/siswa/games/sessions/$sessionId/questions/$questionId/submit'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode(submission.toJson()),
      );

      print('🕵️ DEBUG: Response: ${response.statusCode}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return AnswerResponse(
          success: true,
          message: responseData['message'],
          isCorrect: responseData['data']['is_correct'] ?? false,
          correctAnswer: responseData['data']['correct_answer']?.toString(),
          sessionCompleted: responseData['data']['session_completed'] ?? false,
          feedbackAudio: responseData['data']['feedback_audio']?.toString(),
          canRetry: responseData['data']['can_retry'] ?? true,
        );
      } else {
        return AnswerResponse(
          success: false,
          message:
              responseData['message'] ?? 'Failed to submit detective answer',
        );
      }
    } catch (e) {
      print('🚨 ERROR: submitDetectiveAnswer failed: $e');
      return AnswerResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // ⚡ NEW: Submit answer for Spelling Game
  Future<AnswerResponse> submitSpellingAnswer(
    int sessionId,
    int questionId,
    SpellingAnswerSubmission submission,
  ) async {
    try {
      print('📚 DEBUG: Submitting spelling answer...');
      print('📚 DEBUG: Submission data: ${submission.toJson()}');

      final response = await http.post(
        Uri.parse(
            '${AppConstants.baseUrl}/siswa/games/sessions/$sessionId/questions/$questionId/submit'),
        headers: await _getHeaders(includeAuth: true),
        body: jsonEncode(submission.toJson()),
      );

      print('📚 DEBUG: Response: ${response.statusCode}');
      print('📚 DEBUG: Response body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        return AnswerResponse(
          success: true,
          message: responseData['message'],
          isCorrect: responseData['data']['is_correct'] ?? false,
          correctAnswer: responseData['data']['correct_answer']?.toString(),
          sessionCompleted: responseData['data']['session_completed'] ?? false,
          feedbackAudio: responseData['data']['feedback_audio']?.toString(),
          canRetry: responseData['data']['can_retry'] ?? false,
        );
      } else {
        return AnswerResponse(
          success: false,
          message:
              responseData['message'] ?? 'Failed to submit spelling answer',
        );
      }
    } catch (e, stackTrace) {
      print('🚨 ERROR: submitSpellingAnswer failed: $e');
      print('🚨 STACK: $stackTrace');

      return AnswerResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // ✅ EXISTING: Get session results (unchanged)
  Future<SessionResultResponse> getSessionResults(int sessionId) async {
    try {
      print('🎮 DEBUG: Getting session results for session $sessionId...');

      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/siswa/games/sessions/$sessionId/results'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🎮 DEBUG: Session results response: ${response.statusCode}');
      print('🎮 DEBUG: Session results body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        try {
          final sessionData =
              responseData['data']['session'] as Map<String, dynamic>;

          final session = _safeJsonParse(
            sessionData,
            (json) => GameSession.fromJson(json),
            'GameSession (results)',
          );

          StudentBadge? badge;
          if (responseData['data']['badge'] != null) {
            final badgeData =
                responseData['data']['badge'] as Map<String, dynamic>;
            badge = _safeJsonParse(
              badgeData,
              (json) => StudentBadge.fromJson(json),
              'StudentBadge',
            );
          }

          return SessionResultResponse(
            success: true,
            message: responseData['message'],
            session: session,
            badge: badge,
            canReplay: responseData['data']['can_replay'] ?? true,
          );
        } catch (e) {
          print('🚨 ERROR: Failed to parse session results: $e');
          return SessionResultResponse(
            success: false,
            message: 'Failed to parse results data: $e',
          );
        }
      } else {
        return SessionResultResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get session results',
        );
      }
    } catch (e, stackTrace) {
      print('🚨 ERROR: Network error in getSessionResults: $e');
      print('🚨 STACK: $stackTrace');

      return SessionResultResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // ✅ EXISTING: Get student badges (unchanged)
  Future<ApiResponse<List<StudentBadge>>> getStudentBadges() async {
    try {
      print('🎮 DEBUG: Getting student badges...');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/siswa/badges'),
        headers: await _getHeaders(includeAuth: true),
      );

      print('🎮 DEBUG: Badges response: ${response.statusCode}');
      print('🎮 DEBUG: Badges body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        try {
          List<StudentBadge> badges = [];
          final badgesJsonList = responseData['data'] as List;

          for (int i = 0; i < badgesJsonList.length; i++) {
            try {
              final badgeJson = badgesJsonList[i] as Map<String, dynamic>;
              final badge = _safeJsonParse(
                badgeJson,
                (json) => StudentBadge.fromJson(json),
                'StudentBadge $i',
              );
              badges.add(badge);
            } catch (e) {
              print('🚨 ERROR: Failed to parse badge $i: $e');
            }
          }

          return ApiResponse<List<StudentBadge>>(
            success: true,
            message: responseData['message'] ?? 'Success',
            data: badges,
          );
        } catch (e) {
          print('🚨 ERROR: Failed to parse badges list: $e');
          return ApiResponse<List<StudentBadge>>(
            success: false,
            message: 'Failed to parse badges data: $e',
          );
        }
      } else {
        return ApiResponse<List<StudentBadge>>(
          success: false,
          message: responseData['message'] ?? 'Failed to load badges',
        );
      }
    } catch (e, stackTrace) {
      print('🚨 ERROR: Network error in getStudentBadges: $e');
      print('🚨 STACK: $stackTrace');

      return ApiResponse<List<StudentBadge>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}

// ✅ EXISTING: Response classes (unchanged)
class GameStartResponse {
  final bool success;
  final String message;
  final GameSession? session;
  final bool hasVideo;
  final String? videoPath;

  GameStartResponse({
    required this.success,
    required this.message,
    this.session,
    this.hasVideo = false,
    this.videoPath,
  });
}

// ✅ UPDATED: Current question response with additional data
class CurrentQuestionResponse {
  final bool success;
  final String message;
  final bool allCompleted;
  final GameQuestion? question;
  final List<LetterOption> options;
  final QuestionProgress? progress;
  final GameSession? session;
  final Map<String, dynamic>
      additionalData; // ⚡ NEW: Additional data for spelling game

  CurrentQuestionResponse({
    required this.success,
    required this.message,
    this.allCompleted = false,
    this.question,
    this.options = const [],
    this.progress,
    this.session,
    this.additionalData = const {}, // ⚡ NEW: Default empty map
  });
}

class AnswerResponse {
  final bool success;
  final String message;
  final bool isCorrect;
  final String? correctAnswer;
  final bool sessionCompleted;
  final String? feedbackAudio;
  final bool canRetry;

  AnswerResponse({
    required this.success,
    required this.message,
    this.isCorrect = false,
    this.correctAnswer,
    this.sessionCompleted = false,
    this.feedbackAudio,
    this.canRetry = false,
  });
}

class SessionResultResponse {
  final bool success;
  final String message;
  final GameSession? session;
  final StudentBadge? badge;
  final bool canReplay;

  SessionResultResponse({
    required this.success,
    required this.message,
    this.session,
    this.badge,
    this.canReplay = true,
  });
}

// ⚡ NEW: Spelling Answer Submission class
class SpellingAnswerSubmission {
  final String? selectedLetter;
  final List<String>? selectedSequence;
  final String? teacherObservation;
  final String actionType;

  SpellingAnswerSubmission({
    this.selectedLetter,
    this.selectedSequence,
    this.teacherObservation,
    this.actionType = 'answer',
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'action_type': actionType,
    };

    if (selectedLetter != null) {
      json['selected_letter'] = selectedLetter;
    }

    if (selectedSequence != null && selectedSequence!.isNotEmpty) {
      json['selected_sequence'] = selectedSequence;
    }

    if (teacherObservation != null && teacherObservation!.isNotEmpty) {
      json['teacher_observation'] = teacherObservation;
    }

    return json;
  }
}
