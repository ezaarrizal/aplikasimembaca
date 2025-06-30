class UserStatistics {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final Map<String, int> byRole;
  final int recentRegistrations;

  UserStatistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.byRole,
    required this.recentRegistrations,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalUsers: json['total_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      inactiveUsers: json['inactive_users'] ?? 0,
      byRole: Map<String, int>.from(json['by_role'] ?? {}),
      recentRegistrations: json['recent_registrations'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'active_users': activeUsers,
      'inactive_users': inactiveUsers,
      'by_role': byRole,
      'recent_registrations': recentRegistrations,
    };
  }
}