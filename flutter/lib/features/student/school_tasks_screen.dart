import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class _HomeworkTask {
  const _HomeworkTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueLabel,
    this.submitted = false,
    this.teacherFeedback,
  });

  final String id;
  final String title;
  final String subject;
  final String dueLabel;
  final bool submitted;
  final String? teacherFeedback;

  _HomeworkTask copyWith({bool? submitted}) {
    return _HomeworkTask(
      id: id,
      title: title,
      subject: subject,
      dueLabel: dueLabel,
      submitted: submitted ?? this.submitted,
      teacherFeedback: teacherFeedback,
    );
  }
}

class SchoolTasksScreen extends StatefulWidget {
  const SchoolTasksScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<SchoolTasksScreen> createState() => _SchoolTasksScreenState();
}

class _SchoolTasksScreenState extends State<SchoolTasksScreen> {
  late List<_HomeworkTask> _tasks;
  final List<String> _joinedGroups = ['10-A Matematika (ILM-4821)'];

  @override
  void initState() {
    super.initState();
    final primarySubject =
        tayyorlovFanById(widget.profile.subjectFanId)?.title ?? 'Matematika';
    _tasks = [
      _HomeworkTask(
        id: 'hw-1',
        title: '1-mavzu: Kvadrat tenglamalar (5 ta masala)',
        subject: primarySubject,
        dueLabel: 'Ertaga, 18:00 gacha',
      ),
      _HomeworkTask(
        id: 'hw-2',
        title: 'Grafik chizish mashqi (daftar rasmi)',
        subject: primarySubject,
        dueLabel: 'Tekshirilgan',
        submitted: true,
        teacherFeedback: 'Barakalla! 5 baho — 2-grafik juda aniq chizilgan.',
      ),
    ];
  }

  Future<void> _openJoinGroupSheet() async {
    final codeController = TextEditingController();
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IlmColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ustoz guruhiga qo‘shilish',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: IlmColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ustozingiz bergan taklif kodini kiriting (masalan: ILM-4821).',
                style: TextStyle(fontSize: 13, color: IlmColors.inkMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('joinGroupCodeField'),
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Taklif kodi',
                  hintText: 'ILM-4821',
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                key: const ValueKey('confirmJoinGroupButton'),
                onPressed: () {
                  final val = codeController.text.trim().toUpperCase();
                  if (val.isEmpty) return;
                  Navigator.of(sheetContext).pop(val);
                },
                child: const Text('Guruhga qo‘shilish'),
              ),
            ],
          ),
        );
      },
    );

    if (code != null && mounted) {
      setState(() => _joinedGroups.insert(0, 'Yangi guruh ($code)'));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$code guruhiga qo‘shildingiz'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: IlmColors.paper,
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: IlmColors.paper,
            surfaceTintColor: Colors.transparent,
            title: Text('Vazifalar'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: IlmColors.line),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ustoz guruhlarim',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: IlmColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final g in _joinedGroups)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: IlmColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  g,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: IlmColors.accent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const ValueKey('joinGroupButton'),
                          onPressed: _openJoinGroupSheet,
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                          label: const Text('Kod bilan guruhga qo‘shilish'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Uy vazifalari',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: IlmColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < _tasks.length; i++) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: IlmColors.line),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_tasks[i].subject} · ${_tasks[i].dueLabel}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: IlmColors.accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tasks[i].title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: IlmColors.ink,
                            ),
                          ),
                          if (_tasks[i].teacherFeedback != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Ustoz izohi: ${_tasks[i].teacherFeedback}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: IlmColors.inkMuted,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          if (_tasks[i].submitted)
                            const Text(
                              'Topshirilgan ✓',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: IlmColors.accent,
                              ),
                            )
                          else
                            FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  _tasks[i] = _tasks[i].copyWith(submitted: true);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Uy vazifasi ustozga yuborildi'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.camera_alt_outlined, size: 18),
                              label: const Text('Yechim rasmini yuborish'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
