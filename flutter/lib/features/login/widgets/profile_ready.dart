import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/features/login/widgets/login_step_header.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class ProfileReady extends StatelessWidget {
  const ProfileReady({
    super.key,
    required this.firstName,
    required this.lastName,
    this.role,
  });

  final String firstName;
  final String lastName;
  final RoleId? role;

  @override
  Widget build(BuildContext context) {
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
    final roleTitle = role == null ? null : roleById(role)?.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginStepHeader(
          stepLabel: 'TAYYOR',
          title: 'Xush kelibsiz',
          subtitle: roleTitle == null
              ? '$firstName $lastName. Kirish muvaffaqiyatli.'
              : '$firstName $lastName, $roleTitle. Kirish muvaffaqiyatli.',
        ),
        const SizedBox(height: 24),
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.white,
          foregroundColor: IlmColors.ink,
          child: Text(initial, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}