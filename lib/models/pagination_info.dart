class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int perPage;
  final int total;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.perPage,
    required this.total,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'per_page': perPage,
      'total': total,
      'has_next': hasNext,
      'has_prev': hasPrev,
    };
  }
}