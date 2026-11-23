import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/features/login/widgets/login_step_header.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class RolePicker extends StatelessWidget {
  const RolePicker({
    super.key,
    required this.onSelect,
    required this.onSelectLearner,
  });

  final ValueChanged<RoleId> onSelect;
  final VoidCallback onSelectLearner;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Maqsadingiz nima?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: IlmColors.ink,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 26),
        ...teacherRoleOptions.map(
          (role) => _RoleCard(
            icon: role.icon,
            title: role.title,
            text: role.text,
            onTap: () => onSelect(role.id),
          ),
        ),
        _RoleCard(
          key: const ValueKey('selectLearnerCategory'),
          icon: Icons.school_outlined,
          title: 'O‘quvchiman',
          text: 'Maktab o‘quvchisi, abituriyent yoki talaba',
          onTap: onSelectLearner,
        ),
      ],
    );
  }
}

class LearnerRolePicker extends StatelessWidget {
  const LearnerRolePicker({
    super.key,
    required this.onSelect,
    required this.onBack,
  });

  final ValueChanged<RoleId> onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginStepHeader(
          stepLabel: '2-QADAM',
          title: 'Qaysi bosqichdasiz?',
          subtitle: 'O‘qish turiga qarab menyu va bo‘limlar moslashtiriladi.',
          onBack: onBack,
          backLabel: '← Orqaga',
        ),
        const SizedBox(height: 22),
        ...learnerSubRoleOptions.map(
          (role) => _RoleCard(
            key: ValueKey('learner-role-${role.id.name}'),
            icon: role.icon,
            title: role.title,
            text: role.text,
            onTap: () => onSelect(role.id),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: IlmColors.line, width: 1.2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: IlmColors.paper,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: IlmColors.accent,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: IlmColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: IlmColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: IlmColors.inkMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
