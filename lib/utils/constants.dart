// lib/utils/constants.dart - UPDATED with Game Constants
import 'package:flutter/material.dart';

class AppConstants {
  // 👈 EXISTING: API Constants - Pastikan URL ini sesuai dengan server Laravel Anda
  static const String baseUrl = 'http://localhost:8000/api/v1'; // Untuk development
  // static const String baseUrl = 'http://192.168.1.100:8000/api/v1'; // Untuk testing di device fisik
  // static const String baseUrl = 'https://yourdomain.com/api/v1'; // Untuk production
  
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String userEndpoint = '/auth/user';
  
  // 👈 EXISTING: Game API endpoints
  static const String gamesEndpoint = '/siswa/games';
  static const String startGameEndpoint = '/siswa/games/{id}/start';
  static const String currentQuestionEndpoint = '/siswa/games/sessions/{sessionId}/current-question';
  static const String submitAnswerEndpoint = '/siswa/games/sessions/{sessionId}/questions/{questionId}/submit';
  static const String sessionResultsEndpoint = '/siswa/games/sessions/{sessionId}/results';
  static const String markVideoWatchedEndpoint = '/siswa/games/sessions/{sessionId}/mark-video-watched';
  static const String badgesEndpoint = '/siswa/badges';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Roles
  static const String roleGuru = 'guru';
  static const String roleSiswa = 'siswa';
  static const String roleOrangtua = 'orangtua';

  // ⚡ NEW: Game Types
  static const String VOCAL_GAME = 'vocal';
  static const String DETECTIVE_GAME = 'detective';
  static const String SPELLING_GAME = 'spelling';

  // ⚡ NEW: Game Titles
  static const String VOCAL_GAME_TITLE = 'Permainan Huruf Vokal';
  static const String DETECTIVE_GAME_TITLE = 'Detektif Huruf';
  static const String SPELLING_GAME_TITLE = 'Belajar Mengeja';

  // ⚡ NEW: Question Types
  static const String VOCAL_FILL = 'vocal_fill';
  static const String FILL_BLANK = 'fill_blank';
  static const String FIND_DIFFERENCE = 'find_difference';
  static const String DRAG_MATCH = 'drag_match';
  static const String COMPLETE_WORD = 'complete_word';
  static const String ARRANGE_SYLLABLES = 'arrange_syllables';
  static const String READ_SENTENCE = 'read_sentence';

  // ⚡ NEW: Asset Paths
  static const String VOCAL_ASSETS = 'assets/games/vowels/';
  static const String DETECTIVE_ASSETS = 'assets/games/detective/';
  static const String SPELLING_ASSETS = 'assets/games/spelling/';

  // ⚡ NEW: Audio Paths
  static const String VOCAL_AUDIO = 'assets/games/vowels/audio/';
  static const String DETECTIVE_AUDIO = 'assets/games/detective/audio/';
  static const String SPELLING_AUDIO = 'assets/games/spelling/audio/';

  // ⚡ NEW: Badge Names
  static const String VOCAL_BADGE = 'Ahli Huruf Vokal';
  static const String DETECTIVE_BADGE = 'Detektif Handal';
  static const String SPELLING_BADGE = 'Ahli Mengeja';

  // ⚡ NEW: Audio Files
  static const String SUCCESS_AUDIO = 'assets/audio/success.mp3';
  static const String TRY_AGAIN_AUDIO = 'assets/audio/try_again.mp3';
  static const String COMPLETED_AUDIO = 'assets/audio/completed.mp3';
  static const String NOTED_AUDIO = 'assets/audio/noted.mp3';

  // ⚡ NEW: Game Settings
  static const int MAX_ATTEMPTS = 3;
  static const int FEEDBACK_DURATION_SECONDS = 2;
  static const int ANIMATION_DURATION_MS = 500;

  // ⚡ NEW: Progress Thresholds
  static const double PROGRESS_BEGINNER = 25.0;
  static const double PROGRESS_INTERMEDIATE = 50.0;
  static const double PROGRESS_ADVANCED = 75.0;
  static const double PROGRESS_COMPLETED = 100.0;

  // ⚡ NEW: Spelling Game Data
  static const List<String> SPELLING_LEVEL_1_WORDS = [
    'sapu', 'biru', 'roti', 'pita', 'buku'
  ];

  static const List<String> SPELLING_LEVEL_2_PHRASES = [
    'sapu biru', 'baca buku', 'baju baru', 'lari pagi', 'ibu guru'
  ];

  static const List<String> SPELLING_LEVEL_3_SENTENCES = [
    'ibu beli sapu biru',
    'aku suka baca buku',
    'papa beli baju baru',
    'risa suka lagu baru',
    'mama minum susu sapi',
    'rusa lari di hutan',
    'makan telur mata sapi'
  ];

  // ⚡ NEW: Helper Methods
  static String getGameType(String title) {
    title = title.toLowerCase();
    if (title.contains('vokal')) return VOCAL_GAME;
    if (title.contains('detektif')) return DETECTIVE_GAME;
    if (title.contains('mengeja')) return SPELLING_GAME;
    return VOCAL_GAME; // Default
  }

  static String getBadgeName(String gameType) {
    switch (gameType) {
      case VOCAL_GAME: return VOCAL_BADGE;
      case DETECTIVE_GAME: return DETECTIVE_BADGE;
      case SPELLING_GAME: return SPELLING_BADGE;
      default: return 'Pencapai Hebat';
    }
  }

  static String getGameRoute(String gameType) {
    switch (gameType) {
      case VOCAL_GAME: return '/siswa/game/huruf';
      case DETECTIVE_GAME: return '/siswa/game/detektif';
      case SPELLING_GAME: return '/siswa/game/spelling';
      default: return '/siswa/game/auto';
    }
  }

  static String getAssetPath(String gameType) {
    switch (gameType) {
      case VOCAL_GAME: return VOCAL_ASSETS;
      case DETECTIVE_GAME: return DETECTIVE_ASSETS;
      case SPELLING_GAME: return SPELLING_ASSETS;
      default: return 'assets/games/';
    }
  }

  static String getAudioPath(String gameType) {
    switch (gameType) {
      case VOCAL_GAME: return VOCAL_AUDIO;
      case DETECTIVE_GAME: return DETECTIVE_AUDIO;
      case SPELLING_GAME: return SPELLING_AUDIO;
      default: return 'assets/audio/';
    }
  }

  static bool isVocalQuestionType(String questionType) {
    return [VOCAL_FILL, FILL_BLANK].contains(questionType);
  }

  static bool isDetectiveQuestionType(String questionType) {
    return [FIND_DIFFERENCE, DRAG_MATCH].contains(questionType);
  }

  static bool isSpellingQuestionType(String questionType) {
    return [COMPLETE_WORD, ARRANGE_SYLLABLES, READ_SENTENCE].contains(questionType);
  }

  static String getProgressLabel(double percentage) {
    if (percentage >= PROGRESS_COMPLETED) return 'Selesai';
    if (percentage >= PROGRESS_ADVANCED) return 'Mahir';
    if (percentage >= PROGRESS_INTERMEDIATE) return 'Menengah';
    if (percentage >= PROGRESS_BEGINNER) return 'Pemula';
    return 'Baru Mulai';
  }
}

class AppColors {
  // EXISTING: Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52E8);
  static const Color primaryLight = Color(0xFF8B5CF6);
  
  // EXISTING: Role Colors
  static const Color guruColor = Color(0xFF6C63FF);
  static const Color siswaColor = Color(0xFF00B894);
  static const Color orangtuaColor = Color(0xFFE17055);
  
  // EXISTING: Semantic Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFFB142);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF0984E3);
  
  // EXISTING: Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textDisabled = Color(0xFFB2BEC3);
  static const Color border = Color(0xFFDDD6FE);

  // ⚡ NEW: Game Level Colors
  static const Color LEVEL_1_COLOR = Colors.blue;
  static const Color LEVEL_2_COLOR = Colors.orange;
  static const Color LEVEL_3_COLOR = Colors.green;

  // ⚡ NEW: Spelling Game Level Colors
  static const Color SPELLING_LEVEL_1 = Colors.blue;
  static const Color SPELLING_LEVEL_2 = Colors.orange;
  static const Color SPELLING_LEVEL_3 = Colors.green;

  // ⚡ NEW: Detective Game Level Colors
  static const Color DETECTIVE_LEVEL_1 = Colors.green;
  static const Color DETECTIVE_LEVEL_2 = Colors.orange;
  static const Color DETECTIVE_LEVEL_3 = Colors.purple;

  // ⚡ NEW: Helper Methods
  static Color getLevelColor(int level, String gameType) {
    switch (gameType) {
      case AppConstants.SPELLING_GAME:
        switch (level) {
          case 1: return SPELLING_LEVEL_1;
          case 2: return SPELLING_LEVEL_2;
          case 3: return SPELLING_LEVEL_3;
          default: return Colors.grey;
        }
      case AppConstants.DETECTIVE_GAME:
        switch (level) {
          case 1: return DETECTIVE_LEVEL_1;
          case 2: return DETECTIVE_LEVEL_2;
          case 3: return DETECTIVE_LEVEL_3;
          default: return Colors.grey;
        }
      default:
        switch (level) {
          case 1: return LEVEL_1_COLOR;
          case 2: return LEVEL_2_COLOR;
          case 3: return LEVEL_3_COLOR;
          default: return Colors.grey;
        }
    }
  }

  static String getLevelTitle(int level, String gameType) {
    switch (gameType) {
      case AppConstants.SPELLING_GAME:
        switch (level) {
          case 1: return 'Melengkapi Kata';
          case 2: return 'Menyusun Suku Kata';
          case 3: return 'Membaca Kalimat';
          default: return 'Level $level';
        }
      case AppConstants.DETECTIVE_GAME:
        switch (level) {
          case 1: return 'Temukan Perbedaan';
          case 2: return 'Pasangkan Huruf';
          case 3: return 'Lengkapi Kata';
          default: return 'Level $level';
        }
      default:
        return 'Level $level';
    }
  }

  static IconData getGameIcon(String gameType) {
    switch (gameType) {
      case AppConstants.VOCAL_GAME: return Icons.record_voice_over;
      case AppConstants.DETECTIVE_GAME: return Icons.search;
      case AppConstants.SPELLING_GAME: return Icons.spellcheck;
      default: return Icons.games;
    }
  }

  static Color getProgressColor(double percentage) {
    if (percentage >= AppConstants.PROGRESS_COMPLETED) return success;
    if (percentage >= AppConstants.PROGRESS_ADVANCED) return info;
    if (percentage >= AppConstants.PROGRESS_INTERMEDIATE) return warning;
    if (percentage >= AppConstants.PROGRESS_BEGINNER) return Colors.yellow;
    return Colors.grey;
  }
}

class AppSizes {
  // EXISTING: Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  
  // EXISTING: Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  
  // EXISTING: Icon Sizes
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
}

class AppTextStyles {
  // EXISTING: Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  // EXISTING: Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  
  // EXISTING: Button Text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // EXISTING: Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}