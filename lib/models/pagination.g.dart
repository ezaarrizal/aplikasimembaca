// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
      currentPage: (json['current_page'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      hasNext: json['has_next'] as bool,
      hasPrev: json['has_prev'] as bool,
    );

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'total_pages': instance.totalPages,
      'per_page': instance.perPage,
      'total': instance.total,
      'has_next': instance.hasNext,
      'has_prev': instance.hasPrev,
    };
