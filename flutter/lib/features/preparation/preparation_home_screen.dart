import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/preparation_lessons.dart';
import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class PreparationHomeScreen extends StatefulWidget {
  const PreparationHomeScreen({
    super.key,
    required this.profile,
    required this.onOpenTests,
    required this.onOpenCourses,
  });

  final UserProfile profile;
  final VoidCallback onOpenTests;
  final VoidCallback onOpenCourses;

  @override
  State<PreparationHomeScreen> createState() => _PreparationHomeScreenState();
}

class _PreparationHomeScreenState extends State<PreparationHomeScreen> {
  final Set<String> _completedLessons = {};

  String get _fanName =>
      tayyorlovFanById(widget.profile.subjectFanId)?.title ?? 'Fan tanlanmagan';

  List<PreparationLesson> get _lessons =>
      preparationLessonsByFanId[widget.profile.subjectFanId] ?? const [];

  PreparationLesson? get _nextLesson {
    for (final lesson in _lessons) {
      if (!_completedLessons.contains(lesson.id)) return lesson;
    }
    return _lessons.isEmpty ? null : _lessons.first;
  }

  bool get _isCertificateTeacher => widget.profile.role == RoleId.teacher;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: IlmColors.paper,
          surfaceTintColor: Colors.transparent,
          title: Text('Tayyorlov'),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 112),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _greeting,
              const SizedBox(height: 16),
              _heroCard,
              const SizedBox(height: 26),
              _sectionHeader(
                'Mavzular yo‘li',
                _lessons.isEmpty ? null : '${_lessons.length} ta mavzu',
              ),
              const SizedBox(height: 12),
              if (_lessons.isEmpty)
                _emptyLessonsCard
              else ...[
                for (var index = 0; index < _lessons.length; index++) ...[
                  _lessonTile(_lessons[index], index),
                  if (index != _lessons.length - 1) const SizedBox(height: 10),
                ],
              ],
              const SizedBox(height: 24),
              _practiceCard,
              const SizedBox(height: 14),
              _coursesCard,
            ]),
          ),
        ),
      ],
    );
  }

  Widget get _greeting => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Assalomu alaykum, ${widget.profile.firstName}',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: IlmColors.inkMuted,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        _isCertificateTeacher
            ? 'Sertifikatga tayyorgarlikni davom ettiring.'
            : 'Bugungi o‘qish rejangizni davom ettiring.',
        style: const TextStyle(fontSize: 14, color: IlmColors.inkMuted),
      ),
    ],
  );

  Widget get _heroCard {
    final lessons = _lessons;
    final completedCount = _completedLessons
        .where((id) => lessons.any((lesson) => lesson.id == id))
        .length;
    final progress = lessons.isEmpty ? 0.0 : completedCount / lessons.length;
    final nextLesson = _nextLesson;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [IlmColors.accent, Color(0xFF084C3D)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: IlmColors.accent.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  size: 15,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  _isCertificateTeacher
                      ? 'SERTIFIKATGA TAYYORLOV'
                      : 'SHAXSIY TAYYORLOV REJASI',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _fanName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _isCertificateTeacher
                ? 'Faningiz bo‘yicha darslarni o‘rganing va bilimni test bilan mustahkamlang.'
                : 'Tanlagan faningiz bo‘yicha mavzularni bosqichma-bosqich o‘rganing.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          if (lessons.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$completedCount/${lessons.length} dars',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('startPreparation'),
              onPressed: nextLesson == null
                  ? null
                  : () => _showLesson(nextLesson),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: IlmColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                lessons.isNotEmpty && completedCount == lessons.length
                    ? 'Mavzularni takrorlash'
                    : 'Darsni boshlash',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String? trailing) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: IlmColors.ink,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              color: IlmColors.inkMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _lessonTile(PreparationLesson lesson, int index) {
    final completed = _completedLessons.contains(lesson.id);
    const icons = [
      Icons.calculate_outlined,
      Icons.functions_rounded,
      Icons.architecture_rounded,
      Icons.show_chart_rounded,
    ];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        key: ValueKey('lesson-${lesson.id}'),
        borderRadius: BorderRadius.circular(19),
        onTap: () => _showLesson(lesson),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: completed
                  ? IlmColors.accent.withValues(alpha: 0.4)
                  : IlmColors.line,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: completed
                      ? IlmColors.accent.withValues(alpha: 0.12)
                      : IlmColors.paper,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  completed ? Icons.check_rounded : icons[index % icons.length],
                  color: IlmColors.accent,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        color: IlmColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lesson.subtitle,
                      style: const TextStyle(
                        color: IlmColors.inkMuted,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    color: IlmColors.accent,
                    size: 21,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lesson.minutes} daq.',
                    style: const TextStyle(
                      color: IlmColors.inkMuted,
                      fontSize: 11,
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

  Widget get _emptyLessonsCard => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: IlmColors.line),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.menu_book_outlined, color: IlmColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _fanName == 'Fan tanlanmagan'
                    ? 'Avval faningizni tanlang'
                    : '$_fanName darslari tayyorlanmoqda',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              const Text(
                'Hozircha boshqa fan materiallarini aralashtirib ko‘rsatmaymiz.',
                style: TextStyle(
                  color: IlmColors.inkMuted,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget get _practiceCard => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F1EC),
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: IlmColors.accent.withValues(alpha: 0.12)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.quiz_outlined, color: IlmColors.accent),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Bilimingizni mustahkamlang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          'Test bo‘limida ${_fanName.toLowerCase()} bo‘yicha mashq qiling. Har javobdan keyin yechim va izohni ko‘rasiz.',
          style: const TextStyle(
            color: IlmColors.inkMuted,
            fontSize: 13,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const ValueKey('openSubjectTests'),
            onPressed: widget.onOpenTests,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Test mashqiga o‘tish'),
          ),
        ),
      ],
    ),
  );

  Widget get _coursesCard => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      key: const ValueKey('openCourseCatalog'),
      onTap: widget.onOpenCourses,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: IlmColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: IlmColors.paper,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.play_lesson_outlined,
                color: IlmColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kurslar katalogi',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Faningiz bo‘yicha kurslarni ko‘ring',
                    style: TextStyle(color: IlmColors.inkMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: IlmColors.accent),
          ],
        ),
      ),
    ),
  );

  void _showLesson(PreparationLesson lesson) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: IlmColors.paper,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: IlmColors.ink,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${lesson.subtitle} · ${lesson.minutes} daqiqa',
                style: const TextStyle(color: IlmColors.inkMuted),
              ),
              const SizedBox(height: 20),
              _lessonContentCard(
                title: 'Asosiy tushuncha',
                text: lesson.explanation,
                icon: Icons.menu_book_outlined,
              ),
              const SizedBox(height: 12),
              _lessonContentCard(
                title: lesson.exampleTitle,
                text: lesson.example,
                icon: Icons.lightbulb_outline_rounded,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: ValueKey('finish-${lesson.id}'),
                  onPressed: () {
                    setState(() => _completedLessons.add(lesson.id));
                    Navigator.of(sheetContext).pop();
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Darsni tugatdim'),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: ValueKey('practice-${lesson.id}'),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    widget.onOpenTests();
                  },
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Shu fandan test ishlash'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lessonContentCard({
    required String title,
    required String text,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: IlmColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: IlmColors.accent, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 9),
          Text(text, style: const TextStyle(height: 1.5, fontSize: 14)),
        ],
      ),
    );
  }
}
