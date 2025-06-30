// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedbackListResponse _$FeedbackListResponseFromJson(
        Map<String, dynamic> json) =>
    FeedbackListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : FeedbackListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeedbackListResponseToJson(
        FeedbackListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.toJson(),
    };

FeedbackListData _$FeedbackListDataFromJson(Map<String, dynamic> json) =>
    FeedbackListData(
      feedbacks: (json['feedbacks'] as List<dynamic>)
          .map((e) => Feedback.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
      unreadCount: (json['unread_count'] as num?)?.toInt(),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FeedbackListDataToJson(FeedbackListData instance) =>
    <String, dynamic>{
      'feedbacks': instance.feedbacks.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination?.toJson(),
      'unread_count': instance.unreadCount,
      'children': instance.children?.map((e) => e.toJson()).toList(),
    };
