import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/app_tabs.dart';
import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/data/uzbmb_news.dart';
import 'package:ilm_fan/features/courses/courses_screen.dart';
import 'package:ilm_fan/features/news/news_screen.dart';
import 'package:ilm_fan/features/profile/profile_tab_screen.dart';
import 'package:ilm_fan/features/preparation/preparation_home_screen.dart';
import 'package:ilm_fan/features/reels/reels_feed_screen.dart';
import 'package:ilm_fan/features/shell/shell_tab_page.dart';
import 'package:ilm_fan/features/student/school_tasks_screen.dart';
import 'package:ilm_fan/features/teacher_materials/teacher_lessons_screen.dart';
import 'package:ilm_fan/features/teacher_materials/teacher_reports_screen.dart';
import 'package:ilm_fan/features/teacher_materials/teacher_tests_screen.dart';
import 'package:ilm_fan/features/teacher_materials/textbook_marketplace_screen.dart';
import 'package:ilm_fan/features/tests/test_section_screen.dart';
import 'package:ilm_fan/models/teacher_textbook.dart';
import 'package:ilm_fan/models/textbook_comment.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.profile,
    this.onLogout,
    this.newsRepository,
  });

  final UserProfile profile;
  final VoidCallback? onLogout;
  final NewsRepository? newsRepository;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  var _index = 0;
  late List<TeacherTextbook> _teacherTextbooks;
  late List<TextbookComment> _comments;

  @override
  void initState() {
    super.initState();
    final subjectTitle =
        tayyorlovFanById(widget.profile.subjectFanId)?.title ?? 'Umumiy fan';
    _teacherTextbooks = buildSampleTextbooks(subjectTitle);
    _comments = buildSampleTextbookComments();
  }

  void _addComment(TextbookComment comment) {
    setState(() => _comments = [comment, ..._comments]);
  }

  void _replyComment(String commentId, String reply) {
    setState(() {
      _comments = [
        for (final c in _comments)
          if (c.id == commentId) c.copyWith(teacherReply: reply) else c,
      ];
    });
  }

  List<AppTab> get _tabs => tabsForRole(widget.profile.role);

  void _openTab(String id) {
    final targetIndex = _tabs.indexWhere((tab) => tab.id == id);
    if (targetIndex >= 0) setState(() => _index = targetIndex);
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.role != widget.profile.role) {
      _index = 0;
    }
    if (_index >= _tabs.length) {
      _index = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;

    return Scaffold(
      backgroundColor: IlmColors.paper,
      body: IndexedStack(
        index: _index,
        children: [
          for (final tab in tabs)
            switch (tab.id) {
              'tayyorlovlar' => PreparationHomeScreen(
                profile: widget.profile,
                onOpenTests: () => _openTab('tests'),
                onOpenCourses: _openCourses,
              ),
              'news' => NewsScreen(
                profile: widget.profile,
                repository: widget.newsRepository,
              ),
              'create_lessons' => TeacherLessonsScreen(
                profile: widget.profile,
                textbooks: _teacherTextbooks,
                onTextbooksChanged: (next) =>
                    setState(() => _teacherTextbooks = next),
                comments: _comments,
                onAddComment: _addComment,
              ),
              'create_tests' => TeacherTestsScreen(
                profile: widget.profile,
                teacherTextbooks: _teacherTextbooks,
              ),
              'reports' => TeacherReportsScreen(
                profile: widget.profile,
                comments: _comments,
                onReplyComment: _replyComment,
              ),
              'textbooks' || 'school_textbooks' => TextbookMarketplaceScreen(
                profile: widget.profile,
                canPublish: false,
              ),
              'school_tasks' => SchoolTasksScreen(profile: widget.profile),
              'courses' => CoursesScreen(profile: widget.profile),
              'reels' => const ReelsFeedScreen(),
              'tests' => TestSectionScreen(profile: widget.profile),
              'profile' => ProfileTabScreen(
                profile: widget.profile,
                onLogout: widget.onLogout,
                onOpenPreparation:
                    widget.profile.role == RoleId.teacherMaterials
                    ? _openPreparation
                    : null,
                onOpenMarketplace:
                    widget.profile.role == RoleId.teacherMaterials ||
                        widget.profile.role == RoleId.student
                    ? _openMarketplace
                    : null,
                onOpenNews: widget.profile.role == RoleId.universityStudent
                    ? _openNewsPage
                    : null,
              ),
              _ => ShellTabPage(tab: tab, profile: widget.profile),
            },
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: Colors.white,
        indicatorColor: IlmColors.accent.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.icon, color: IlmColors.accent),
              label: tab.label,
            ),
        ],
      ),
    );
  }

  void _openCourses() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: IlmColors.paper,
          body: CoursesScreen(profile: widget.profile),
        ),
      ),
    );
  }

  void _openPreparation() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (routeContext) => Scaffold(
          backgroundColor: IlmColors.paper,
          body: PreparationHomeScreen(
            profile: widget.profile,
            onOpenTests: () => _openTestsPage(routeContext),
            onOpenCourses: _openCourses,
          ),
        ),
      ),
    );
  }

  void _openTestsPage(BuildContext routeContext) {
    Navigator.of(routeContext).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: IlmColors.paper,
          body: TestSectionScreen(profile: widget.profile),
        ),
      ),
    );
  }

  void _openMarketplace() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TextbookMarketplaceScreen(
          profile: widget.profile,
          canPublish: widget.profile.role == RoleId.teacherMaterials,
          teacherTextbooks: _teacherTextbooks,
        ),
      ),
    );
  }

  void _openNewsPage() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: IlmColors.paper,
          body: NewsScreen(
            profile: widget.profile,
            repository: widget.newsRepository,
          ),
        ),
      ),
    );
  }
}
