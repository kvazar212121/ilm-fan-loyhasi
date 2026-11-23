import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/models/teacher_textbook.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class TopicEditorScreen extends StatefulWidget {
  const TopicEditorScreen({super.key, required this.topic});

  final TextbookTopic topic;

  @override
  State<TopicEditorScreen> createState() => _TopicEditorScreenState();
}

class _TopicEditorScreenState extends State<TopicEditorScreen> {
  late TextEditingController _titleController;
  late List<LessonMaterialBlock> _blocks;
  late bool _requireTestPass;
  late int _passingScore;
  late int _maxAttempts;
  late int _timeLimitMinutes;

  static const _scoreOptions = [60, 70, 80, 90];
  static const _attemptOptions = [1, 2, 3, 0];
  static const _timeOptions = [10, 15, 30, 0];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topic.title);
    _blocks = [...widget.topic.blocks];
    _requireTestPass = widget.topic.requireTestPassToUnlockNext;
    _passingScore = widget.topic.passingScorePercent;
    _maxAttempts = widget.topic.maxAttempts;
    _timeLimitMinutes = widget.topic.timeLimitMinutes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  TextbookTopic _buildResult() {
    final title = _titleController.text.trim();
    return widget.topic.copyWith(
      title: title.isEmpty ? widget.topic.title : title,
      blocks: _blocks,
      requireTestPassToUnlockNext: _requireTestPass,
      passingScorePercent: _passingScore,
      maxAttempts: _maxAttempts,
      timeLimitMinutes: _timeLimitMinutes,
    );
  }

  void _saveAndClose() {
    Navigator.of(context).pop(_buildResult());
  }

  Future<void> _pickMaterialType() async {
    final selectedType = await showModalBottomSheet<LessonMaterialType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IlmColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Material turini tanlang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: IlmColors.ink,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  itemCount: LessonMaterialType.values.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 54,
                  ),
                  itemBuilder: (_, index) {
                    final type = LessonMaterialType.values[index];
                    return Material(
                      color: Colors.white,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: IlmColors.line),
                      ),
                      child: InkWell(
                        key: ValueKey('pick-material-${type.name}'),
                        onTap: () => Navigator.of(sheetContext).pop(type),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                type.icon,
                                size: 20,
                                color: IlmColors.accent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  type.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: IlmColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedType != null && mounted) {
      await _openAddBlockForm(selectedType);
    }
  }

  Future<void> _openAddBlockForm(LessonMaterialType type) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final questionsController = TextEditingController(text: '10');
    final visualController = TextEditingController();
    var selectedVisualKind = AudioVisualKind.image;
    String? pickedVisualPath;

    final block = await showModalBottomSheet<LessonMaterialBlock>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IlmColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> pickVisualFile() async {
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (picked == null) return;
              setSheetState(() {
                pickedVisualPath = picked.path;
                visualController.text = picked.name;
                if (picked.name.toLowerCase().endsWith('.gif')) {
                  selectedVisualKind = AudioVisualKind.gif;
                }
              });
            }

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
                    Row(
                      children: [
                        Icon(type.icon, color: IlmColors.accent),
                        const SizedBox(width: 8),
                        Text(
                          '${type.label} qo‘shish',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: IlmColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      key: const ValueKey('blockTitleField'),
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Sarlavha',
                        hintText: 'Masalan: ${type.label}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const ValueKey('blockContentField'),
                      controller: contentController,
                      maxLines: type == LessonMaterialType.text ? 4 : 2,
                      decoration: InputDecoration(
                        labelText: type == LessonMaterialType.text
                            ? 'Matn mazmuni'
                            : (type == LessonMaterialType.audio
                                  ? 'Ovozli fayl yoki qisqa izoh'
                                  : 'Fayl nomi yoki izoh'),
                        hintText: type.placeholderHint,
                      ),
                    ),
                    if (type == LessonMaterialType.audio) ...[
                      const SizedBox(height: 14),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: IlmColors.line),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nimani tushuntirasiz? (Rasm yoki GIF)',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: IlmColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'O‘quvchi ovozni eshitayotganda ko‘radigan rasm yoki GIF ni biriktiring.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: IlmColors.inkMuted,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                children: [
                                  for (final kind in AudioVisualKind.values)
                                    ChoiceChip(
                                      key: ValueKey('audio-visual-${kind.name}'),
                                      avatar: Icon(
                                        kind.icon,
                                        size: 16,
                                        color: selectedVisualKind == kind
                                            ? IlmColors.accent
                                            : IlmColors.inkMuted,
                                      ),
                                      label: Text(kind.label),
                                      selected: selectedVisualKind == kind,
                                      selectedColor: IlmColors.accent
                                          .withValues(alpha: 0.16),
                                      onSelected: (_) => setSheetState(
                                        () => selectedVisualKind = kind,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                key: const ValueKey('audioVisualField'),
                                controller: visualController,
                                decoration: InputDecoration(
                                  labelText:
                                      selectedVisualKind == AudioVisualKind.gif
                                      ? 'GIF fayl nomi'
                                      : 'Rasm fayl nomi',
                                  hintText:
                                      selectedVisualKind == AudioVisualKind.gif
                                      ? 'Masalan: yechim_bosqichlari.gif'
                                      : 'Masalan: formula_chizmasi.png',
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: pickVisualFile,
                                icon: Icon(selectedVisualKind.icon, size: 18),
                                label: Text(
                                  selectedVisualKind == AudioVisualKind.gif
                                      ? 'Galereyadan GIF tanlash'
                                      : 'Galereyadan rasm tanlash',
                                ),
                              ),
                              if (pickedVisualPath != null && !kIsWeb) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(pickedVisualPath!),
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (type == LessonMaterialType.test) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: questionsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Savollar soni',
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const ValueKey('saveBlockButton'),
                      onPressed: () {
                        final title = titleController.text.trim();
                        final fallbackTitle = type.label;
                        final questions = type == LessonMaterialType.test
                            ? (int.tryParse(questionsController.text.trim()) ??
                                  10)
                            : null;
                        final visualName = visualController.text.trim();
                        Navigator.of(sheetContext).pop(
                          LessonMaterialBlock(
                            id: 'blk-${DateTime.now().microsecondsSinceEpoch}',
                            type: type,
                            title: title.isEmpty ? fallbackTitle : title,
                            content: contentController.text.trim(),
                            questionsCount: questions,
                            visualKind: type == LessonMaterialType.audio
                                ? selectedVisualKind
                                : null,
                            visualFileName:
                                type == LessonMaterialType.audio &&
                                    visualName.isNotEmpty
                                ? visualName
                                : null,
                            visualLocalPath: type == LessonMaterialType.audio
                                ? pickedVisualPath
                                : null,
                          ),
                        );
                      },
                      child: const Text('Qo‘shish'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (block != null && mounted) {
      setState(() {
        _blocks = [..._blocks, block];
        if (block.type == LessonMaterialType.test && !_requireTestPass) {
          _requireTestPass = true;
        }
      });
    }
  }

  void _moveBlock(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _blocks.length) return;
    setState(() {
      final copy = [..._blocks];
      final item = copy.removeAt(index);
      copy.insert(target, item);
      _blocks = copy;
    });
  }

  void _removeBlock(int index) {
    setState(() {
      final copy = [..._blocks];
      copy.removeAt(index);
      _blocks = copy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasTest = _blocks.any((b) => b.type == LessonMaterialType.test);

    return Scaffold(
      backgroundColor: IlmColors.paper,
      appBar: AppBar(
        backgroundColor: IlmColors.paper,
        surfaceTintColor: Colors.transparent,
        title: const Text('Mavzuni tahrirlash'),
        actions: [
          TextButton(
            key: const ValueKey('saveTopicButton'),
            onPressed: _saveAndClose,
            child: const Text(
              'Saqlash',
              style: TextStyle(
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
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Mavzu nomi',
            ),
          ),
          const SizedBox(height: 16),
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
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: IlmColors.accent,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Testdan o‘tmasa keyingi darsni ochmaslik',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: IlmColors.ink,
                          ),
                        ),
                      ),
                      Switch(
                        key: const ValueKey('topicLockSwitch'),
                        value: _requireTestPass,
                        activeThumbColor: IlmColors.accent,
                        onChanged: (value) =>
                            setState(() => _requireTestPass = value),
                      ),
                    ],
                  ),
                  if (_requireTestPass) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Keyingi mavzu ochilishi uchun minimal natija:',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final score in _scoreOptions)
                          ChoiceChip(
                            label: Text('$score%'),
                            selected: _passingScore == score,
                            selectedColor:
                                IlmColors.accent.withValues(alpha: 0.16),
                            onSelected: (_) =>
                                setState(() => _passingScore = score),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Urinishlar soni:',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final attempt in _attemptOptions)
                          ChoiceChip(
                            label: Text(
                              attempt == 0 ? 'Cheksiz' : '$attempt marta',
                            ),
                            selected: _maxAttempts == attempt,
                            selectedColor:
                                IlmColors.accent.withValues(alpha: 0.16),
                            onSelected: (_) =>
                                setState(() => _maxAttempts = attempt),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Vaqt chegarasi:',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final minutes in _timeOptions)
                          ChoiceChip(
                            label: Text(
                              minutes == 0 ? 'Cheksiz' : '$minutes daq',
                            ),
                            selected: _timeLimitMinutes == minutes,
                            selectedColor:
                                IlmColors.accent.withValues(alpha: 0.16),
                            onSelected: (_) =>
                                setState(() => _timeLimitMinutes = minutes),
                          ),
                      ],
                    ),
                    if (!hasTest) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Eslatma: bu shart ishlashi uchun pastdan «Oraliq test» blokini ham qo‘shing.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text(
                'Mavzu materiallari',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: IlmColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                '${_blocks.length} ta blok',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: IlmColors.inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_blocks.isEmpty)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: IlmColors.line),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Hali material qo‘shilmagan. Matn, PDF, video, ovozli tushuntirish, rasm yoki oraliq test qo‘shing.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: IlmColors.inkMuted,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < _blocks.length; i++) ...[
              _BlockCard(
                block: _blocks[i],
                canMoveUp: i > 0,
                canMoveDown: i < _blocks.length - 1,
                onMoveUp: () => _moveBlock(i, -1),
                onMoveDown: () => _moveBlock(i, 1),
                onDelete: () => _removeBlock(i),
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const ValueKey('addMaterialBlockButton'),
            onPressed: _pickMaterialType,
            icon: const Icon(Icons.add),
            label: const Text('Material yoki test qo‘shish'),
          ),
        ],
      ),
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.block,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final LessonMaterialBlock block;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      block.type.label,
      if (block.questionsCount != null) '${block.questionsCount} ta savol',
      if (block.content.isNotEmpty) block.content,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IlmColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: IlmColors.accent.withValues(alpha: 0.12),
              child: Icon(block.type.icon, size: 19, color: IlmColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: IlmColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleParts.join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: IlmColors.inkMuted,
                    ),
                  ),
                  if (block.visualKind != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: IlmColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            block.visualKind!.icon,
                            size: 13,
                            color: IlmColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              block.visualFileName != null
                                  ? '${block.visualKind!.label} bilan: ${block.visualFileName}'
                                  : '${block.visualKind!.label} biriktirilgan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                  ],
                ],
              ),
            ),
            if (canMoveUp)
              IconButton(
                tooltip: 'Yuqoriga',
                icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                onPressed: onMoveUp,
              ),
            if (canMoveDown)
              IconButton(
                tooltip: 'Pastga',
                icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                onPressed: onMoveDown,
              ),
            IconButton(
              tooltip: 'O‘chirish',
              icon: const Icon(
                Icons.delete_outline,
                size: 19,
                color: IlmColors.inkMuted,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
