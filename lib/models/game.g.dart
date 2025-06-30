// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      targetAge: json['target_age'] as String,
      skillFocus: json['skill_focus'] as String,
      learningOutcomes: (json['learning_outcomes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      theme: json['theme'] as String,
      totalQuestions: (json['total_questions'] as num).toInt(),
      videoPath: json['video_path'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      studentProgress: json['student_progress'] == null
          ? null
          : StudentProgress.fromJson(
              json['student_progress'] as Map<String, dynamic>),
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => GameQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'target_age': instance.targetAge,
      'skill_focus': instance.skillFocus,
      'learning_outcomes': instance.learningOutcomes,
      'theme': instance.theme,
      'total_questions': instance.totalQuestions,
      'video_path': instance.videoPath,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'student_progress': instance.studentProgress?.toJson(),
      'questions': instance.questions.map((e) => e.toJson()).toList(),
    };

StudentProgress _$StudentProgressFromJson(Map<String, dynamic> json) =>
    StudentProgress(
      hasPlayed: json['has_played'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      lastPlayed: json['last_played'] as String?,
      hasBadge: json['has_badge'] as bool? ?? false,
      badge: json['badge'] == null
          ? null
          : StudentBadge.fromJson(json['badge'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentProgressToJson(StudentProgress instance) =>
    <String, dynamic>{
      'has_played': instance.hasPlayed,
      'is_completed': instance.isCompleted,
      'progress_percentage': instance.progressPercentage,
      'last_played': instance.lastPlayed,
      'has_badge': instance.hasBadge,
      'badge': instance.badge?.toJson(),
    };

GameQuestion _$GameQuestionFromJson(Map<String, dynamic> json) => GameQuestion(
      id: (json['id'] as num).toInt(),
      gameId: (json['game_id'] as num).toInt(),
      questionNumber: (json['question_number'] as num).toInt(),
      level: (json['level'] as num?)?.toInt() ?? 1,
      questionType: json['question_type'] as String? ?? 'vocal_fill',
      letter: json['letter'] as String,
      word: json['word'] as String,
      imagePath: json['image_path'] as String?,
      audioLetterPath: json['audio_letter_path'] as String?,
      audioWordPath: json['audio_word_path'] as String?,
      instruction: json['instruction'] as String,
      wordPattern: json['word_pattern'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$GameQuestionToJson(GameQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'game_id': instance.gameId,
      'question_number': instance.questionNumber,
      'level': instance.level,
      'question_type': instance.questionType,
      'letter': instance.letter,
      'word': instance.word,
      'image_path': instance.imagePath,
      'audio_letter_path': instance.audioLetterPath,
      'audio_word_path': instance.audioWordPath,
      'instruction': instance.instruction,
      'word_pattern': instance.wordPattern,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

GameSession _$GameSessionFromJson(Map<String, dynamic> json) => GameSession(
      id: (json['id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      gameId: (json['game_id'] as num).toInt(),
      startedAt: json['started_at'] as String,
      completedAt: json['completed_at'] as String?,
      videoWatched: json['video_watched'] as bool? ?? false,
      videoCompletedAt: json['video_completed_at'] as String?,
      questionsCompleted: (json['questions_completed'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      status: json['status'] as String,
      teacherNotes: json['teacher_notes'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      game: json['game'] == null
          ? null
          : Game.fromJson(json['game'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GameSessionToJson(GameSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'game_id': instance.gameId,
      'started_at': instance.startedAt,
      'completed_at': instance.completedAt,
      'video_watched': instance.videoWatched,
      'video_completed_at': instance.videoCompletedAt,
      'questions_completed': instance.questionsCompleted,
      'status': instance.status,
      'teacher_notes': instance.teacherNotes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'game': instance.game?.toJson(),
    };

StudentBadge _$StudentBadgeFromJson(Map<String, dynamic> json) => StudentBadge(
      id: (json['id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      gameId: (json['game_id'] as num).toInt(),
      badgeName: json['badge_name'] as String,
      badgeImagePath: json['badge_image_path'] as String?,
      description: json['description'] as String,
      earnedAt: json['earned_at'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      game: json['game'] == null
          ? null
          : Game.fromJson(json['game'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentBadgeToJson(StudentBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'game_id': instance.gameId,
      'badge_name': instance.badgeName,
      'badge_image_path': instance.badgeImagePath,
      'description': instance.description,
      'earned_at': instance.earnedAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'game': instance.game?.toJson(),
    };

LetterOption _$LetterOptionFromJson(Map<String, dynamic> json) => LetterOption(
      letter: json['letter'] as String,
    );

Map<String, dynamic> _$LetterOptionToJson(LetterOption instance) =>
    <String, dynamic>{
      'letter': instance.letter,
    };

QuestionProgress _$QuestionProgressFromJson(Map<String, dynamic> json) =>
    QuestionProgress(
      current: (json['current'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$QuestionProgressToJson(QuestionProgress instance) =>
    <String, dynamic>{
      'current': instance.current,
      'total': instance.total,
      'percentage': instance.percentage,
    };
