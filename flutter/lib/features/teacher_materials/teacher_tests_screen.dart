import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/features/teacher_materials/test_editor_screen.dart';
import 'package:ilm_fan/models/teacher_test.dart';
import 'package:ilm_fan/models/teacher_textbook.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class TeacherTestsScreen extends StatefulWidget {
  const TeacherTestsScreen({
    super.key,
    required this.profile,
    this.teacherTextbooks = const [],
  });

  final UserProfile profile;
  final List<TeacherTextbook> teacherTextbooks;

  @override
  State<TeacherTestsScreen> createState() => _TeacherTestsScreenState();
}

class _TeacherTestsScreenState extends State<TeacherTestsScreen> {
  late List<TeacherTestItem> _tests;

  String get _subjectTitle =>
      tayyorlovFanById(widget.profile.subjectFanId)?.title ?? 'Umumiy fan';

  @override
  void initState() {
    super.initState();
    _tests = buildSampleTeacherTests(_subjectTitle);
  }

  Future<void> _openEditor(int index) async {
    final updated = await Navigator.of(context).push<TeacherTestItem>(
      MaterialPageRoute<TeacherTestItem>(
        builder: (_) => TestEditorScreen(testItem: _tests[index]),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        final copy = [..._tests];
        copy[index] = updated;
        _tests = copy;
      });
    }
  }

  Future<void> _openCreateTestSheet() async {
    final titleController = TextEditingController();
    final timeController = TextEditingController(text: '20');

    final created = await showModalBottomSheet<TeacherTestItem>(
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
                'Yangi test yaratish',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: IlmColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Test nomi',
                  hintText: 'Masalan: 10-sinf funksiyalar testi',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Vaqt chegarasi (daqiqa)',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;
                  final mins = int.tryParse(timeController.text.trim()) ?? 20;
                  Navigator.of(sheetContext).pop(
                    TeacherTestItem(
                      id: 'test-${DateTime.now().microsecondsSinceEpoch}',
                      title: title,
                      attemptsCount: 0,
                      isActive: false,
                      timeLimitMinutes: mins > 0 ? mins : 20,
                      questions: const [],
                    ),
                  );
                },
                child: const Text('Yaratish va savol qo‘shish'),
              ),
            ],
          ),
        );
      },
    );

    if (created != null && mounted) {
      setState(() => _tests = [created, ..._tests]);
      await _openEditor(0);
    }
  }

  Future<void> _openAiGeneratorSheet() async {
    final sourceController = TextEditingController();
    var sourceKind = 'Kitob / PDF';
    var count = 5;
    var difficulty = 'O‘rta';
    var qType = 'Aralash';
    final myBooks = widget.teacherTextbooks;

    final generated = await showModalBottomSheet<TeacherTestItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IlmColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
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
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_outlined,
                          color: IlmColors.accent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI bilan kitobdan test tuzish',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: IlmColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Kitob, PDF bob nomi yoki o‘zingiz yaratgan darslikni tanlang — AI tayyor savollar va yechimlar tuzib beradi.',
                      style: TextStyle(
                        fontSize: 13,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final kind in ['Kitob / PDF', 'Darsligimdan', 'Matndan'])
                          ChoiceChip(
                            label: Text(kind),
                            selected: sourceKind == kind,
                            selectedColor:
                                IlmColors.accent.withValues(alpha: 0.16),
                            onSelected: (_) => setSheetState(() {
                              sourceKind = kind;
                              if (kind == 'Darsligimdan' && myBooks.isNotEmpty) {
                                sourceController.text = myBooks.first.title;
                              }
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const ValueKey('aiBookSourceField'),
                      controller: sourceController,
                      maxLines: sourceKind == 'Matndan' ? 4 : 2,
                      decoration: InputDecoration(
                        labelText: sourceKind == 'Matndan'
                            ? 'Kitobdan matn parcha'
                            : 'Kitob nomi, PDF yoki bob',
                        hintText:
                            'Masalan: 10-sinf $_subjectTitle, 3-bob (Funksiyalar)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Savollar soni',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final c in [5, 10, 15])
                          ChoiceChip(
                            label: Text('$c ta'),
                            selected: count == c,
                            selectedColor:
                                IlmColors.accent.withValues(alpha: 0.16),
                            onSelected: (_) => setSheetState(() => count = c),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Daraja',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final d in ['Oson', 'O‘rta', 'DTM / Sertifikat'])
                          ChoiceChip(
                            label: Text(d),
                            selected: difficulty == d,
                            selectedColor:
                                IlmColors.accent.withValues(alpha: 0.16),
                            onSelected: (_) =>
                                setSheetState(() => difficulty = d),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Savol turi',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final t in ['Aralash', 'A/B/C/D', 'Ochiq javob'])
                          ChoiceChip(
                            label: Text(t),
                            selected: qType == t,
                            selectedColor:
                                IlmColors.accent.withValues(alpha: 0.16),
                            onSelected: (_) => setSheetState(() => qType = t),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      key: const ValueKey('confirmAiGenerateTestButton'),
                      onPressed: () {
                        final bookName = sourceController.text.trim().isEmpty
                            ? '$_subjectTitle darsligi'
                            : sourceController.text.trim();
                        final questions = List<TeacherQuestion>.generate(
                          count,
                          (i) {
                            final type = switch (qType) {
                              'Ochiq javob' => TeacherQuestionType.openAnswer,
                              'A/B/C/D' => TeacherQuestionType.multipleChoice,
                              _ => i.isEven
                                  ? TeacherQuestionType.multipleChoice
                                  : TeacherQuestionType.openAnswer,
                            };
                            return TeacherQuestion(
                              id: 'ai-q-${DateTime.now().microsecondsSinceEpoch}-$i',
                              type: type,
                              prompt:
                                  '[$difficulty] $bookName bo‘yicha ${i + 1}-savol: asosiy qoidani qo‘llab natijani toping.',
                              options: type == TeacherQuestionType.multipleChoice
                                  ? const ['A) 12', 'B) 18', 'C) 24', 'D) 30']
                                  : const [],
                              correctAnswer:
                                  type == TeacherQuestionType.multipleChoice
                                  ? 'B) 18'
                                  : '18',
                              solutionText:
                                  'AI yechimi: $bookName dagi formulaga ko‘ra bosqichma-bosqich hisoblanadi.',
                            );
                          },
                        );
                        Navigator.of(sheetContext).pop(
                          TeacherTestItem(
                            id: 'ai-test-${DateTime.now().microsecondsSinceEpoch}',
                            title: 'AI test: $bookName',
                            attemptsCount: 0,
                            isActive: false,
                            timeLimitMinutes: count * 2,
                            questions: questions,
                          ),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('AI bilan savollar yaratish'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (generated != null && mounted) {
      setState(() => _tests = [generated, ..._tests]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'AI ${generated.questions.length} ta savol tuzib berdi — tekshirib tahrirlang',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _openEditor(0);
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
            title: Text('Test yaratish'),
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_subjectTitle testlari',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: IlmColors.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'A/B/C/D, ochiq javob, moslashtirish, yechimli savollar, qog‘oz A/B variantlar va jonli sinf testlarini yarating.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: IlmColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            key: const ValueKey('createTestButton'),
                            onPressed: _openCreateTestSheet,
                            icon: const Icon(Icons.add),
                            label: const Text('Yangi test yaratish'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            key: const ValueKey('aiGenerateTestButton'),
                            onPressed: _openAiGeneratorSheet,
                            icon: const Icon(
                              Icons.auto_awesome_outlined,
                              color: IlmColors.accent,
                            ),
                            label: const Text('AI bilan kitobdan test tuzish'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Yaratilgan testlar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: IlmColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < _tests.length; i++) ...[
                  Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: IlmColors.line),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: IlmColors.accent.withValues(alpha: 0.12),
                        child: const Icon(
                          Icons.quiz_outlined,
                          color: IlmColors.accent,
                        ),
                      ),
                      title: Text(
                        _tests[i].title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: IlmColors.ink,
                        ),
                      ),
                      subtitle: Text(
                        '${_tests[i].questions.length} ta savol · ${_tests[i].timeLimitMinutes} daq · ${_tests[i].attemptsCount} marta ishlangan',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: IlmColors.inkMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: IlmColors.inkMuted,
                      ),
                      onTap: () => _openEditor(i),
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
