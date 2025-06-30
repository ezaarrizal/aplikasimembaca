import 'package:json_annotation/json_annotation.dart';
import 'feedback.dart';
import 'pagination.dart';
import 'user.dart';

part 'feedback_list_response.g.dart';

@JsonSerializable()
class FeedbackListResponse {
  final bool success;
  final String message;
  final FeedbackListData? data;

  FeedbackListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory FeedbackListResponse.fromJson(Map<String, dynamic> json) =>
      _$FeedbackListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackListResponseToJson(this);
}

@JsonSerializable()
class FeedbackListData {
  final List<Feedback> feedbacks;
  final Pagination? pagination;
  @JsonKey(name: 'unread_count')
  final int? unreadCount;
  final List<User>? children; // For orangtua

  FeedbackListData({
    required this.feedbacks,
    this.pagination,
    this.unreadCount,
    this.children,
  });

  factory FeedbackListData.fromJson(Map<String, dynamic> json) =>
      _$FeedbackListDataFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackListDataToJson(this);
}
