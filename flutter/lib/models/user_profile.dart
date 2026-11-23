import 'package:ilm_fan/data/roles.dart';

class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    this.role,
    this.subjectFanId,
    this.subjectFanIds = const [],
  });

  final String firstName;
  final String lastName;
  final RoleId? role;

  /// Asosiy fan (`tayyorlov_fans` id).
  final String? subjectFanId;

  /// O‘quvchi / abituriyent / talaba tanlagan bir nechta fanlar.
  final List<String> subjectFanIds;

  List<String> get allSubjectFanIds {
    if (subjectFanIds.isNotEmpty) return subjectFanIds;
    if (subjectFanId != null) return [subjectFanId!];
    return const [];
  }
}
