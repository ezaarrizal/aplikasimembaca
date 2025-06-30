// lib/models/game.dart - UPDATED with word_pattern support

import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

// Helper functions for safe type conversion
int _safeInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _safeDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

String _safeString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

List<String> _safeStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return [];
}

@JsonSerializable()
class Game {
  final int id;
  final String title;
  final String description;
  @JsonKey(name: 'target_age')
  final String targetAge;
  @JsonKey(name: 'skill_focus')
  final String skillFocus;
  @JsonKey(name: 'learning_outcomes')
  final List<String> learningOutcomes;
  final String theme;
  @JsonKey(name: 'total_questions')
  final int totalQuestions;
  @JsonKey(name: 'video_path')
  final String? videoPath;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  @JsonKey(name: 'student_progress')
  final StudentProgress? studentProgress;
  
  final List<GameQuestion> questions;

  Game({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAge,
    required this.skillFocus,
    required this.learningOutcomes,
    required this.theme,
    required this.totalQuestions,
    this.videoPath,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.studentProgress,
    this.questions = const [],
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    try {
      return Game(
        id: _safeInt(json['id']),
        title: _safeString(json['title']),
        description: _safeString(json['description']),
        targetAge: _safeString(json['target_age']),
        skillFocus: _safeString(json['skill_focus']),
        learningOutcomes: _safeStringList(json['learning_outcomes']),
        theme: _safeString(json['theme']),
        totalQuestions: _safeInt(json['total_questions']),
        videoPath: json['video_path']?.toString(),
        isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == "1",
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
        studentProgress: json['student_progress'] != null
            ? StudentProgress.fromJson(Map<String, dynamic>.from(json['student_progress']))
            : null,
        questions: json['questions'] != null
            ? (json['questions'] as List)
                .map((q) => GameQuestion.fromJson(Map<String, dynamic>.from(q)))
                .toList()
            : [],
      );
    } catch (e) {
      print('🚨 Error parsing Game: $e');
      print('🚨 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$GameToJson(this);

  bool get requiresVideo => videoPath != null && videoPath!.isNotEmpty;
  bool get hasProgress => studentProgress != null;
  bool get isCompleted => studentProgress?.isCompleted ?? false;
  bool get hasPlayed => studentProgress?.hasPlayed ?? false;
  bool get hasBadge => studentProgress?.hasBadge ?? false;

  // ⚡ NEW: Game type detection helpers
  bool get isVocalGame => title.toLowerCase().contains('vokal') || 
                         theme.toLowerCase().contains('vokal');
  
  bool get isDetectiveGame => title.toLowerCase().contains('detektif') || 
                             theme.toLowerCase().contains('detektif');
  
  bool get isSpellingGame => title.toLowerCase().contains('mengeja') || 
                            theme.toLowerCase().contains('mengeja') ||
                            skillFocus.toLowerCase().contains('mengeja');

  String get gameType {
    if (isVocalGame) return 'vocal';
    if (isDetectiveGame) return 'detective';
    if (isSpellingGame) return 'spelling';
    return 'unknown';
  }

  @override
  String toString() {
    return 'Game{id: $id, title: $title, type: $gameType}';
  }
}

@JsonSerializable()
class StudentProgress {
  @JsonKey(name: 'has_played', defaultValue: false)
  final bool hasPlayed;
  @JsonKey(name: 'is_completed', defaultValue: false)
  final bool isCompleted;
  @JsonKey(name: 'progress_percentage', defaultValue: 0.0)
  final double progressPercentage;
  @JsonKey(name: 'last_played')
  final String? lastPlayed;
  @JsonKey(name: 'has_badge', defaultValue: false)
  final bool hasBadge;
  final StudentBadge? badge;

  StudentProgress({
    required this.hasPlayed,
    required this.isCompleted,
    required this.progressPercentage,
    this.lastPlayed,
    required this.hasBadge,
    this.badge,
  });

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    try {
      return StudentProgress(
        hasPlayed: json['has_played'] == true || json['has_played'] == 1 || json['has_played'] == "1",
        isCompleted: json['is_completed'] == true || json['is_completed'] == 1 || json['is_completed'] == "1",
        progressPercentage: _safeDouble(json['progress_percentage']),
        lastPlayed: json['last_played']?.toString(),
        hasBadge: json['has_badge'] == true || json['has_badge'] == 1 || json['has_badge'] == "1",
        badge: json['badge'] != null 
            ? StudentBadge.fromJson(Map<String, dynamic>.from(json['badge'])) 
            : null,
      );
    } catch (e) {
      print('🚨 Error parsing StudentProgress: $e');
      print('🚨 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$StudentProgressToJson(this);
}

@JsonSerializable()
class GameQuestion {
  final int id;
  @JsonKey(name: 'game_id')
  final int gameId;
  @JsonKey(name: 'question_number')
  final int questionNumber;
  @JsonKey(name: 'level', defaultValue: 1)
  final int? level;
  @JsonKey(name: 'question_type', defaultValue: 'vocal_fill')
  final String? questionType;
  final String letter; // This is the correct letter/answer
  final String word; // Full word for context
  @JsonKey(name: 'image_path')
  final String? imagePath;
  @JsonKey(name: 'audio_letter_path')
  final String? audioLetterPath;
  @JsonKey(name: 'audio_word_path')
  final String? audioWordPath;
  final String instruction;
  @JsonKey(name: 'word_pattern') // ⚡ NEW: Pattern for spelling game
  final String? wordPattern;

  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  GameQuestion({
    required this.id,
    required this.gameId,
    required this.questionNumber,
    this.level = 1,
    this.questionType = 'vocal_fill',
    required this.letter,
    required this.word,
    this.imagePath,
    this.audioLetterPath,
    this.audioWordPath,
    required this.instruction,
    this.wordPattern, // ⚡ NEW: For spelling game patterns
    this.createdAt,
    this.updatedAt,
  });

  factory GameQuestion.fromJson(Map<String, dynamic> json) {
    try {
      return GameQuestion(
        id: _safeInt(json['id']),
        gameId: _safeInt(json['game_id']),
        questionNumber: _safeInt(json['question_number']),
        level: _safeInt(json['level'] ?? 1),
        questionType: _safeString(json['question_type'] ?? 'vocal_fill'),
        letter: _safeString(json['letter']),
        word: _safeString(json['word']),
        imagePath: json['image_path']?.toString(),
        audioLetterPath: json['audio_letter_path']?.toString(),
        audioWordPath: json['audio_word_path']?.toString(),
        instruction: _safeString(json['instruction']),
        wordPattern: json['word_pattern']?.toString(), // ⚡ NEW
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );
    } catch (e) {
      print('🚨 Error parsing GameQuestion: $e');
      print('🚨 JSON data: $json');
      rethrow;
    }
  }

  int get safeLevel => level ?? 1;
  String get safeQuestionType => questionType ?? 'vocal_fill';

  Map<String, dynamic> toJson() => _$GameQuestionToJson(this);

  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get hasAudio => audioWordPath != null && audioWordPath!.isNotEmpty;
  bool get hasLetterAudio => audioLetterPath != null && audioLetterPath!.isNotEmpty;
  
  // ⚡ NEW: Spelling game helpers
  bool get hasWordPattern => wordPattern != null && wordPattern!.isNotEmpty;
  
  String get displayPattern {
    if (hasWordPattern) return wordPattern!;
    
    // Fallback pattern generation
    if (safeQuestionType == 'complete_word') {
      if (word.toLowerCase().startsWith(letter.toLowerCase())) {
        return '$letter + ${word.substring(letter.length)}';
      } else {
        return '... + $letter';
      }
    }
    
    return word;
  }
  
  List<String> get correctSequence {
    if (safeQuestionType == 'arrange_syllables') {
      return letter.split(',').map((s) => s.trim()).toList();
    }
    return [];
  }
  
  bool get isSpellingGame => safeQuestionType.contains('complete_word') || 
                           safeQuestionType.contains('arrange_syllables') ||
                           safeQuestionType.contains('read_sentence');
  
  bool get isDetectiveGame => safeQuestionType.contains('find_difference') ||
                             safeQuestionType.contains('drag_match');
  
  bool get isVocalGame => safeQuestionType.contains('vocal_fill') ||
                         safeQuestionType.contains('fill_blank');

  String get levelTitle {
    switch (safeLevel) {
      case 1:
        if (isSpellingGame) return 'Melengkapi Kata';
        if (isDetectiveGame) return 'Temukan Perbedaan';
        return 'Level 1';
      case 2:
        if (isSpellingGame) return 'Menyusun Suku Kata';
        if (isDetectiveGame) return 'Pasangkan Huruf';
        return 'Level 2';
      case 3:
        if (isSpellingGame) return 'Membaca Kalimat';
        if (isDetectiveGame) return 'Lengkapi Kata';
        return 'Level 3';
      default:
        return 'Level $safeLevel';
    }
  }
}

@JsonSerializable()
class GameSession {
  final int id;
  @JsonKey(name: 'student_id')
  final int studentId;
  @JsonKey(name: 'game_id')
  final int gameId;
  @JsonKey(name: 'started_at')
  final String startedAt;
  @JsonKey(name: 'completed_at')
  final String? completedAt;
  @JsonKey(name: 'video_watched', defaultValue: false)
  final bool videoWatched;
  @JsonKey(name: 'video_completed_at')
  final String? videoCompletedAt;
  @JsonKey(name: 'questions_completed')
  final List<int> questionsCompleted; 
  final String status;
  @JsonKey(name: 'teacher_notes')
  final String? teacherNotes;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  final Game? game;

  GameSession({
    required this.id,
    required this.studentId,
    required this.gameId,
    required this.startedAt,
    this.completedAt,
    required this.videoWatched,
    this.videoCompletedAt,
    required this.questionsCompleted,
    required this.status,
    this.teacherNotes,
    this.createdAt,
    this.updatedAt,
    this.game,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    try {
      List<int> questionsCompleted = [];
      if (json['questions_completed'] != null) {
        if (json['questions_completed'] is List) {
          questionsCompleted = (json['questions_completed'] as List)
              .map((e) => _safeInt(e))
              .toList();
        }
      }

      return GameSession(
        id: _safeInt(json['id']),
        studentId: _safeInt(json['student_id']),
        gameId: _safeInt(json['game_id']),
        startedAt: _safeString(json['started_at']),
        completedAt: json['completed_at']?.toString(),
        videoWatched: json['video_watched'] == true || json['video_watched'] == 1 || json['video_watched'] == "1",
        videoCompletedAt: json['video_completed_at']?.toString(),
        questionsCompleted: questionsCompleted,
        status: _safeString(json['status']),
        teacherNotes: json['teacher_notes']?.toString(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
        game: json['game'] != null 
            ? Game.fromJson(Map<String, dynamic>.from(json['game'])) 
            : null,
      );
    } catch (e) {
      print('🚨 Error parsing GameSession: $e');
      print('🚨 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$GameSessionToJson(this);

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get requiresVideo => game?.requiresVideo == true && !videoWatched;
  
  double get progressPercentage {
    if (game == null || game!.totalQuestions == 0) return 0.0;
    return (questionsCompleted.length / game!.totalQuestions) * 100;
  }
}

@JsonSerializable()
class StudentBadge {
  final int id;
  @JsonKey(name: 'student_id')
  final int studentId;
  @JsonKey(name: 'game_id')
  final int gameId;
  @JsonKey(name: 'badge_name')
  final String badgeName;
  @JsonKey(name: 'badge_image_path')
  final String? badgeImagePath;
  final String description;
  @JsonKey(name: 'earned_at')
  final String earnedAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  final Game? game;

  StudentBadge({
    required this.id,
    required this.studentId,
    required this.gameId,
    required this.badgeName,
    this.badgeImagePath,
    required this.description,
    required this.earnedAt,
    this.createdAt,
    this.updatedAt,
    this.game,
  });

  factory StudentBadge.fromJson(Map<String, dynamic> json) {
    try {
      return StudentBadge(
        id: _safeInt(json['id']),
        studentId: _safeInt(json['student_id']),
        gameId: _safeInt(json['game_id']),
        badgeName: _safeString(json['badge_name']),
        badgeImagePath: json['badge_image_path']?.toString(),
        description: _safeString(json['description']),
        earnedAt: _safeString(json['earned_at']),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
        game: json['game'] != null 
            ? Game.fromJson(Map<String, dynamic>.from(json['game'])) 
            : null,
      );
    } catch (e) {
      print('🚨 Error parsing StudentBadge: $e');
      print('🚨 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$StudentBadgeToJson(this);

  bool get hasImage => badgeImagePath != null && badgeImagePath!.isNotEmpty;
  
  DateTime get earnedDate {
    try {
      return DateTime.parse(earnedAt);
    } catch (e) {
      return DateTime.now();
    }
  }
}

@JsonSerializable()
class LetterOption {
  final String letter;

  LetterOption({
    required this.letter,
  });

  factory LetterOption.fromJson(Map<String, dynamic> json) {
    try {
      return LetterOption(
        letter: _safeString(json['letter']),
      );
    } catch (e) {
      print('🚨 Error parsing LetterOption: $e');
      print('🚨 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$LetterOptionToJson(this);
  
  @override
  String toString() => 'LetterOption(letter: $letter)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LetterOption &&
          runtimeType == other.runtimeType &&
          letter == other.letter;

  @override
  int get hashCode => letter.hashCode;
}

@JsonSerializable()
class QuestionProgress {
  final int current;
  final int total;
  final double percentage;

  QuestionProgress({
    required this.current,
    required this.total,
    required this.percentage,
  });

  factory QuestionProgress.fromJson(Map<String, dynamic> json) {
    try {
      return QuestionProgress(
        current: _safeInt(json['current']),
        total: _safeInt(json['total']),
        percentage: _safeDouble(json['percentage']),
      );
    } catch (e) {
      print('🚨 Error parsing QuestionProgress: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$QuestionProgressToJson(this);
  
  bool get isCompleted => current >= total;
  String get displayText => '$current/$total';
}

// Request models - Simplified for different game submissions
class AnswerSubmission {
  final String selectedLetter;
  final String? teacherObservation;

  AnswerSubmission({
    required this.selectedLetter,
    this.teacherObservation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'selected_letter': selectedLetter,
    };
    
    final String? observation = teacherObservation;
    if (observation != null && observation.isNotEmpty) {
      json['teacher_observation'] = observation;
    }
    
    return json;
  }
}