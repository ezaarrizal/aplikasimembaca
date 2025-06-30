import 'user.dart';
import 'pagination_info.dart';

class UserListResponse {
  final List<User> users;
  final PaginationInfo pagination;

  UserListResponse({
    required this.users,
    required this.pagination,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      users: (json['users'] as List<dynamic>?)
          ?.map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList() ?? [],
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((u) => u.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}