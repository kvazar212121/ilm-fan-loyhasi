import 'package:ilm_fan/data/roles.dart';

class TayyorlovFan {
  const TayyorlovFan({required this.id, required this.title});

  final String id;
  final String title;
}

const tayyorlovFans = <TayyorlovFan>[
  TayyorlovFan(id: 'matematika', title: 'Matematika'),
  TayyorlovFan(id: 'fizika', title: 'Fizika'),
  TayyorlovFan(id: 'kimyo', title: 'Kimyo'),
  TayyorlovFan(id: 'biologiya', title: 'Biologiya'),
  TayyorlovFan(id: 'ona-tili', title: 'Ona tili va adabiyot'),
  TayyorlovFan(id: 'ingliz-tili', title: 'Ingliz tili'),
  TayyorlovFan(id: 'tarix', title: 'Tarix'),
  TayyorlovFan(id: 'geografiya', title: 'Geografiya'),
];

TayyorlovFan? tayyorlovFanById(String? id) {
  if (id == null) return null;
  for (final fan in tayyorlovFans) {
    if (fan.id == id) return fan;
  }
  return null;
}

bool roleNeedsSubjectAtLogin(RoleId id) {
  return id == RoleId.teacher ||
      id == RoleId.teacherMaterials ||
      isLearnerRole(id);
}
