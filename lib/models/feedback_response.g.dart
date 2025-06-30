// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedbackResponse _$FeedbackResponseFromJson(Map<String, dynamic> json) =>
    FeedbackResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : FeedbackData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeedbackResponseToJson(FeedbackResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.toJson(),
    };

FeedbackData _$FeedbackDataFromJson(Map<String, dynamic> json) => FeedbackData(
      feedback: Feedback.fromJson(json['feedback'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeedbackDataToJson(FeedbackData instance) =>
    <String, dynamic>{
      'feedback': instance.feedback.toJson(),
    };
