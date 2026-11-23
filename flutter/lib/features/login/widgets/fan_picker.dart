import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/features/login/widgets/login_step_header.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class FanPicker extends StatefulWidget {
  const FanPicker({
    super.key,
    required this.role,
    required this.onBack,
    required this.onSelect,
  });

  final RoleOption role;
  final VoidCallback onBack;
  final ValueChanged<List<String>> onSelect;

  @override
  State<FanPicker> createState() => _FanPickerState();
}

class _FanPickerState extends State<FanPicker> {
  final Set<String> _selected = {};

  bool get _allowMultiple => isLearnerRole(widget.role.id);

  void _toggle(String fanId) {
    if (!_allowMultiple) {
      widget.onSelect([fanId]);
      return;
    }
    setState(() {
      if (!_selected.add(fanId)) {
        _selected.remove(fanId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (widget.role.id) {
      RoleId.teacher =>
        'Sertifikat imtihoniga tayyorlanadigan faningizni tanlang.',
      RoleId.teacherMaterials => 'Material yaratadigan faningizni tanlang.',
      RoleId.student =>
        'Kirish imtihoniga tayyorlanadigan bir nechta faningizni tanlang.',
      RoleId.schoolStudent =>
        'O‘rganmoqchi bo‘lgan bir nechta maktab fanlaringizni tanlang.',
      RoleId.universityStudent =>
        'Chuqurlashtirib o‘rganadigan fanlaringizni tanlang.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginStepHeader(
          stepLabel: '3-QADAM',
          title: _allowMultiple ? 'Qaysi fanlar?' : 'Qaysi fan?',
          subtitle: subtitle,
          onBack: widget.onBack,
          backLabel: '← Rolni o‘zgartirish',
        ),
        const SizedBox(height: 20),
        ...tayyorlovFans.map((fan) {
          final isSelected = _selected.contains(fan.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? IlmColors.accent : IlmColors.line,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: InkWell(
                key: ValueKey('fan-option-${fan.id}'),
                borderRadius: BorderRadius.circular(14),
                onTap: () => _toggle(fan.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _allowMultiple
                            ? (isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked)
                            : Icons.subject_outlined,
                        color: IlmColors.accent,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fan.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (!_allowMultiple)
                        const Icon(
                          Icons.chevron_right,
                          color: IlmColors.inkMuted,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (_allowMultiple) ...[
          const SizedBox(height: 12),
          FilledButton(
            key: const ValueKey('confirmFansButton'),
            onPressed: _selected.isEmpty
                ? null
                : () => widget.onSelect(_selected.toList(growable: false)),
            child: Text(
              _selected.isEmpty
                  ? 'Kamida 1 ta fan tanlang'
                  : 'Davom etish (${_selected.length} ta fan)',
            ),
          ),
        ],
      ],
    );
  }
}
