import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/demo_test_questions.dart';
import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/models/test_question.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

enum _TestMode { practice, contest, ranking }

enum _TestPage { home, quiz, result, mistakes }

class TestSectionScreen extends StatefulWidget {
  const TestSectionScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<TestSectionScreen> createState() => _TestSectionScreenState();
}

class _TestSectionScreenState extends State<TestSectionScreen> {
  _TestMode _mode = _TestMode.practice;
  _TestPage _page = _TestPage.home;
  String _subject = 'Matematika';
  String _topic = 'Barcha mavzular';
  TestDifficulty? _difficulty;
  int _questionCount = 3;
  String _rankPeriod = 'Haftalik';
  String _rankSubject = 'Matematika';

  final List<TestQuestion> _mistakes = [];
  List<TestQuestion> _activeQuestions = [];
  int _questionIndex = 0;
  int? _selectedIndex;
  bool _timed = false;
  bool _reviewingMistakes = false;
  int _secondsLeft = 10;
  int _sessionCorrect = 0;
  int _sessionPoints = 0;
  int _elapsedSeconds = 0;
  int _ratingPoints = 0;
  int _personalBest = 0;
  int? _lastPercent;
  DateTime? _startedAt;
  Timer? _questionTimer;

  static const _difficulties = [
    (label: 'Barchasi', value: null),
    (label: 'Oson', value: TestDifficulty.easy),
    (label: 'O‘rtacha', value: TestDifficulty.medium),
    (label: 'Qiyin', value: TestDifficulty.hard),
  ];
  static const _demoRivals = ['Malika', 'Sardor', 'Jasur'];

  String? get _profileSubject =>
      tayyorlovFanById(widget.profile.subjectFanId)?.title;

  List<String> get _subjects =>
      demoTestQuestions.map((question) => question.subject).toSet().toList();

  List<TestQuestion> get _subjectQuestions => demoTestQuestions
      .where((question) => question.subject == _subject)
      .toList();

  List<TestQuestion> get _visibleMistakes =>
      _mistakes.where((question) => question.subject == _subject).toList();

  @override
  void initState() {
    super.initState();
    final profileSubject = _profileSubject;
    if (profileSubject != null) {
      _subject = profileSubject;
      _rankSubject = profileSubject;
    }
  }

  List<String> get _topics {
    final topics = _subjectQuestions
        .map((question) => question.topic)
        .toSet()
        .toList();
    return ['Barcha mavzular', ...topics];
  }

  List<TestQuestion> get _filteredQuestions => _subjectQuestions
      .where(
        (question) => _topic == 'Barcha mavzular' || question.topic == _topic,
      )
      .where(
        (question) => _difficulty == null || question.difficulty == _difficulty,
      )
      .toList();

  int get _availableQuestionCount => _filteredQuestions.length < _questionCount
      ? _filteredQuestions.length
      : _questionCount;

  @override
  void dispose() {
    _questionTimer?.cancel();
    super.dispose();
  }

  void _selectMode(_TestMode mode) {
    _questionTimer?.cancel();
    setState(() {
      _mode = mode;
      _page = _TestPage.home;
    });
  }

  void _startPractice() {
    final questions = _filteredQuestions.take(_availableQuestionCount).toList();
    _startQuiz(questions, timed: false);
  }

  void _startContest() {
    _startQuiz(_subjectQuestions.take(5).toList(), timed: true);
  }

  void _startMistakeReview() {
    _startQuiz(_visibleMistakes, timed: false, reviewingMistakes: true);
  }

  void _startQuiz(
    List<TestQuestion> questions, {
    required bool timed,
    bool reviewingMistakes = false,
  }) {
    if (questions.isEmpty) return;
    _questionTimer?.cancel();
    setState(() {
      _activeQuestions = questions;
      _questionIndex = 0;
      _selectedIndex = null;
      _timed = timed;
      _reviewingMistakes = reviewingMistakes;
      _secondsLeft = 10;
      _sessionCorrect = 0;
      _sessionPoints = 0;
      _elapsedSeconds = 0;
      _startedAt = DateTime.now();
      _page = _TestPage.quiz;
    });
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    if (!_timed) return;
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        _submitAnswer(-1);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _submitAnswer(int index) {
    if (_selectedIndex != null) return;
    _questionTimer?.cancel();
    final question = _activeQuestions[_questionIndex];
    final correct = index == question.correctIndex;
    setState(() {
      _selectedIndex = index;
      if (correct) {
        _sessionCorrect++;
        _sessionPoints += 10 + (_timed ? _secondsLeft : 0);
        if (_reviewingMistakes) {
          _mistakes.removeWhere((mistake) => mistake.id == question.id);
        }
      } else if (!_mistakes.any((mistake) => mistake.id == question.id)) {
        _mistakes.add(question);
      }
    });
  }

  void _nextQuestion() {
    if (_questionIndex == _activeQuestions.length - 1) {
      _finishQuiz();
      return;
    }
    setState(() {
      _questionIndex++;
      _selectedIndex = null;
      _secondsLeft = 10;
    });
    _startQuestionTimer();
  }

  void _finishQuiz() {
    _questionTimer?.cancel();
    final startedAt = _startedAt;
    final elapsed = startedAt == null
        ? 0
        : DateTime.now().difference(startedAt).inSeconds;
    final percent = (_sessionCorrect * 100 / _activeQuestions.length).round();
    setState(() {
      _elapsedSeconds = elapsed;
      _lastPercent = percent;
      if (percent > _personalBest) _personalBest = percent;
      _ratingPoints += _sessionPoints;
      _page = _TestPage.result;
    });
  }

  void _returnHome() {
    _questionTimer?.cancel();
    setState(() => _page = _TestPage.home);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: IlmColors.paper,
          surfaceTintColor: Colors.transparent,
          title: Text('Test'),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildModeSelector(),
              const SizedBox(height: 18),
              if (_page == _TestPage.quiz) _buildQuizPage(),
              if (_page == _TestPage.result) _buildResultPage(),
              if (_page == _TestPage.mistakes) _buildMistakesPage(),
              if (_page == _TestPage.home) _buildModeHome(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    const modes = [
      (mode: _TestMode.practice, label: 'Mashq', icon: Icons.edit_note_rounded),
      (mode: _TestMode.contest, label: 'Bellashuv', icon: Icons.bolt_rounded),
      (
        mode: _TestMode.ranking,
        label: 'Reyting',
        icon: Icons.leaderboard_outlined,
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: modes.map((item) {
        final selected = _mode == item.mode;
        return ChoiceChip(
          avatar: Icon(
            item.icon,
            size: 18,
            color: selected ? IlmColors.accent : IlmColors.inkMuted,
          ),
          label: Text(item.label),
          selected: selected,
          onSelected: (_) => _selectMode(item.mode),
          showCheckmark: false,
          backgroundColor: Colors.white,
          selectedColor: IlmColors.accent.withValues(alpha: 0.14),
          side: BorderSide(
            color: selected
                ? IlmColors.accent.withValues(alpha: 0.35)
                : IlmColors.line,
          ),
          labelStyle: TextStyle(
            color: selected ? IlmColors.accent : IlmColors.ink,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModeHome() {
    return switch (_mode) {
      _TestMode.practice => _buildPracticeHome(),
      _TestMode.contest => _buildContestHome(),
      _TestMode.ranking => _buildRankingHome(),
    };
  }

  Widget _buildPracticeHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Mashq testi'),
        const SizedBox(height: 6),
        const Text(
          'Mavzuni tanlang va bilimni mustahkamlang.',
          style: TextStyle(fontSize: 15, color: IlmColors.inkMuted),
        ),
        const SizedBox(height: 20),
        _buildSubjectFilter(),
        const SizedBox(height: 14),
        _filterLabel('Mavzu'),
        _choiceRow<String>(
          options: _topics,
          selected: _topic,
          label: (value) => value,
          onSelected: (value) => setState(() => _topic = value),
        ),
        const SizedBox(height: 14),
        _filterLabel('Qiyinlik'),
        _choiceRow<TestDifficulty?>(
          options: _difficulties.map((item) => item.value).toList(),
          selected: _difficulty,
          label: (value) => value?.label ?? 'Barchasi',
          onSelected: (value) => setState(() => _difficulty = value),
        ),
        const SizedBox(height: 14),
        _filterLabel('Savollar soni'),
        _choiceRow<int>(
          options: const [1, 3, 6],
          selected: _questionCount,
          label: (value) => '$value ta',
          onSelected: (value) => setState(() => _questionCount = value),
        ),
        const SizedBox(height: 18),
        _infoCard(
          icon: Icons.lightbulb_outline_rounded,
          title: 'Javobdan keyin tushuntirish',
          text: 'Har savolda yechim va eslab qolishga yordam beradigan fakt chiqadi.',
        ),
        if (_filteredQuestions.isEmpty) ...[
          const SizedBox(height: 12),
          _noQuestionsCard(),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const ValueKey('startPractice'),
          onPressed: _availableQuestionCount == 0 ? null : _startPractice,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text('Mashqni boshlash · $_availableQuestionCount savol'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('openMistakes'),
          onPressed: _visibleMistakes.isEmpty
              ? null
              : () => setState(() => _page = _TestPage.mistakes),
          icon: const Icon(Icons.replay_rounded),
          label: Text('Xatolarim · ${_visibleMistakes.length}'),
        ),
        if (_lastPercent != null) ...[
          const SizedBox(height: 16),
          _infoCard(
            icon: Icons.trending_up_rounded,
            title: 'Oxirgi natija · $_lastPercent%',
            text: 'Eng yaxshi natijangiz · $_personalBest%',
          ),
        ],
      ],
    );
  }

  Widget _buildContestHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Tezkor bellashuv'),
        const SizedBox(height: 6),
        const Text(
          'Har savolga 10 soniya. To‘g‘ri javobga asosiy ball, tezlikka qo‘shimcha ball.',
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: IlmColors.inkMuted,
          ),
        ),
        const SizedBox(height: 20),
        _buildSubjectFilter(),
        const SizedBox(height: 16),
        if (_subjectQuestions.isEmpty)
          _noQuestionsCard()
        else ...[
          _infoCard(
            icon: Icons.groups_rounded,
            title: 'Sinov xonasi',
            text:
                '${_demoRivals.length} ta namuna raqib bilan bellashuv jarayonini sinab ko‘ring.',
          ),
          const SizedBox(height: 10),
          _demoRivalRow(),
          const SizedBox(height: 14),
          const Text(
            'Jonli qatnashchilar va umumiy xona uchun server ulanishi kerak. Hozir bu demo bellashuv.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: IlmColors.inkMuted,
            ),
          ),
        ],
        const SizedBox(height: 18),
        FilledButton.icon(
          key: const ValueKey('startContest'),
          onPressed: _subjectQuestions.isEmpty ? null : _startContest,
          icon: const Icon(Icons.bolt_rounded),
          label: const Text('10 soniyalik demo bellashuv'),
        ),
      ],
    );
  }

  Widget _buildSubjectFilter({bool ranking = false}) {
    final profileSubject = _profileSubject;
    if (profileSubject != null) {
      return _infoCard(
        icon: Icons.school_outlined,
        title: widget.profile.role == RoleId.teacher
            ? 'Sertifikat fani'
            : 'Tanlangan fan',
        text: profileSubject,
      );
    }

    final selected = ranking ? _rankSubject : _subject;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _filterLabel('Fan'),
        _choiceRow<String>(
          options: _subjects,
          selected: selected,
          label: (value) => value,
          onSelected: (value) => setState(() {
            if (ranking) {
              _rankSubject = value;
            } else {
              _subject = value;
              _topic = 'Barcha mavzular';
            }
          }),
        ),
      ],
    );
  }

  Widget _noQuestionsCard() {
    return _infoCard(
      icon: Icons.library_books_outlined,
      title: '$_subject testlari hali qo‘shilmagan',
      text: 'Bu fan bo‘yicha savollar tayyorlanmoqda. Boshqa fan testlari ko‘rsatilmaydi.',
    );
  }

  Widget _demoRivalRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final name in _demoRivals)
          Chip(
            avatar: CircleAvatar(
              backgroundColor: IlmColors.accent.withValues(alpha: 0.14),
              child: Text(
                name[0],
                style: const TextStyle(color: IlmColors.accent, fontSize: 12),
              ),
            ),
            label: Text(name),
            backgroundColor: Colors.white,
            side: const BorderSide(color: IlmColors.line),
          ),
      ],
    );
  }

  Widget _buildRankingHome() {
    final entries = <_RankingEntry>[
      const _RankingEntry(name: 'Madina', points: 940),
      const _RankingEntry(name: 'Aziz', points: 815),
      const _RankingEntry(name: 'Sardor', points: 720),
      _RankingEntry(
        name: '${widget.profile.firstName} · Siz',
        points: _ratingPoints,
        isCurrentUser: true,
      ),
      const _RankingEntry(name: 'Malika', points: 490),
    ]..sort((a, b) => b.points.compareTo(a.points));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Reyting'),
        const SizedBox(height: 6),
        const Text(
          'Natijangizni fan va vaqt bo‘yicha kuzating.',
          style: TextStyle(fontSize: 15, color: IlmColors.inkMuted),
        ),
        const SizedBox(height: 18),
        _choiceRow<String>(
          options: const ['Haftalik', 'Umumiy'],
          selected: _rankPeriod,
          label: (value) => value,
          onSelected: (value) => setState(() => _rankPeriod = value),
        ),
        const SizedBox(height: 12),
        _buildSubjectFilter(ranking: true),
        const SizedBox(height: 18),
        _infoCard(
          icon: Icons.stars_rounded,
          title: 'Shaxsiy ko‘rsatkich',
          text: '$_ratingPoints ball · eng yaxshi natija $_personalBest%',
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _sectionTitle('$_rankPeriod reytingi')),
            const Text(
              'DEMO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: IlmColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < entries.length; index++)
          _rankingTile(index + 1, entries[index]),
      ],
    );
  }

  Widget _rankingTile(int rank, _RankingEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? IlmColors.accent.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isCurrentUser
              ? IlmColors.accent.withValues(alpha: 0.35)
              : IlmColors.line,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$rank',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          CircleAvatar(
            radius: 17,
            backgroundColor: IlmColors.paper,
            foregroundColor: IlmColors.accent,
            child: Text(entry.name[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text('${entry.points} ball'),
        ],
      ),
    );
  }

  Widget _buildQuizPage() {
    final question = _activeQuestions[_questionIndex];
    final answered = _selectedIndex != null;
    final isCorrect = _selectedIndex == question.correctIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _timed
                    ? 'Bellashuv · ${_questionIndex + 1}/${_activeQuestions.length}'
                    : 'Savol ${_questionIndex + 1}/${_activeQuestions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: IlmColors.inkMuted,
                ),
              ),
            ),
            if (_timed) _timerBadge(),
            TextButton(onPressed: _finishQuiz, child: const Text('Tugatish')),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value:
              (_questionIndex + (answered ? 1 : 0)) / _activeQuestions.length,
          minHeight: 6,
          borderRadius: BorderRadius.circular(99),
          backgroundColor: IlmColors.line,
          color: IlmColors.accent,
        ),
        const SizedBox(height: 18),
        _infoCard(
          icon: Icons.category_outlined,
          title: '${question.subject} · ${question.topic}',
          text: question.difficulty.label,
        ),
        const SizedBox(height: 18),
        Text(
          question.prompt,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: IlmColors.ink,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        for (var index = 0; index < question.options.length; index++)
          _answerOption(question, index),
        if (answered) ...[
          const SizedBox(height: 12),
          _answerFeedback(question, isCorrect),
          const SizedBox(height: 14),
          FilledButton(
            key: const ValueKey('nextQuestion'),
            onPressed: _nextQuestion,
            child: Text(
              _questionIndex == _activeQuestions.length - 1
                  ? 'Natijani ko‘rish'
                  : 'Keyingi savol',
            ),
          ),
        ],
      ],
    );
  }

  Widget _timerBadge() {
    final urgent = _secondsLeft <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: urgent
            ? const Color(0xFFFFE7E4)
            : IlmColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '00:${_secondsLeft.toString().padLeft(2, '0')}',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: urgent ? const Color(0xFFB42318) : IlmColors.accent,
        ),
      ),
    );
  }

  Widget _answerOption(TestQuestion question, int index) {
    final answered = _selectedIndex != null;
    final isCorrectAnswer = index == question.correctIndex;
    final isSelectedWrong = index == _selectedIndex && !isCorrectAnswer;
    final background = !answered
        ? Colors.white
        : isCorrectAnswer
        ? const Color(0xFFE5F5EC)
        : isSelectedWrong
        ? const Color(0xFFFFEAE7)
        : Colors.white;
    final border = !answered
        ? IlmColors.line
        : isCorrectAnswer
        ? IlmColors.accent
        : isSelectedWrong
        ? const Color(0xFFB42318)
        : IlmColors.line;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: answered ? null : () => _submitAnswer(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: IlmColors.paper,
                child: Text(
                  String.fromCharCode(65 + index),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: IlmColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(question.options[index])),
              if (answered && isCorrectAnswer)
                const Icon(Icons.check_circle_rounded, color: IlmColors.accent),
              if (answered && isSelectedWrong)
                const Icon(Icons.cancel_rounded, color: Color(0xFFB42318)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _answerFeedback(TestQuestion question, bool isCorrect) {
    final timedOut = _selectedIndex == -1;
    final title = timedOut
        ? 'Vaqt tugadi'
        : isCorrect
        ? 'To‘g‘ri javob!'
        : 'Bu safar adashdingiz';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect
              ? IlmColors.accent.withValues(alpha: 0.35)
              : IlmColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isCorrect ? IlmColors.accent : const Color(0xFFB42318),
            ),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Text('To‘g‘ri javob: ${question.options[question.correctIndex]}'),
          ],
          const SizedBox(height: 12),
          const Text('Yechimi', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(question.explanation, style: const TextStyle(height: 1.45)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: IlmColors.accent,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(question.fact, style: const TextStyle(height: 1.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultPage() {
    final total = _activeQuestions.length;
    final percent = total == 0 ? 0 : (_sessionCorrect * 100 / total).round();
    final contest = _mode == _TestMode.contest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(contest ? 'Bellashuv yakuni' : 'Test natijasi'),
        const SizedBox(height: 16),
        _infoCard(
          icon: percent >= 70
              ? Icons.emoji_events_outlined
              : Icons.insights_rounded,
          title: '$_sessionCorrect / $total to‘g‘ri · $percent%',
          text: '$_sessionPoints ball · $_elapsedSeconds soniya',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _statTile('Xatolar', '${total - _sessionCorrect}')),
            const SizedBox(width: 10),
            Expanded(child: _statTile('Reyting balli', '$_ratingPoints')),
          ],
        ),
        if (contest) ...[
          const SizedBox(height: 18),
          _infoCard(
            icon: Icons.groups_outlined,
            title: 'Demo bellashuv',
            text: 'Jonli qatnashchilar reytingi server ulanganda ko‘rinadi.',
          ),
        ],
        if (_visibleMistakes.isNotEmpty) ...[
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => setState(() => _page = _TestPage.mistakes),
            icon: const Icon(Icons.replay_rounded),
            label: Text('Xatolarimni ko‘rish · ${_visibleMistakes.length}'),
          ),
        ],
        const SizedBox(height: 10),
        FilledButton(
          key: const ValueKey('returnToTests'),
          onPressed: _returnHome,
          child: const Text('Testlarga qaytish'),
        ),
      ],
    );
  }

  Widget _buildMistakesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Mashqqa qaytish',
              onPressed: _returnHome,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: _sectionTitle('Xatolarim · ${_visibleMistakes.length}'),
            ),
          ],
        ),
        if (_visibleMistakes.isEmpty)
          _infoCard(
            icon: Icons.check_circle_outline_rounded,
            title: 'Hozircha xato yo‘q',
            text: 'Mashq testida adashgan savollaringiz shu yerda saqlanadi.',
          )
        else ...[
          for (final question in _visibleMistakes) _mistakeTile(question),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const ValueKey('reviewMistakes'),
            onPressed: _startMistakeReview,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Xatolarni qayta ishlash'),
          ),
        ],
      ],
    );
  }

  Widget _mistakeTile(TestQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IlmColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.prompt,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Javob: ${question.options[question.correctIndex]}',
            style: const TextStyle(
              color: IlmColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            question.explanation,
            style: const TextStyle(color: IlmColors.inkMuted),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IlmColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: IlmColors.inkMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: IlmColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: IlmColors.paper,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: IlmColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: IlmColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: Theme.of(context).textTheme.titleLarge
        ?.copyWith(color: IlmColors.ink, fontWeight: FontWeight.w700),
  );

  Widget _filterLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget _choiceRow<T>({
    required List<T> options,
    required T selected,
    required String Function(T value) label,
    required ValueChanged<T> onSelected,
  }) {
    return Wrap(
      spacing: 7,
      runSpacing: 4,
      children: options.map((option) {
        final isSelected = option == selected;
        return ChoiceChip(
          label: Text(label(option)),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          showCheckmark: false,
          backgroundColor: Colors.white,
          selectedColor: IlmColors.accent.withValues(alpha: 0.14),
          side: BorderSide(
            color: isSelected
                ? IlmColors.accent.withValues(alpha: 0.4)
                : IlmColors.line,
          ),
          labelStyle: TextStyle(
            fontSize: 13,
            color: isSelected ? IlmColors.accent : IlmColors.ink,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }
}

class _RankingEntry {
  const _RankingEntry({
    required this.name,
    required this.points,
    this.isCurrentUser = false,
  });

  final String name;
  final int points;
  final bool isCurrentUser;
}
