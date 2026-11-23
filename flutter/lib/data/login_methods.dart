import 'package:material_ui/material_ui.dart';

enum LoginMethodId { google, telegram, phone }

class LoginMethod {
  const LoginMethod({
    required this.id,
    required this.label,
    required this.icon,
  });

  final LoginMethodId id;
  final String label;
  final IconData icon;
}

const loginMethods = <LoginMethod>[
  LoginMethod(
    id: LoginMethodId.google,
    label: 'Google',
    icon: Icons.g_mobiledata_rounded,
  ),
  LoginMethod(
    id: LoginMethodId.telegram,
    label: 'Telegram',
    icon: Icons.send_outlined,
  ),
  LoginMethod(
    id: LoginMethodId.phone,
    label: 'Telefon raqam',
    icon: Icons.phone_outlined,
  ),
];