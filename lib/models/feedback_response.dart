import 'package:json_annotation/json_annotation.dart';
import 'feedback.dart';

part 'feedback_response.g.dart';

@JsonSerializable()
class FeedbackResponse {
  final bool success;
  final String message;
  final FeedbackData? data;

  FeedbackResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) => 
      _$FeedbackResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackResponseToJson(this);
}

@JsonSerializable()
class FeedbackData {
  final Feedback feedback;

  FeedbackData({required this.feedback});

  factory FeedbackData.fromJson(Map<String, dynamic> json) => 
      _$FeedbackDataFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackDataToJson(this);
}