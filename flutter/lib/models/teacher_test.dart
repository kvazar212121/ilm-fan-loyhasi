import 'package:material_ui/material_ui.dart';

enum TeacherQuestionType {
  multipleChoice,
  openAnswer,
  matching,
}

extension TeacherQuestionTypeMeta on TeacherQuestionType {
  String get label => switch (this) {
    TeacherQuestionType.multipleChoice => 'A / B / C / D',
    TeacherQuestionType.openAnswer => 'Ochiq javob',
    TeacherQuestionType.matching => 'Moslashtirish',
  };

  IconData get icon => switch (this) {
    TeacherQuestionType.multipleChoice => Icons.radio_button_checked,
    TeacherQuestionType.openAnswer => Icons.short_text_rounded,
    TeacherQuestionType.matching => Icons.compare_arrows_rounded,
  };
}

class TeacherQuestion {
  const TeacherQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    this.options = const [],
    this.solutionText = '',
    this.solutionHasVoice = false,
    this.imageName,
  });

  final String id;
  final TeacherQuestionType type;
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String solutionText;
  final bool solutionHasVoice;
  final String? imageName;
}

class TeacherTestItem {
  const TeacherTestItem({
    required this.id,
    required this.title,
    required this.attemptsCount,
    required this.isActive,
    required this.questions,
    this.timeLimitMinutes = 20,
    this.liveRoomCode = 'LIVE-739',
  });

  final String id;
  final String title;
  final int attemptsCount;
  final bool isActive;
  final List<TeacherQuestion> questions;
  final int timeLimitMinutes;
  final String liveRoomCode;

  TeacherTestItem copyWith({
    String? title,
    int? attemptsCount,
    bool? isActive,
    List<TeacherQuestion>? questions,
    int? timeLimitMinutes,
    String? liveRoomCode,
  }) {
    return TeacherTestItem(
      id: id,
      title: title ?? this.title,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      isActive: isActive ?? this.isActive,
      questions: questions ?? this.questions,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      liveRoomCode: liveRoomCode ?? this.liveRoomCode,
    );
  }
}

List<TeacherTestItem> buildSampleTeacherTests(String subjectTitle) {
  return [
    TeacherTestItem(
      id: 'test-1',
      title: '$subjectTitle — 1-chorak nazorat testi',
      attemptsCount: 34,
      isActive: true,
      timeLimitMinutes: 25,
      liveRoomCode: 'LIVE-739',
      questions: const [
        TeacherQuestion(
          id: 'q-1',
          type: TeacherQuestionType.multipleChoice,
          prompt: 'x² − 5x + 6 = 0 tenglamaning ildizlari yig‘indisini toping.',
          options: ['3', '5', '6', '-5'],
          correctAnswer: '5',
          solutionText: 'Viyet teoremasiga ko‘ra x₁ + x₂ = −(−5) = 5.',
          solutionHasVoice: true,
        ),
        TeacherQuestion(
          id: 'q-2',
          type: TeacherQuestionType.openAnswer,
          prompt: 'Uchburchakning asosi 12 sm, balandligi 5 sm. Yuzini yozing.',
          correctAnswer: '30',
          solutionText: 'S = (12 × 5) / 2 = 30 sm².',
          imageName: 'uchburchak_chizma.png',
        ),
        TeacherQuestion(
          id: 'q-3',
          type: TeacherQuestionType.matching,
          prompt: 'Formulalarni nomlari bilan moslashtiring.',
          options: ['a² − b² → (a−b)(a+b)', '(a+b)² → a²+2ab+b²'],
          correctAnswer: '1-A, 2-B',
          solutionText: 'Qisqa ko‘paytirish formulalaridan foydalaniladi.',
        ),
      ],
    ),
    TeacherTestItem(
      id: 'test-2',
      title: '$subjectTitle — mavzu bo‘yicha tezkor test',
      attemptsCount: 18,
      isActive: true,
      timeLimitMinutes: 10,
      liveRoomCode: 'LIVE-214',
      questions: const [
        TeacherQuestion(
          id: 'q-4',
          type: TeacherQuestionType.multipleChoice,
          prompt: '25% ning kasr ko‘rinishi qaysi?',
          options: ['1/2', '1/4', '1/5', '2/5'],
          correctAnswer: '1/4',
          solutionText: '25 / 100 = 1/4.',
        ),
      ],
    ),
  ];
}
