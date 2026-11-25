import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/roles.dart';

class AppTab {
  const AppTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.blurb,
  });

  final String id;
  final String label;
  final IconData icon;
  final String blurb;
}

/// Veb `frontend/lib/nav.ts` bilan bir xil tartib (Kirish bundan tashqari).
const appTabs = <AppTab>[
  AppTab(
    id: 'tayyorlovlar',
    label: 'Tayyorlov',
    icon: Icons.fact_check_outlined,
    blurb: 'Tanlangan faningiz bo‘yicha tayyorgarlik rejasi.',
  ),
  AppTab(
    id: 'guides',
    label: 'Qo‘llanma',
    icon: Icons.menu_book_outlined,
    blurb: 'Fan bo‘yicha tayyorlov materiallari.',
  ),
  AppTab(
    id: 'textbooks',
    label: 'Darslik',
    icon: Icons.auto_stories_outlined,
    blurb: 'O‘quvchi uchun darsliklar.',
  ),
  AppTab(
    id: 'tests',
    label: 'Test',
    icon: Icons.quiz_outlined,
    blurb: 'Mashq testlari.',
  ),
  AppTab(
    id: 'reels',
    label: 'Reels',
    icon: Icons.movie_filter_outlined,
    blurb: 'Qisqa video qo‘llanmalar.',
  ),
  AppTab(
    id: 'profile',
    label: 'Profil',
    icon: Icons.person_outline,
    blurb: 'Sozlamalar va shaxsiy bo‘lim.',
  ),
];

/// O‘quvchilari uchun o‘quv materiallari yaratadigan o‘qituvchi menyusi.
const teacherMaterialsTabs = <AppTab>[
  AppTab(
    id: 'create_lessons',
    label: 'Darsliklar',
    icon: Icons.auto_stories_outlined,
    blurb: 'O‘quvchilaringiz uchun darslik va mavzular yarating.',
  ),
  AppTab(
    id: 'create_tests',
    label: 'Testlar',
    icon: Icons.quiz_outlined,
    blurb: 'O‘quvchilaringiz uchun mashq va nazorat testlari tuzing.',
  ),
  AppTab(
    id: 'reels',
    label: 'Reels',
    icon: Icons.movie_filter_outlined,
    blurb: 'Qisqa video qo‘llanmalar.',
  ),
  AppTab(
    id: 'reports',
    label: 'Hisobotlar',
    icon: Icons.bar_chart_rounded,
    blurb: 'O‘quvchilar natijalari va materiallar statistikasi.',
  ),
  AppTab(
    id: 'profile',
    label: 'Profil',
    icon: Icons.person_outline,
    blurb: 'Sozlamalar va shaxsiy bo‘lim.',
  ),
];

/// Abituriyent / OTMlarga tayyorlov menyusi: Tayyorlov, Testlar, Reels, Profil.
const applicantTabs = <AppTab>[
  AppTab(
    id: 'tayyorlovlar',
    label: 'Tayyorlov',
    icon: Icons.fact_check_outlined,
    blurb: 'Tanlangan fanlaringiz bo‘yicha tayyorgarlik rejasi.',
  ),
  AppTab(
    id: 'tests',
    label: 'Testlar',
    icon: Icons.quiz_outlined,
    blurb: 'DTM mashq testlari, bellashuv va reyting.',
  ),
  AppTab(
    id: 'reels',
    label: 'Reels',
    icon: Icons.movie_filter_outlined,
    blurb: 'Qisqa video qo‘llanmalar.',
  ),
  AppTab(
    id: 'profile',
    label: 'Profil',
    icon: Icons.person_outline,
    blurb: 'Sozlamalar va shaxsiy bo‘lim.',
  ),
];

/// Maktab o‘quvchisi menyusi: Darsliklar, Testlar, Vazifalar, Reels, Profil.
const schoolStudentTabs = <AppTab>[
  AppTab(
    id: 'school_textbooks',
    label: 'Darsliklar',
    icon: Icons.auto_stories_outlined,
    blurb: 'Ustoz darsliklari va darslik marketplace.',
  ),
  AppTab(
    id: 'tests',
    label: 'Testlar',
    icon: Icons.quiz_outlined,
    blurb: 'Mavzu va chorak nazorat testlari.',
  ),
  AppTab(
    id: 'school_tasks',
    label: 'Vazifalar',
    icon: Icons.assignment_outlined,
    blurb: 'Uy vazifalari va ustoz guruhlari.',
  ),
  AppTab(
    id: 'reels',
    label: 'Reels',
    icon: Icons.movie_filter_outlined,
    blurb: 'Qisqa video qo‘llanmalar.',
  ),
  AppTab(
    id: 'profile',
    label: 'Profil',
    icon: Icons.person_outline,
    blurb: 'Sozlamalar va shaxsiy bo‘lim.',
  ),
];

/// Talaba menyusi: Darsliklar, Kurslar, Testlar, Reels, Profil.
const universityStudentTabs = <AppTab>[
  AppTab(
    id: 'textbooks',
    label: 'Darsliklar',
    icon: Icons.auto_stories_outlined,
    blurb: 'Darslik marketplace va qo‘llanmalar.',
  ),
  AppTab(
    id: 'courses',
    label: 'Kurslar',
    icon: Icons.school_outlined,
    blurb: 'Chuqurlashtirilgan fan kurslari.',
  ),
  AppTab(
    id: 'tests',
    label: 'Testlar',
    icon: Icons.quiz_outlined,
    blurb: 'Bilim sinovi va sertifikat testlari.',
  ),
  AppTab(
    id: 'reels',
    label: 'Reels',
    icon: Icons.movie_filter_outlined,
    blurb: 'Qisqa video qo‘llanmalar.',
  ),
  AppTab(
    id: 'profile',
    label: 'Profil',
    icon: Icons.person_outline,
    blurb: 'Sozlamalar va shaxsiy bo‘lim.',
  ),
];

/// Rolga mos pastki menyu tablari.
List<AppTab> tabsForRole(RoleId? role) {
  return switch (role) {
    RoleId.teacherMaterials => teacherMaterialsTabs,
    RoleId.teacher => appTabs
        .where((tab) => tab.id != 'guides' && tab.id != 'textbooks')
        .toList(growable: false),
    RoleId.student => applicantTabs,
    RoleId.schoolStudent => schoolStudentTabs,
    RoleId.universityStudent => universityStudentTabs,
    null => appTabs,
  };
}
