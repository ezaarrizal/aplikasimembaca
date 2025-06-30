// lib/models/pagination.dart
import 'package:json_annotation/json_annotation.dart';

part 'pagination.g.dart';

@JsonSerializable()
class Pagination {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;
  @JsonKey(name: 'has_next')
  final bool hasNext;
  @JsonKey(name: 'has_prev')
  final bool hasPrev;

  const Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.perPage,
    required this.total,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => _$PaginationFromJson(json);
  
  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}