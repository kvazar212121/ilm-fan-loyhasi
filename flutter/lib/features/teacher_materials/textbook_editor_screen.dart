import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/features/teacher_materials/textbook_student_preview_screen.dart';
import 'package:ilm_fan/features/teacher_materials/topic_editor_screen.dart';
import 'package:ilm_fan/models/teacher_textbook.dart';
import 'package:ilm_fan/models/textbook_comment.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class TextbookEditorScreen extends StatefulWidget {
  const TextbookEditorScreen({
    super.key,
    required this.textbook,
    this.comments = const [],
    this.onAddComment,
  });

  final TeacherTextbook textbook;
  final List<TextbookComment> comments;
  final ValueChanged<TextbookComment>? onAddComment;

  @override
  State<TextbookEditorScreen> createState() => _TextbookEditorScreenState();
}

class _TextbookEditorScreenState extends State<TextbookEditorScreen> {
  late TeacherTextbook _textbook;

  @override
  void initState() {
    super.initState();
    _textbook = widget.textbook;
  }

  Future<void> _addSection() async {
    final controller = TextEditingController();
    final title = await showModalBottomSheet<String>(
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
                'Yangi bo‘lim qo‘shish',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: IlmColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('sectionTitleField'),
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Bo‘lim nomi',
                  hintText:
                      'Masalan: ${_textbook.sections.length + 1}-bo‘lim. Tenglamalar',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('confirmAddSectionButton'),
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.isEmpty) return;
                  Navigator.of(sheetContext).pop(value);
                },
                child: const Text('Qo‘shish'),
              ),
            ],
          ),
        );
      },
    );

    if (title != null && mounted) {
      final newSection = TextbookSection(
        id: 'sec-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        topics: const [],
      );
      setState(() {
        _textbook = _textbook.copyWith(
          sections: [..._textbook.sections, newSection],
        );
      });
    }
  }

  Future<void> _addTopic(int sectionIndex) async {
    final section = _textbook.sections[sectionIndex];
    final controller = TextEditingController();
    final title = await showModalBottomSheet<String>(
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
                'Yangi mavzu qo‘shish',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: IlmColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('topicTitleField'),
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Mavzu nomi',
                  hintText:
                      'Masalan: ${section.topics.length + 1}-mavzu. Asosiy misollar',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('confirmAddTopicButton'),
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.isEmpty) return;
                  Navigator.of(sheetContext).pop(value);
                },
                child: const Text('Yaratish'),
              ),
            ],
          ),
        );
      },
    );

    if (title != null && mounted) {
      final newTopic = TextbookTopic(
        id: 'top-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        blocks: const [],
      );
      final updatedSections = [..._textbook.sections];
      updatedSections[sectionIndex] = section.copyWith(
        topics: [...section.topics, newTopic],
      );
      setState(() {
        _textbook = _textbook.copyWith(sections: updatedSections);
      });
      await _openTopicEditor(sectionIndex, section.topics.length);
    }
  }

  Future<void> _openTopicEditor(int sectionIndex, int topicIndex) async {
    final section = _textbook.sections[sectionIndex];
    final topic = section.topics[topicIndex];

    final updated = await Navigator.of(context).push<TextbookTopic>(
      MaterialPageRoute<TextbookTopic>(
        builder: (_) => TopicEditorScreen(topic: topic),
      ),
    );

    if (updated != null && mounted) {
      final updatedTopics = [...section.topics];
      updatedTopics[topicIndex] = updated;
      final updatedSections = [..._textbook.sections];
      updatedSections[sectionIndex] = section.copyWith(topics: updatedTopics);
      setState(() {
        _textbook = _textbook.copyWith(sections: updatedSections);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<TeacherTextbook>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(_textbook);
        }
      },
      child: Scaffold(
        backgroundColor: IlmColors.paper,
        appBar: AppBar(
          backgroundColor: IlmColors.paper,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_textbook),
          ),
          title: Text(
            _textbook.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              key: const ValueKey('openStudentPreviewButton'),
              tooltip: 'O‘quvchi ko‘rinishi',
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => TextbookStudentPreviewScreen(
                      textbook: _textbook,
                      comments: widget.comments,
                      onAddComment: widget.onAddComment,
                    ),
                  ),
                );
              },
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _textbook = _textbook.copyWith(
                    published: !_textbook.published,
                  );
                });
              },
              child: Text(
                _textbook.published ? 'Nashrda' : 'Nashr qilish',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: IlmColors.accent,
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: IlmColors.line),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: IlmColors.accent.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: IlmColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sinf / Guruh taklif kodi',
                            style: TextStyle(
                              fontSize: 12,
                              color: IlmColors.inkMuted,
                            ),
                          ),
                          Text(
                            _textbook.inviteCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: IlmColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _textbook.inviteCode),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Taklif kodi nusxalandi: ${_textbook.inviteCode}',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Nusxalash'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                    Row(
                      children: [
                        const Icon(
                          Icons.route_outlined,
                          size: 20,
                          color: IlmColors.accent,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Ketma-ket ochilish qoidasi',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: IlmColors.ink,
                            ),
                          ),
                        ),
                        Switch(
                          value: _textbook.sequentialLock,
                          activeThumbColor: IlmColors.accent,
                          onChanged: (value) {
                            setState(() {
                              _textbook = _textbook.copyWith(
                                sequentialLock: value,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _textbook.sequentialLock
                          ? 'O‘quvchi har bir mavzuni va uning oraliq testini topshirmasdan keyingi mavzuga o‘ta olmaydi.'
                          : 'Barcha mavzular o‘quvchi uchun erkin ochiq bo‘ladi.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  'Bo‘limlar va mavzular',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: IlmColors.ink,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_textbook.sections.length} bo‘lim · ${_textbook.totalTopics} mavzu',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: IlmColors.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var sIdx = 0; sIdx < _textbook.sections.length; sIdx++) ...[
              _SectionCard(
                section: _textbook.sections[sIdx],
                onAddTopic: () => _addTopic(sIdx),
                onOpenTopic: (tIdx) => _openTopicEditor(sIdx, tIdx),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              key: const ValueKey('addSectionButton'),
              onPressed: _addSection,
              icon: const Icon(Icons.add),
              label: const Text('Bo‘lim qo‘shish'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.onAddTopic,
    required this.onOpenTopic,
  });

  final TextbookSection section;
  final VoidCallback onAddTopic;
  final ValueChanged<int> onOpenTopic;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
            Text(
              section.title,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: IlmColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            if (section.topics.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Bu bo‘limda hali mavzu yo‘q.',
                  style: TextStyle(fontSize: 13, color: IlmColors.inkMuted),
                ),
              )
            else
              for (var tIdx = 0; tIdx < section.topics.length; tIdx++) ...[
                _TopicRow(
                  topic: section.topics[tIdx],
                  onTap: () => onOpenTopic(tIdx),
                ),
                const SizedBox(height: 8),
              ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddTopic,
                icon: const Icon(Icons.add, size: 18, color: IlmColors.accent),
                label: const Text(
                  'Mavzu qo‘shish',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: IlmColors.accent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic, required this.onTap});

  final TextbookTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: IlmColors.paper.withValues(alpha: 0.65),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: IlmColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: IlmColors.ink,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: IlmColors.inkMuted,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final block in topic.blocks)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: IlmColors.line),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            block.type.icon,
                            size: 13,
                            color: IlmColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            block.type.label,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: IlmColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (topic.requireTestPassToUnlockNext)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: IlmColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 13,
                            color: IlmColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Test ≥${topic.passingScorePercent}%',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: IlmColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
