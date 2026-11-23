enum TestDifficulty { easy, medium, hard }

extension TestDifficultyLabel on TestDifficulty {
  String get label => switch (this) {
    TestDifficulty.easy => 'Oson',
    TestDifficulty.medium => 'O‘rtacha',
    TestDifficulty.hard => 'Qiyin',
  };
}

class TestQuestion {
  const TestQuestion({
    required this.id,
    required this.subject,
    required this.topic,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.fact,
  });

  final String id;
  final String subject;
  final String topic;
  final TestDifficulty difficulty;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String fact;
}
