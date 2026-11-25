import 'package:material_ui/material_ui.dart';

enum RoleId {
  teacher,
  teacherMaterials,
  student,
  schoolStudent,
  universityStudent,
}

bool isLearnerRole(RoleId? id) {
  return id == RoleId.student ||
      id == RoleId.schoolStudent ||
      id == RoleId.universityStudent;
}

bool roleAllowsMultipleSubjects(RoleId id) {
  return id == RoleId.student ||
      id == RoleId.universityStudent ||
      id == RoleId.schoolStudent;
}

class RoleOption {
  const RoleOption({
    required this.id,
    required this.title,
    required this.text,
    required this.icon,
  });

  final RoleId id;
  final String title;
  final String text;
  final IconData icon;
}

/// Mobil ilovada kirishdan keyin so‘raladigan 3 ta asosiy maqsad.
const loginGoalOptions = <RoleOption>[
  RoleOption(
    id: RoleId.teacher,
    title: 'Milliy sertifikatlarga tayyorlov',
    text: 'O‘qituvchilar o‘z fanidan milliy sertifikat imtihoniga tayyorlanishi uchun',
    icon: Icons.workspace_premium_outlined,
  ),
  RoleOption(
    id: RoleId.student,
    title: 'OTMlarga tayyorlov',
    text: 'OTM kirish imtihonlariga bir nechta fan bo‘yicha tayyorgarlik',
    icon: Icons.school_outlined,
  ),
  RoleOption(
    id: RoleId.universityStudent,
    title: 'OTM sessiyalariga tayyorlov',
    text: 'Talabalar uchun fanlar va sessiya imtihonlariga tayyorgarlik',
    icon: Icons.account_balance_outlined,
  ),
];

const _legacyRoleOptions = <RoleOption>[
  RoleOption(
    id: RoleId.teacherMaterials,
    title: 'O‘qituvchiman',
    text: 'O‘quvchilarim uchun o‘quv materiallari yarataman',
    icon: Icons.edit_note_rounded,
  ),
  RoleOption(
    id: RoleId.schoolStudent,
    title: 'Maktab o‘quvchisi',
    text: 'Sinf darsliklari, testlar va uy vazifalari',
    icon: Icons.menu_book_outlined,
  ),
];

const roleOptions = <RoleOption>[
  ...loginGoalOptions,
  ..._legacyRoleOptions,
];

RoleOption? roleById(RoleId? id) {
  if (id == null) return null;
  for (final role in roleOptions) {
    if (role.id == id) return role;
  }
  return null;
}
