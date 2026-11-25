import 'package:material_ui/material_ui.dart';

enum LoginMethodId { google, telegram, phone }

class LoginMethod {
  const LoginMethod({
    required this.id,
    required this.label,
    required this.note,
    required this.icon,
  });

  final LoginMethodId id;
  final String label;
  final String note;
  final IconData icon;
}

const loginMethods = <LoginMethod>[
  LoginMethod(
    id: LoginMethodId.google,
    label: 'Google bilan davom etish',
    note: 'Bir bosishda tezkor kirish',
    icon: Icons.g_mobiledata_rounded,
  ),
  LoginMethod(
    id: LoginMethodId.telegram,
    label: 'Telegram orqali kirish',
    note: 'Botda tasdiqlash, parolsiz',
    icon: Icons.send_outlined,
  ),
  LoginMethod(
    id: LoginMethodId.phone,
    label: 'Telefon raqam bilan',
    note: '5 xonali SMS kod orqali',
    icon: Icons.phone_outlined,
  ),
];
