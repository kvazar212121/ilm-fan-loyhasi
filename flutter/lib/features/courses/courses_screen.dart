import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/sample_courses.dart';
import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

enum _CoursesTab { recommended, catalog, mine }

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  _CoursesTab _tab = _CoursesTab.recommended;
  String _category = 'Barchasi';
  String _searchQuery = '';
  SampleCourse? _selectedCourse;
  final Set<String> _enrolledCourseIds = {};
  final Set<String> _completedLessonIds = {};

  String get _subjectName =>
      tayyorlovFanById(widget.profile.subjectFanId)?.title ?? 'Fan tanlanmagan';

  List<SampleCourse> get _subjectCourses => sampleCourses
      .where((course) => course.subjectId == widget.profile.subjectFanId)
      .toList();

  List<SampleCourse> get _visibleCourses {
    var courses = _subjectCourses;
    if (_tab == _CoursesTab.mine) {
      courses = courses
          .where((course) => _enrolledCourseIds.contains(course.id))
          .toList();
    } else if (_tab == _CoursesTab.recommended) {
      final recommended = courses
          .where((course) => course.category == 'Attestatsiya')
          .toList();
      if (recommended.isNotEmpty) courses = recommended;
    }

    if (_tab == _CoursesTab.catalog && _category != 'Barchasi') {
      courses = courses
          .where((course) => course.category == _category)
          .toList();
    }
    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      courses = courses
          .where(
            (course) =>
                course.title.toLowerCase().contains(query) ||
                course.subtitle.toLowerCase().contains(query) ||
                course.instructor.toLowerCase().contains(query),
          )
          .toList();
    }
    return courses;
  }

  @override
  Widget build(BuildContext context) {
    final course = _selectedCourse;
    if (course != null) return _buildCourseDetail(course);
    return _buildCatalog();
  }

  Widget _buildCatalog() {
    final courses = _visibleCourses;
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: IlmColors.paper,
          surfaceTintColor: Colors.transparent,
          title: Text('Kurslar'),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 112),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _catalogHero,
              const SizedBox(height: 16),
              _subjectChip,
              const SizedBox(height: 16),
              _tabSelector,
              const SizedBox(height: 14),
              _searchField,
              if (_tab == _CoursesTab.catalog) ...[
                const SizedBox(height: 14),
                _categorySelector,
              ],
              const SizedBox(height: 18),
              if (courses.isEmpty)
                _emptyCatalog
              else ...[
                _sectionHeading,
                const SizedBox(height: 11),
                for (final course in courses) ...[
                  _courseCard(course),
                  const SizedBox(height: 12),
                ],
              ],
              const SizedBox(height: 4),
              _demoNotice,
            ]),
          ),
        ),
      ],
    );
  }

  Widget get _catalogHero => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [IlmColors.accent, Color(0xFF084C3D)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'KURS NAMUNALARI',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'O‘rganing,\nbosqichma-bosqich',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Darslar, misollar va mashqlar bir kursda.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.play_lesson_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
      ],
    ),
  );

  Widget get _subjectChip => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: IlmColors.line),
    ),
    child: Row(
      children: [
        const Icon(Icons.subject_rounded, color: IlmColors.accent, size: 20),
        const SizedBox(width: 9),
        const Text(
          'Tanlangan fan',
          style: TextStyle(color: IlmColors.inkMuted, fontSize: 13),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            _subjectName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: IlmColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget get _tabSelector {
    const items = [
      (tab: _CoursesTab.recommended, label: 'Tavsiya'),
      (tab: _CoursesTab.catalog, label: 'Katalog'),
      (tab: _CoursesTab.mine, label: 'Mening kurslarim'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            ChoiceChip(
              label: Text(items[index].label),
              selected: _tab == items[index].tab,
              onSelected: (_) => setState(() => _tab = items[index].tab),
              showCheckmark: false,
              backgroundColor: Colors.white,
              selectedColor: IlmColors.accent.withValues(alpha: 0.13),
              side: BorderSide(
                color: _tab == items[index].tab
                    ? IlmColors.accent.withValues(alpha: 0.35)
                    : IlmColors.line,
              ),
              labelStyle: TextStyle(
                color: _tab == items[index].tab
                    ? IlmColors.accent
                    : IlmColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (index != items.length - 1) const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }

  Widget get _searchField => TextField(
    key: const ValueKey('courseSearch'),
    onChanged: (value) => setState(() => _searchQuery = value),
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: 'Kurs yoki mavzuni qidiring',
      hintStyle: const TextStyle(color: IlmColors.inkMuted, fontSize: 14),
      prefixIcon: const Icon(Icons.search_rounded, color: IlmColors.inkMuted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: IlmColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: IlmColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: IlmColors.accent),
      ),
    ),
  );

  Widget get _categorySelector {
    const categories = ['Barchasi', 'Attestatsiya', 'Mavzu kursi'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < categories.length; index++) ...[
            ChoiceChip(
              label: Text(categories[index]),
              selected: _category == categories[index],
              onSelected: (_) => setState(() => _category = categories[index]),
              showCheckmark: false,
              backgroundColor: Colors.white,
              selectedColor: IlmColors.accent.withValues(alpha: 0.13),
              side: BorderSide(
                color: _category == categories[index]
                    ? IlmColors.accent.withValues(alpha: 0.35)
                    : IlmColors.line,
              ),
              labelStyle: TextStyle(
                color: _category == categories[index]
                    ? IlmColors.accent
                    : IlmColors.ink,
                fontSize: 12,
              ),
            ),
            if (index != categories.length - 1) const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }

  Widget get _sectionHeading => Row(
    children: [
      Expanded(
        child: Text(
          switch (_tab) {
            _CoursesTab.recommended => 'Sizga tavsiya qilamiz',
            _CoursesTab.catalog => 'Barcha kurslar',
            _CoursesTab.mine => 'Boshlagan kurslarim',
          },
          style: const TextStyle(
            color: IlmColors.ink,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Text(
        '${_visibleCourses.length} ta',
        style: const TextStyle(color: IlmColors.inkMuted, fontSize: 12),
      ),
    ],
  );

  Widget _courseCard(SampleCourse course) {
    final enrolled = _enrolledCourseIds.contains(course.id);
    final completed = _completedCount(course);
    final progress = course.lessonCount == 0
        ? 0.0
        : completed / course.lessonCount;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        key: ValueKey('course-${course.id}'),
        borderRadius: BorderRadius.circular(21),
        onTap: () => setState(() => _selectedCourse = course),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: IlmColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 7,
                runSpacing: 6,
                children: [
                  _smallBadge(course.category, accent: true),
                  _smallBadge('NAMUNA'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                course.title,
                style: const TextStyle(
                  color: IlmColors.ink,
                  fontSize: 17,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                course.subtitle,
                style: const TextStyle(
                  color: IlmColors.inkMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    color: IlmColors.accent,
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      course.instructor,
                      style: const TextStyle(
                        color: IlmColors.inkMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    course.level,
                    style: const TextStyle(
                      color: IlmColors.inkMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _metaItem(
                    Icons.view_module_outlined,
                    '${course.modules.length} modul',
                  ),
                  _metaItem(
                    Icons.play_lesson_outlined,
                    '${course.lessonCount} dars',
                  ),
                  _metaItem(
                    Icons.schedule_rounded,
                    _durationText(course.totalMinutes),
                  ),
                ],
              ),
              if (enrolled) ...[
                const SizedBox(height: 13),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: IlmColors.line,
                    color: IlmColors.accent,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$completed/${course.lessonCount} dars tugallangan',
                  style: const TextStyle(
                    color: IlmColors.inkMuted,
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 13),
              Row(
                children: [
                  Text(
                    enrolled ? 'Davom etish' : 'Bepul namuna darsi bor',
                    style: const TextStyle(
                      color: IlmColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: IlmColors.accent,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallBadge(String text, {bool accent = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: accent ? const Color(0xFFE8F1EC) : IlmColors.paper,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: accent ? IlmColors.accent : IlmColors.inkMuted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: accent ? 0 : 0.5,
      ),
    ),
  );

  Widget _metaItem(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: IlmColors.inkMuted, size: 15),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(color: IlmColors.inkMuted, fontSize: 11),
      ),
    ],
  );

  Widget get _emptyCatalog {
    final mine = _tab == _CoursesTab.mine;
    final hasSubject = widget.profile.subjectFanId != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: IlmColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: IlmColors.paper,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              mine ? Icons.school_outlined : Icons.menu_book_outlined,
              color: IlmColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            mine
                ? 'Hozircha kursga qo‘shilmagansiz'
                : !hasSubject
                ? 'Avval faningizni tanlang'
                : _searchQuery.isNotEmpty || _category != 'Barchasi'
                ? 'Bu qidiruvda kurs topilmadi'
                : '$_subjectName kurslari tayyorlanmoqda',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: IlmColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mine ? 'Katalogdan tanlangan fanga mos kursni ko‘rib chiqing.' : 'Boshqa fan kurslarini aralashtirib ko‘rsatmaymiz. Yangi kurslar joylanganda shu yerda chiqadi.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: IlmColors.inkMuted,
            ),
          ),
          if (mine) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => setState(() => _tab = _CoursesTab.catalog),
              child: const Text('Kurslar katalogini ko‘rish'),
            ),
          ],
        ],
      ),
    );
  }

  Widget get _demoNotice => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 17,
          color: IlmColors.inkMuted,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'Ko‘rsatilgan kurslar namuna. Haqiqiy kurslar va muallif profillari server ulanganidan keyin keladi.',
            style: const TextStyle(
              color: IlmColors.inkMuted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildCourseDetail(SampleCourse course) {
    final enrolled = _enrolledCourseIds.contains(course.id);
    final completed = _completedCount(course);
    final nextLesson = _nextLesson(course);
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: IlmColors.paper,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  tooltip: 'Kurslar ro‘yxatiga qaytish',
                  onPressed: () => setState(() => _selectedCourse = null),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                title: const Text('Kurs haqida'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 5, 18, 18),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _detailCover(course),
                    const SizedBox(height: 17),
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: IlmColors.ink,
                        fontSize: 23,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      course.subtitle,
                      style: const TextStyle(
                        color: IlmColors.inkMuted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _smallBadge(course.category, accent: true),
                        _smallBadge('NAMUNA'),
                        _smallBadge(course.level),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _instructorCard(course),
                    const SizedBox(height: 16),
                    _detailStats(course),
                    if (enrolled) ...[
                      const SizedBox(height: 16),
                      _courseProgress(course, completed),
                    ],
                    const SizedBox(height: 22),
                    _detailSectionTitle('Kurs haqida'),
                    const SizedBox(height: 7),
                    Text(
                      course.description,
                      style: const TextStyle(
                        color: IlmColors.inkMuted,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _detailSectionTitle('Kurs yakunida siz'),
                    const SizedBox(height: 9),
                    for (final outcome in course.outcomes)
                      _outcomeItem(outcome),
                    const SizedBox(height: 20),
                    _detailSectionTitle('Bepul tanishuv darsi'),
                    const SizedBox(height: 9),
                    if (course.previewLesson case final preview?)
                      _previewLessonTile(course, preview),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _detailSectionTitle('Kurs dasturi')),
                        Text(
                          '${course.modules.length} modul · ${course.lessonCount} dars',
                          style: const TextStyle(
                            color: IlmColors.inkMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    for (final module in course.modules)
                      _moduleCard(course, module, enrolled),
                    const SizedBox(height: 14),
                    _demoNotice,
                  ]),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: IlmColors.line)),
            ),
            child: FilledButton.icon(
              key: ValueKey('course-action-${course.id}'),
              onPressed: enrolled
                  ? nextLesson == null
                        ? null
                        : () => _openLesson(course, nextLesson)
                  : () => setState(() => _enrolledCourseIds.add(course.id)),
              icon: Icon(
                enrolled ? Icons.play_arrow_rounded : Icons.add_rounded,
              ),
              label: Text(enrolled ? 'Davom etish' : 'Bepul kursga qo‘shilish'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailCover(SampleCourse course) => Container(
    height: 154,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F6E56), Color(0xFF173F37)],
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Stack(
      children: [
        Positioned(
          right: 18,
          bottom: 13,
          child: Icon(
            course.subjectId == 'matematika'
                ? Icons.functions_rounded
                : Icons.science_outlined,
            size: 88,
            color: Colors.white.withValues(alpha: 0.13),
          ),
        ),
        Positioned(left: 18, top: 18, child: _smallBadge('NAMUNA KURS')),
        Positioned(
          left: 18,
          bottom: 18,
          child: Row(
            children: [
              const Icon(
                Icons.play_circle_outline_rounded,
                color: Colors.white,
                size: 29,
              ),
              const SizedBox(width: 9),
              Text(
                '${course.lessonCount} ta dars · ${_durationText(course.totalMinutes)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _instructorCard(SampleCourse course) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: IlmColors.line),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: IlmColors.paper,
          foregroundColor: IlmColors.accent,
          child: Icon(Icons.person_outline_rounded),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.instructor,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              const Text(
                'Muallif profili demo ko‘rinishida',
                style: TextStyle(color: IlmColors.inkMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        _smallBadge('DEMO'),
      ],
    ),
  );

  Widget _detailStats(SampleCourse course) => Row(
    children: [
      Expanded(
        child: _statCell(
          Icons.view_module_outlined,
          '${course.modules.length}',
          'modul',
        ),
      ),
      Expanded(
        child: _statCell(
          Icons.play_lesson_outlined,
          '${course.lessonCount}',
          'dars',
        ),
      ),
      Expanded(
        child: _statCell(
          Icons.schedule_rounded,
          _durationText(course.totalMinutes),
          'jami',
        ),
      ),
    ],
  );

  Widget _statCell(IconData icon, String value, String label) => Column(
    children: [
      Icon(icon, color: IlmColors.accent, size: 19),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      Text(
        label,
        style: const TextStyle(color: IlmColors.inkMuted, fontSize: 11),
      ),
    ],
  );

  Widget _courseProgress(SampleCourse course, int completed) {
    final progress = course.lessonCount == 0
        ? 0.0
        : completed / course.lessonCount;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1EC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Kursdagi jarayoningiz',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$completed/${course.lessonCount}',
                style: const TextStyle(
                  color: IlmColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white,
              color: IlmColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      color: IlmColors.ink,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _outcomeItem(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: IlmColors.accent,
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(height: 1.4, fontSize: 13)),
        ),
      ],
    ),
  );

  Widget _previewLessonTile(SampleCourse course, SampleCourseLesson lesson) =>
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: ValueKey('preview-${course.id}'),
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openLesson(course, lesson),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: IlmColors.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1EC),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: IlmColors.accent,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Bepul namuna · ${lesson.minutes} daqiqa',
                        style: const TextStyle(
                          color: IlmColors.inkMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: IlmColors.accent,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _moduleCard(
    SampleCourse course,
    SampleCourseModule module,
    bool enrolled,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: IlmColors.line),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          title: Text(
            module.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${module.lessons.length} ta dars',
            style: const TextStyle(fontSize: 11, color: IlmColors.inkMuted),
          ),
          children: [
            for (final lesson in module.lessons)
              ListTile(
                dense: true,
                key: ValueKey('course-lesson-${lesson.id}'),
                leading: Icon(
                  _completedLessonIds.contains(lesson.id)
                      ? Icons.check_circle_rounded
                      : lesson.isPreview
                      ? Icons.play_circle_outline_rounded
                      : enrolled
                      ? Icons.play_circle_outline_rounded
                      : Icons.lock_outline_rounded,
                  color: IlmColors.accent,
                ),
                title: Text(lesson.title, style: const TextStyle(fontSize: 13)),
                subtitle: Text('${lesson.minutes} daqiqa'),
                onTap: () {
                  if (enrolled || lesson.isPreview) {
                    _openLesson(course, lesson);
                  } else {
                    _showMessage('Darslarni ochish uchun kursga qo‘shiling.');
                  }
                },
              ),
          ],
        ),
      ),
    ),
  );

  int _completedCount(SampleCourse course) => course.lessons
      .where((lesson) => _completedLessonIds.contains(lesson.id))
      .length;

  SampleCourseLesson? _nextLesson(SampleCourse course) {
    for (final lesson in course.lessons) {
      if (!_completedLessonIds.contains(lesson.id)) return lesson;
    }
    return course.previewLesson;
  }

  String _durationText(int minutes) {
    if (minutes < 60) return '$minutes daq.';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return remainingMinutes == 0
        ? '$hours soat'
        : '$hours soat $remainingMinutes daq.';
  }

  void _openLesson(SampleCourse course, SampleCourseLesson lesson) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: IlmColors.paper,
      builder: (sheetContext) {
        final enrolled = _enrolledCourseIds.contains(course.id);
        final completed = _completedLessonIds.contains(lesson.id);
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _smallBadge(lesson.isPreview ? 'BEPUL NAMUNA' : course.title),
                const SizedBox(height: 12),
                Text(
                  lesson.title,
                  style: const TextStyle(
                    color: IlmColors.ink,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${course.title} · ${lesson.minutes} daqiqa',
                  style: const TextStyle(
                    color: IlmColors.inkMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                _lessonInfoCard('Dars mazmuni', lesson.summary),
                const SizedBox(height: 10),
                _lessonInfoCard('Misol', lesson.example),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: ValueKey('course-lesson-action-${lesson.id}'),
                    onPressed: () {
                      if (!enrolled) {
                        setState(() => _enrolledCourseIds.add(course.id));
                      } else {
                        setState(() => _completedLessonIds.add(lesson.id));
                      }
                      Navigator.of(sheetContext).pop();
                    },
                    icon: Icon(
                      !enrolled
                          ? Icons.add_rounded
                          : completed
                          ? Icons.check_rounded
                          : Icons.done_rounded,
                    ),
                    label: Text(
                      !enrolled
                          ? 'Bepul kursga qo‘shilish'
                          : completed
                          ? 'Dars bajarilgan'
                          : 'Darsni tugatdim',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _lessonInfoCard(String title, String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: IlmColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        Text(text, style: const TextStyle(height: 1.45, fontSize: 13)),
      ],
    ),
  );

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
