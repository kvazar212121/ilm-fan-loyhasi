import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/models/teacher_textbook.dart';
import 'package:ilm_fan/models/textbook_comment.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class TextbookStudentPreviewScreen extends StatefulWidget {
  const TextbookStudentPreviewScreen({
    super.key,
    required this.textbook,
    this.comments = const [],
    this.onAddComment,
  });

  final TeacherTextbook textbook;
  final List<TextbookComment> comments;
  final ValueChanged<TextbookComment>? onAddComment;

  @override
  State<TextbookStudentPreviewScreen> createState() =>
      _TextbookStudentPreviewScreenState();
}

class _TextbookStudentPreviewScreenState
    extends State<TextbookStudentPreviewScreen> {
  final Set<String> _passedTopicIds = {};
  final Set<String> _confusedBlockIds = {};
  final Set<String> _submittedHomeworkIds = {};
  late List<TextbookComment> _localComments;
  String? _playingAudioId;

  @override
  void initState() {
    super.initState();
    _localComments = [...widget.comments];
  }

  List<TextbookTopic> get _allTopics => [
    for (final section in widget.textbook.sections) ...section.topics,
  ];

  bool _isTopicUnlocked(int flatIndex) {
    if (!widget.textbook.sequentialLock || flatIndex == 0) return true;
    final previous = _allTopics[flatIndex - 1];
    if (!previous.requireTestPassToUnlockNext) return true;
    return _passedTopicIds.contains(previous.id);
  }

  void _openTopicModal(TextbookTopic topic) {
    final commentController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IlmColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            void toggleConfused(String blockId) {
              setState(() {
                if (!_confusedBlockIds.add(blockId)) {
                  _confusedBlockIds.remove(blockId);
                }
              });
              setSheetState(() {});
            }

            void sendComment() {
              final text = commentController.text.trim();
              if (text.isEmpty) return;
              final created = TextbookComment(
                id: 'cmt-${DateTime.now().microsecondsSinceEpoch}',
                studentName: 'O‘quvchi (sinov)',
                topicTitle: topic.title,
                text: text,
                createdAtLabel: 'Hozirgina',
              );
              setState(() => _localComments = [created, ..._localComments]);
              widget.onAddComment?.call(created);
              commentController.clear();
              setSheetState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Izoh yuborildi — o‘qituvchining Hisobotlar bo‘limiga tushdi',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            final topicComments = _localComments
                .where((c) => c.topicTitle == topic.title)
                .toList(growable: false);

            void simulateTest(int scorePercent) {
              final passed = scorePercent >= topic.passingScorePercent;
              if (passed) {
                setState(() => _passedTopicIds.add(topic.id));
              }
              setSheetState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    passed
                        ? 'Natija: $scorePercent% — Testdan o‘tdingiz! Keyingi mavzu ochildi.'
                        : 'Natija: $scorePercent% — Kamida ${topic.passingScorePercent}% kerak. Keyingi mavzu yopiq.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.82,
              maxChildSize: 0.94,
              minChildSize: 0.5,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: IlmColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.requireTestPassToUnlockNext
                          ? 'Shart: testdan ≥${topic.passingScorePercent}% · ${topic.maxAttempts == 0 ? 'cheksiz urinish' : '${topic.maxAttempts} urinish'}'
                          : 'Erkin mavzu',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final block in topic.blocks) ...[
                      _PreviewBlockCard(
                        block: block,
                        isConfused: _confusedBlockIds.contains(block.id),
                        isPlaying: _playingAudioId == block.id,
                        isHomeworkSent: _submittedHomeworkIds.contains(block.id),
                        isTestPassed: _passedTopicIds.contains(topic.id),
                        passingScore: topic.passingScorePercent,
                        onToggleConfused: () => toggleConfused(block.id),
                        onTogglePlay: () {
                          setState(() {
                            _playingAudioId = _playingAudioId == block.id
                                ? null
                                : block.id;
                          });
                          setSheetState(() {});
                        },
                        onSubmitHomework: () {
                          setState(() => _submittedHomeworkIds.add(block.id));
                          setSheetState(() {});
                        },
                        onSimulateFail: () => simulateTest(
                          (topic.passingScorePercent - 20).clamp(10, 50),
                        ),
                        onSimulatePass: () => simulateTest(
                          (topic.passingScorePercent + 15).clamp(70, 100),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 6),
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
                            const Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 18,
                                  color: IlmColors.accent,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Savollar va izohlar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: IlmColors.ink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (topicComments.isEmpty)
                              const Text(
                                'Tushunmagan joyingiz bo‘lsa savol yozing — ustoz Hisobotlar bo‘limidan javob beradi.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: IlmColors.inkMuted,
                                ),
                              )
                            else
                              for (final c in topicComments) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: IlmColors.paper,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${c.studentName} · ${c.createdAtLabel}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: IlmColors.inkMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        c.text,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          color: IlmColors.ink,
                                        ),
                                      ),
                                      if (c.isAnswered) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'Ustoz javobi: ${c.teacherReply}',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: IlmColors.accent,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    key: const ValueKey('topicCommentField'),
                                    controller: commentController,
                                    decoration: const InputDecoration(
                                      hintText: 'Savol yoki izoh yozing...',
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  key: const ValueKey('sendTopicCommentButton'),
                                  onPressed: sendComment,
                                  child: const Text('Yuborish'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var flatIndex = 0;

    return Scaffold(
      backgroundColor: IlmColors.paper,
      appBar: AppBar(
        backgroundColor: IlmColors.paper,
        surfaceTintColor: Colors.transparent,
        title: const Text('O‘quvchi ko‘rinishi'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: IlmColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: IlmColors.accent.withValues(alpha: 0.25),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    color: IlmColors.accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _confusedBlockIds.isEmpty
                          ? 'Sinov rejimi: mavzuni ochib test va qulf ishlashini tekshiring.'
                          : '«Tushunmadim» belgilangan bloklar: ${_confusedBlockIds.length} ta (Hisobotga tushadi).',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: IlmColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final section in widget.textbook.sections) ...[
            Text(
              section.title,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: IlmColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            for (final topic in section.topics) ...[
              Builder(
                builder: (_) {
                  final currentIdx = flatIndex++;
                  final unlocked = _isTopicUnlocked(currentIdx);
                  final passed = _passedTopicIds.contains(topic.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: unlocked
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.65),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: IlmColors.line),
                      ),
                      child: ListTile(
                        key: ValueKey('preview-topic-${topic.id}'),
                        leading: CircleAvatar(
                          backgroundColor: unlocked
                              ? IlmColors.accent.withValues(alpha: 0.12)
                              : IlmColors.line,
                          child: Icon(
                            passed
                                ? Icons.check_rounded
                                : (unlocked
                                      ? Icons.play_arrow_rounded
                                      : Icons.lock_outline_rounded),
                            color: unlocked
                                ? IlmColors.accent
                                : IlmColors.inkMuted,
                          ),
                        ),
                        title: Text(
                          topic.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: unlocked
                                ? IlmColors.ink
                                : IlmColors.inkMuted,
                          ),
                        ),
                        subtitle: Text(
                          unlocked
                              ? (passed
                                    ? 'Testdan o‘tilgan · ${topic.blocks.length} ta material'
                                    : '${topic.blocks.length} ta material')
                              : 'Qulflangan — oldingi mavzu testidan o‘ting',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: IlmColors.inkMuted,
                          ),
                        ),
                        onTap: unlocked
                            ? () => _openTopicModal(topic)
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Avval oldingi mavzu testidan o‘tishingiz kerak',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PreviewBlockCard extends StatelessWidget {
  const _PreviewBlockCard({
    required this.block,
    required this.isConfused,
    required this.isPlaying,
    required this.isHomeworkSent,
    required this.isTestPassed,
    required this.passingScore,
    required this.onToggleConfused,
    required this.onTogglePlay,
    required this.onSubmitHomework,
    required this.onSimulateFail,
    required this.onSimulatePass,
  });

  final LessonMaterialBlock block;
  final bool isConfused;
  final bool isPlaying;
  final bool isHomeworkSent;
  final bool isTestPassed;
  final int passingScore;
  final VoidCallback onToggleConfused;
  final VoidCallback onTogglePlay;
  final VoidCallback onSubmitHomework;
  final VoidCallback onSimulateFail;
  final VoidCallback onSimulatePass;

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
                Icon(block.type.icon, size: 20, color: IlmColors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    block.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: IlmColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            if (block.content.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                block.content,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: IlmColors.inkMuted,
                ),
              ),
            ],
            if (block.type == LessonMaterialType.audio) ...[
              const SizedBox(height: 10),
              if (block.visualKind != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: IlmColors.paper,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: IlmColors.line),
                  ),
                  child: Column(
                    children: [
                      if (block.visualLocalPath != null && !kIsWeb)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(block.visualLocalPath!),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              block.visualKind!.icon,
                              color: IlmColors.accent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              block.visualFileName ?? block.visualKind!.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: IlmColors.ink,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onTogglePlay,
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                ),
                label: Text(
                  isPlaying ? 'Ovozli tushuntirish ijroda...' : 'Ovozni tinglash',
                ),
              ),
            ],
            if (block.type == LessonMaterialType.homework) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: isHomeworkSent ? null : onSubmitHomework,
                icon: Icon(
                  isHomeworkSent
                      ? Icons.check_circle_outline
                      : Icons.camera_alt_outlined,
                ),
                label: Text(
                  isHomeworkSent
                      ? 'Uy vazifasi yuborildi'
                      : 'Yechim rasmini yuborish',
                ),
              ),
            ],
            if (block.type == LessonMaterialType.test) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    key: const ValueKey('simulateTestFail'),
                    onPressed: onSimulateFail,
                    child: const Text('Past ball (sinov)'),
                  ),
                  FilledButton(
                    key: const ValueKey('simulateTestPass'),
                    onPressed: onSimulatePass,
                    child: Text(
                      isTestPassed
                          ? 'O‘tilgan (≥$passingScore%)'
                          : 'Testdan o‘tish (sinov)',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: ValueKey('confused-${block.id}'),
                onPressed: onToggleConfused,
                icon: Icon(
                  isConfused
                      ? Icons.help_rounded
                      : Icons.help_outline_rounded,
                  size: 16,
                  color: isConfused
                      ? const Color(0xFFB45309)
                      : IlmColors.inkMuted,
                ),
                label: Text(
                  isConfused ? 'Tushunmadim (belgilandi)' : 'Tushunmadim',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isConfused
                        ? const Color(0xFFB45309)
                        : IlmColors.inkMuted,
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
