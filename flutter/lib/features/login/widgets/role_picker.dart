import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/features/login/widgets/login_step_header.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class RolePicker extends StatelessWidget {
  const RolePicker({
    super.key,
    required this.onSelect,
    this.onBack,
  });

  final ValueChanged<RoleId> onSelect;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onBack != null)
          LoginStepHeader(
            stepLabel: '3-QADAM',
            title: 'Maqsadingiz nima?',
            subtitle: 'Yo‘nalishingizni tanlang — darslik va testlar shunga moslanadi.',
            onBack: onBack!,
            backLabel: '← Ma’lumotlar',
          )
        else ...[
          Text(
            'Maqsadingiz nima?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: IlmColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Yo‘nalishingizni tanlang — darslik va testlar shunga moslanadi.',
            style: TextStyle(fontSize: 14, color: IlmColors.inkMuted),
          ),
        ],
        const SizedBox(height: 22),
        ...loginGoalOptions.map(
          (goal) => _GoalCard(
            key: ValueKey('goal-${goal.id.name}'),
            icon: goal.icon,
            title: goal.title,
            text: goal.text,
            badge: roleAllowsMultipleSubjects(goal.id)
                ? 'Bir nechta fan'
                : '1 ta asosiy fan',
            onTap: () => onSelect(goal.id),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatefulWidget {
  const _GoalCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String text;
  final String badge;
  final VoidCallback onTap;

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Material(
          color: IlmColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: IlmColors.line, width: 1.2),
          ),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: IlmColors.paper,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.icon,
                      color: IlmColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: IlmColors.ink,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.text,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: IlmColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: IlmColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.badge,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: IlmColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: IlmColors.inkMuted,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
