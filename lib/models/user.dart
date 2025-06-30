// lib/models/user.dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String nama;
  final String role;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.nama,
    required this.role,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // Menggunakan generated fromJson dengan safe handling
  factory User.fromJson(Map<String, dynamic> json) {
    // Handle null/missing fields safely
    Map<String, dynamic> safeJson = {
      'id': json['id'] ?? 0,
      'username': json['username'] ?? '',
      'nama': json['nama'] ?? '',
      'role': json['role'] ?? '',
      'is_active': json['is_active'] ?? true, // Default true jika null
      'created_at': json['created_at'],
      'updated_at': json['updated_at'],
    };

    return _$UserFromJson(safeJson);
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Role checking methods
  bool get isGuru => role == 'guru';
  bool get isSiswa => role == 'siswa';
  bool get isOrangtua => role == 'orangtua';

  bool hasRole(String roleToCheck) {
    return role == roleToCheck;
  }

  bool hasAnyRole(List<String> roles) {
    return roles.contains(role);
  }

  // Display getters
  String get roleDisplayName {
    switch (role) {
      case 'guru':
        return 'Guru';
      case 'siswa':
        return 'Siswa';
      case 'orangtua':
        return 'Orangtua';
      default:
        return role;
    }
  }

  String get statusDisplayName => isActive ? 'Aktif' : 'Nonaktif';

  @override
  String toString() {
    return 'User{id: $id, nama: $nama, username: $username, role: $role, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
