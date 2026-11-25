import 'package:ilm_fan/data/roles.dart';

class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    this.id,
    this.role,
    this.subjectFanId,
    this.subjectFanIds = const [],
    this.phone,
    this.email,
    this.birthDate,
    this.region,
    this.gender,
    this.avatarUrl,
    this.accessToken,
    this.refreshToken,
  });

  final int? id;
  final String firstName;
  final String lastName;
  final RoleId? role;

  /// Asosiy fan (`tayyorlov_fans` id).
  final String? subjectFanId;

  /// O‘quvchi / abituriyent / talaba tanlagan bir nechta fanlar.
  final List<String> subjectFanIds;

  final String? phone;
  final String? email;
  final String? birthDate;
  final String? region;
  final String? gender;
  final String? avatarUrl;
  final String? accessToken;
  final String? refreshToken;

  List<String> get allSubjectFanIds {
    if (subjectFanIds.isNotEmpty) return subjectFanIds;
    if (subjectFanId != null) return [subjectFanId!];
    return const [];
  }

  static RoleId? roleFromBackend(String? raw) {
    return switch (raw?.trim()) {
      'teacher' || 'cert-teacher' => RoleId.teacher,
      'teacherMaterials' || 'teacher_materials' || 'guide-teacher' =>
        RoleId.teacherMaterials,
      'student' || 'applicant' => RoleId.student,
      'schoolStudent' || 'school_student' || 'pupil' => RoleId.schoolStudent,
      'universityStudent' || 'university_student' => RoleId.universityStudent,
      _ => null,
    };
  }

  static String roleToBackend(RoleId role) {
    return switch (role) {
      RoleId.teacher => 'teacher',
      RoleId.teacherMaterials => 'teacherMaterials',
      RoleId.student => 'student',
      RoleId.schoolStudent => 'schoolStudent',
      RoleId.universityStudent => 'universityStudent',
    };
  }

  factory UserProfile.fromBackendJson(
    Map<String, dynamic> json, {
    String? accessToken,
    String? refreshToken,
  }) {
    final rawFans = json['fan_ids'];
    final fanIds = rawFans is List
        ? rawFans.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : const <String>[];
    return UserProfile(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      role: roleFromBackend(json['role']?.toString()),
      subjectFanId: fanIds.isNotEmpty ? fanIds.first : null,
      subjectFanIds: fanIds,
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      birthDate: json['birth_date']?.toString(),
      region: json['region']?.toString(),
      gender: json['gender']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
