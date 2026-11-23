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

const teacherRoleOptions = <RoleOption>[
  RoleOption(
    id: RoleId.teacher,
    title: 'O‘qituvchiman',
    text: 'Sertifikat imtihoniga tayyorlanish uchun',
    icon: Icons.workspace_premium_outlined,
  ),
  RoleOption(
    id: RoleId.teacherMaterials,
    title: 'O‘qituvchiman',
    text: 'O‘quvchilarim uchun o‘quv materiallari yarataman',
    icon: Icons.edit_note_rounded,
  ),
];

const learnerSubRoleOptions = <RoleOption>[
  RoleOption(
    id: RoleId.schoolStudent,
    title: 'Maktab o‘quvchisi',
    text: 'Sinf darsliklari, testlar va uy vazifalari',
    icon: Icons.menu_book_outlined,
  ),
  RoleOption(
    id: RoleId.student,
    title: 'Abituriyent',
    text: 'OTM kirish imtihonlariga tayyorlanaman',
    icon: Icons.school_outlined,
  ),
  RoleOption(
    id: RoleId.universityStudent,
    title: 'Talaba',
    text: 'OTM, kurslar va chuqurlashtirilgan darsliklar',
    icon: Icons.account_balance_outlined,
  ),
];

const roleOptions = <RoleOption>[
  ...teacherRoleOptions,
  ...learnerSubRoleOptions,
];

RoleOption? roleById(RoleId? id) {
  if (id == null) return null;
  for (final role in roleOptions) {
    if (role.id == id) return role;
  }
  return null;
}
