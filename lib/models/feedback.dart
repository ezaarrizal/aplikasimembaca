// lib/models/feedback.dart
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'feedback.g.dart';

@JsonSerializable()
class Feedback {
  final int id;
  @JsonKey(name: 'guru_id')
  final int guruId;
  @JsonKey(name: 'siswa_id')
  final int siswaId;
  final String judul;
  @JsonKey(name: 'isi_feedback')
  final String isiFeedback;
  final String kategori;
  final String tingkat;
  @JsonKey(name: 'is_read_by_parent', defaultValue: false)
  final bool isReadByParent;
  @JsonKey(name: 'read_at')
  final String? readAt;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'formatted_date')
  final String? formattedDate;
  
  // Relationships
  final User? guru;
  final User? siswa;

  Feedback({
    required this.id,
    required this.guruId,
    required this.siswaId,
    required this.judul,
    required this.isiFeedback,
    required this.kategori,
    required this.tingkat,
    this.isReadByParent = false,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    this.formattedDate,
    this.guru,
    this.siswa,
  });

  // Custom fromJson dengan safe handling
  factory Feedback.fromJson(Map<String, dynamic> json) {
    // Handle null boolean values safely
    Map<String, dynamic> safeJson = Map.from(json);
    safeJson['is_read_by_parent'] = json['is_read_by_parent'] ?? false;
    
    return _$FeedbackFromJson(safeJson);
  }

  Map<String, dynamic> toJson() => _$FeedbackToJson(this);

  // Getters for display
  String get kategoriDisplayName {
    switch (kategori) {
      case 'akademik':
        return 'Akademik';
      case 'perilaku':
        return 'Perilaku';
      case 'prestasi':
        return 'Prestasi';
      case 'kehadiran':
        return 'Kehadiran';
      case 'lainnya':
        return 'Lainnya';
      default:
        return kategori;
    }
  }

  String get tingkatDisplayName {
    switch (tingkat) {
      case 'positif':
        return 'Positif';
      case 'netral':
        return 'Netral';
      case 'perlu_perhatian':
        return 'Perlu Perhatian';
      default:
        return tingkat;
    }
  }

  String get statusDisplayName => isReadByParent ? 'Sudah Dibaca' : 'Belum Dibaca';

  // Helper getters
  bool get isPositive => tingkat == 'positif';
  bool get isNeutral => tingkat == 'netral';
  bool get isNeedsAttention => tingkat == 'perlu_perhatian';

  String get guruName => guru?.nama ?? 'Guru';
  String get siswaName => siswa?.nama ?? 'Siswa';

  @override
  String toString() {
    return 'Feedback{id: $id, judul: $judul, siswa: $siswaName, guru: $guruName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Feedback && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}