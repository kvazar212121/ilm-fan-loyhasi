import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/models/teacher_test.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class TestEditorScreen extends StatefulWidget {
  const TestEditorScreen({super.key, required this.testItem});

  final TeacherTestItem testItem;

  @override
  State<TestEditorScreen> createState() => _TestEditorScreenState();
}

class _TestEditorScreenState extends State<TestEditorScreen> {
  late TeacherTestItem _test;

  @override
  void initState() {
    super.initState();
    _test = widget.testItem;
  }

  Future<void> _openAddQuestionSheet() async {
    var selectedType = TeacherQuestionType.multipleChoice;
    final promptController = TextEditingController();
    final optAController = TextEditingController();
    final optBController = TextEditingController();
    final optCController = TextEditingController();
    final optDController = TextEditingController();
    final answerController = TextEditingController();
    final solutionController = TextEditingController();
    final imageController = TextEditingController();
    var hasVoiceSolution = false;

    final created = await showModalBottomSheet<TeacherQuestion>(
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
                    const Text(
                      'Yangi savol qo‘shish',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: IlmColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final type in TeacherQuestionType.values)
                          ChoiceChip(
                            key: ValueKey('qtype-${type.name}'),
                            label: Text(type.label),
                            selected: selectedType == type,
                            selectedColor:
                                IlmColors.accent.withValues(alpha: 0.16),
                            onSelected: (_) =>
                                setSheetState(() => selectedType = type),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const ValueKey('questionPromptField'),
                      controller: promptController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Savol matni',
                        hintText: 'Savol shartini yozing...',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: 'Chizma / rasm fayli (ixtiyoriy)',
                        hintText: 'Masalan: grafik_02.png',
                      ),
                    ),
                    if (selectedType == TeacherQuestionType.multipleChoice) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: optAController,
                              decoration: const InputDecoration(labelText: 'A'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: optBController,
                              decoration: const InputDecoration(labelText: 'B'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: optCController,
                              decoration: const InputDecoration(labelText: 'C'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: optDController,
                              decoration: const InputDecoration(labelText: 'D'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextField(
                      key: const ValueKey('questionAnswerField'),
                      controller: answerController,
                      decoration: InputDecoration(
                        labelText: 'To‘g‘ri javob',
                        hintText: selectedType == TeacherQuestionType.openAnswer
                            ? 'Masalan: 30'
                            : 'Masalan: A yoki to‘g‘ri variant',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: solutionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Yechim tushuntirishi',
                        hintText: 'O‘quvchi xato qilsa ko‘rinadigan yechim...',
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Ovozli yechim biriktirish',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: hasVoiceSolution,
                      activeThumbColor: IlmColors.accent,
                      onChanged: (v) =>
                          setSheetState(() => hasVoiceSolution = v),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      key: const ValueKey('saveQuestionButton'),
                      onPressed: () {
                        final prompt = promptController.text.trim();
                        if (prompt.isEmpty) return;
                        final opts =
                            selectedType == TeacherQuestionType.multipleChoice
                            ? [
                                optAController.text.trim(),
                                optBController.text.trim(),
                                optCController.text.trim(),
                                optDController.text.trim(),
                              ].where((e) => e.isNotEmpty).toList()
                            : const <String>[];
                        final img = imageController.text.trim();
                        Navigator.of(sheetContext).pop(
                          TeacherQuestion(
                            id: 'q-${DateTime.now().microsecondsSinceEpoch}',
                            type: selectedType,
                            prompt: prompt,
                            options: opts,
                            correctAnswer: answerController.text.trim().isEmpty
                                ? 'A'
                                : answerController.text.trim(),
                            solutionText: solutionController.text.trim(),
                            solutionHasVoice: hasVoiceSolution,
                            imageName: img.isEmpty ? null : img,
                          ),
                        );
                      },
                      child: const Text('Savolni saqlash'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (created != null && mounted) {
      setState(() {
        _test = _test.copyWith(questions: [..._test.questions, created]);
      });
    }
  }

  void _openPaperVariantsPreview() {
    final reversed = _test.questions.reversed.toList();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IlmColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Qog‘oz test (A va B variantlar)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: IlmColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_test.title} · ${_test.questions.length} ta savol aralashtirildi.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: IlmColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 14),
                _VariantCard(
                  label: 'A-variant',
                  questions: _test.questions,
                ),
                const SizedBox(height: 10),
                _VariantCard(
                  label: 'B-variant (aralashtirilgan)',
                  questions: reversed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openLiveQuizRoom() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: IlmColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Jonli sinf testi (Kahoot rejimi)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: IlmColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: IlmColors.line),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Xona kodi',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: IlmColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _test.liveRoomCode,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: IlmColors.accent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_test.questions.length} ta savol · ${_test.timeLimitMinutes} daqiqa',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: IlmColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Jonli test ochildi: ${_test.liveRoomCode}',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Jonli bellashuvni boshlash'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<TeacherTestItem>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_test);
      },
      child: Scaffold(
        backgroundColor: IlmColors.paper,
        appBar: AppBar(
          backgroundColor: IlmColors.paper,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_test),
          ),
          title: Text(
            _test.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('paperVariantButton'),
                    onPressed: _openPaperVariantsPreview,
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('Qog‘oz A/B'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('liveQuizButton'),
                    onPressed: _openLiveQuizRoom,
                    icon: const Icon(Icons.bolt_rounded, size: 18),
                    label: const Text('Jonli test'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Test savollari',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: IlmColors.ink,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_test.questions.length} ta savol',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: IlmColors.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < _test.questions.length; i++) ...[
              _QuestionCard(
                index: i + 1,
                question: _test.questions[i],
                onDelete: () {
                  final copy = [..._test.questions]..removeAt(i);
                  setState(() => _test = _test.copyWith(questions: copy));
                },
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 6),
            FilledButton.icon(
              key: const ValueKey('addQuestionButton'),
              onPressed: _openAddQuestionSheet,
              icon: const Icon(Icons.add),
              label: const Text('Savol qo‘shish'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.onDelete,
  });

  final int index;
  final TeacherQuestion question;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: IlmColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$index · ${question.type.label}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: IlmColors.accent,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'O‘chirish',
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: IlmColors.inkMuted,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              question.prompt,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: IlmColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'To‘g‘ri javob: ${question.correctAnswer}',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: IlmColors.accent,
              ),
            ),
            if (question.solutionText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Yechim: ${question.solutionText}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: IlmColors.inkMuted,
                ),
              ),
            ],
            if (question.imageName != null || question.solutionHasVoice) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  if (question.imageName != null)
                    _MiniTag(
                      icon: Icons.image_outlined,
                      label: question.imageName!,
                    ),
                  if (question.solutionHasVoice)
                    const _MiniTag(
                      icon: Icons.mic_none_rounded,
                      label: 'Ovozli yechim',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: IlmColors.paper,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: IlmColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: IlmColors.accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: IlmColors.ink),
          ),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({required this.label, required this.questions});

  final String label;
  final List<TeacherQuestion> questions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: IlmColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < questions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${i + 1}. ${questions[i].prompt}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: IlmColors.ink),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
