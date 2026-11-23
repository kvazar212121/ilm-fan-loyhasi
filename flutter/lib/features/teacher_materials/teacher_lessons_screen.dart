import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/features/teacher_materials/textbook_editor_screen.dart';
import 'package:ilm_fan/models/teacher_textbook.dart';
import 'package:ilm_fan/models/textbook_comment.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class TeacherLessonsScreen extends StatefulWidget {
  const TeacherLessonsScreen({
    super.key,
    required this.profile,
    this.textbooks,
    this.onTextbooksChanged,
    this.comments = const [],
    this.onAddComment,
  });

  final UserProfile profile;
  final List<TeacherTextbook>? textbooks;
  final ValueChanged<List<TeacherTextbook>>? onTextbooksChanged;
  final List<TextbookComment> comments;
  final ValueChanged<TextbookComment>? onAddComment;

  @override
  State<TeacherLessonsScreen> createState() => _TeacherLessonsScreenState();
}

class _TeacherLessonsScreenState extends State<TeacherLessonsScreen> {
  late List<TeacherTextbook> _items;

  String get _subjectTitle =>
      tayyorlovFanById(widget.profile.subjectFanId)?.title ?? 'Umumiy fan';

  @override
  void initState() {
    super.initState();
    _items = widget.textbooks != null
        ? [...widget.textbooks!]
        : buildSampleTextbooks(_subjectTitle);
  }

  void _updateItems(List<TeacherTextbook> next) {
    setState(() => _items = next);
    widget.onTextbooksChanged?.call(next);
  }

  Future<void> _openEditor(int index) async {
    final updated = await Navigator.of(context).push<TeacherTextbook>(
      MaterialPageRoute<TeacherTextbook>(
        builder: (_) => TextbookEditorScreen(
          textbook: _items[index],
          comments: widget.comments,
          onAddComment: widget.onAddComment,
        ),
      ),
    );
    if (updated != null && mounted) {
      final copy = [..._items];
      copy[index] = updated;
      _updateItems(copy);
    }
  }

  Future<void> _openCreateSheet() async {
    final titleController = TextEditingController();
    final gradeController = TextEditingController(text: '9–11-sinf');

    final created = await showModalBottomSheet<TeacherTextbook>(
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
                'Yangi darslik yaratish',
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
                  labelText: 'Darslik nomi',
                  hintText: 'Masalan: Kvadrat tenglamalar qo‘llanmasi',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(
                  labelText: 'Sinf yoki auditoriya',
                  hintText: 'Masalan: 10-sinf',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;
                  Navigator.of(sheetContext).pop(
                    TeacherTextbook(
                      id: 'tb-${DateTime.now().microsecondsSinceEpoch}',
                      title: title,
                      grade: gradeController.text.trim().isEmpty
                          ? 'Umumiy'
                          : gradeController.text.trim(),
                      published: false,
                      sequentialLock: true,
                      sections: const [
                        TextbookSection(
                          id: 'sec-initial',
                          title: '1-bo‘lim. Asosiy mavzular',
                          topics: [],
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Yaratish va tahrirlash'),
              ),
            ],
          ),
        );
      },
    );

    if (created != null && mounted) {
      _updateItems([created, ..._items]);
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
            title: Text('Darsliklar yaratish'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HeroCreateCard(
                  subject: _subjectTitle,
                  count: _items.length,
                  onCreate: _openCreateSheet,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mening darsliklarim',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: IlmColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < _items.length; i++) ...[
                  _TextbookTile(
                    item: _items[i],
                    onTap: () => _openEditor(i),
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

class _HeroCreateCard extends StatelessWidget {
  const _HeroCreateCard({
    required this.subject,
    required this.count,
    required this.onCreate,
  });

  final String subject;
  final int count;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: IlmColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: IlmColors.accent,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$count ta darslik',
                  style: const TextStyle(
                    fontSize: 12,
                    color: IlmColors.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Bo‘lim, mavzu va testli darsliklar',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: IlmColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Har bir mavzuga matn, PDF, video, ovozli tushuntirish, rasm hamda keyingi darsni ochuvchi oraliq test qo‘shing.',
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
                key: const ValueKey('createTextbookButton'),
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Yangi darslik yaratish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextbookTile extends StatelessWidget {
  const _TextbookTile({required this.item, required this.onTap});

  final TeacherTextbook item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lockLabel = item.gatedTopicsCount > 0
        ? ' · ${item.gatedTopicsCount} ta test qulfi'
        : '';

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: IlmColors.line),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: IlmColors.accent.withValues(alpha: 0.12),
          child: const Icon(
            Icons.auto_stories_outlined,
            color: IlmColors.accent,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: IlmColors.ink,
          ),
        ),
        subtitle: Text(
          '${item.grade} · ${item.sections.length} bo‘lim · ${item.totalTopics} mavzu$lockLabel · ${item.published ? 'Nashrda' : 'Qoralama'}',
          style: const TextStyle(fontSize: 12.5, color: IlmColors.inkMuted),
        ),
        trailing: const Icon(Icons.chevron_right, color: IlmColors.inkMuted),
        onTap: onTap,
      ),
    );
  }
}
