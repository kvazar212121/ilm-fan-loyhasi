import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/features/login/widgets/login_step_header.dart';
import 'package:ilm_fan/models/user_profile.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key, required this.onBack, required this.onSave});

  final VoidCallback onBack;
  final ValueChanged<UserProfile> onSave;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  var _missing = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  void _submit() {
    final given = _firstName.text.trim();
    final family = _lastName.text.trim();
    if (given.isEmpty || family.isEmpty) {
      setState(() => _missing = true);
      return;
    }
    widget.onSave(UserProfile(firstName: given, lastName: family));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginStepHeader(
          stepLabel: 'YANGI FOYDALANUVCHI',
          title: 'Ism va familiya',
          subtitle: 'Bu qadam faqat birinchi marta kirganlar uchun.',
          onBack: widget.onBack,
          backLabel: '← Orqaga',
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _firstName,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(hintText: 'Ism'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _lastName,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: const InputDecoration(hintText: 'Familiya'),
        ),
        if (_missing)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Ism va familiyani yozing.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        const SizedBox(height: 24),
        FilledButton(onPressed: _submit, child: const Text('Davom etish')),
      ],
    );
  }
}
