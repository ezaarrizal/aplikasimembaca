// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feedback _$FeedbackFromJson(Map<String, dynamic> json) => Feedback(
      id: (json['id'] as num).toInt(),
      guruId: (json['guru_id'] as num).toInt(),
      siswaId: (json['siswa_id'] as num).toInt(),
      judul: json['judul'] as String,
      isiFeedback: json['isi_feedback'] as String,
      kategori: json['kategori'] as String,
      tingkat: json['tingkat'] as String,
      isReadByParent: json['is_read_by_parent'] as bool? ?? false,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      formattedDate: json['formatted_date'] as String?,
      guru: json['guru'] == null
          ? null
          : User.fromJson(json['guru'] as Map<String, dynamic>),
      siswa: json['siswa'] == null
          ? null
          : User.fromJson(json['siswa'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeedbackToJson(Feedback instance) => <String, dynamic>{
      'id': instance.id,
      'guru_id': instance.guruId,
      'siswa_id': instance.siswaId,
      'judul': instance.judul,
      'isi_feedback': instance.isiFeedback,
      'kategori': instance.kategori,
      'tingkat': instance.tingkat,
      'is_read_by_parent': instance.isReadByParent,
      'read_at': instance.readAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'formatted_date': instance.formattedDate,
      'guru': instance.guru?.toJson(),
      'siswa': instance.siswa?.toJson(),
    };
