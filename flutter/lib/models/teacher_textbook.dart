import 'package:material_ui/material_ui.dart';

enum LessonMaterialType {
  text,
  pdf,
  video,
  audio,
  image,
  homework,
  test,
}

extension LessonMaterialTypeMeta on LessonMaterialType {
  String get label => switch (this) {
    LessonMaterialType.text => 'Matn',
    LessonMaterialType.pdf => 'PDF',
    LessonMaterialType.video => 'Video darslik',
    LessonMaterialType.audio => 'Ovozli tushuntirish',
    LessonMaterialType.image => 'Rasm',
    LessonMaterialType.homework => 'Uy vazifasi',
    LessonMaterialType.test => 'Oraliq test',
  };

  IconData get icon => switch (this) {
    LessonMaterialType.text => Icons.article_outlined,
    LessonMaterialType.pdf => Icons.picture_as_pdf_outlined,
    LessonMaterialType.video => Icons.play_circle_outline,
    LessonMaterialType.audio => Icons.mic_none_rounded,
    LessonMaterialType.image => Icons.image_outlined,
    LessonMaterialType.homework => Icons.assignment_outlined,
    LessonMaterialType.test => Icons.quiz_outlined,
  };

  String get placeholderHint => switch (this) {
    LessonMaterialType.text => 'Mavzu matni yoki qoidalarini yozing...',
    LessonMaterialType.pdf => 'Masalan: 1-bob_qollanma.pdf',
    LessonMaterialType.video => 'Masalan: Kvadrat_tenglamalar_12min.mp4',
    LessonMaterialType.audio => 'Masalan: Ustoz_tushuntirishi_4min.m4a',
    LessonMaterialType.image => 'Masalan: Formula_sxemasi.png',
    LessonMaterialType.homework =>
      'O‘quvchi daftaridagi yechimni rasmga olib yuboradi',
    LessonMaterialType.test => 'Masalan: 10 ta savol · mavzuni mustahkamlash',
  };
}

enum AudioVisualKind {
  image,
  gif,
}

extension AudioVisualKindMeta on AudioVisualKind {
  String get label => switch (this) {
    AudioVisualKind.image => 'Rasm',
    AudioVisualKind.gif => 'GIF',
  };

  IconData get icon => switch (this) {
    AudioVisualKind.image => Icons.image_outlined,
    AudioVisualKind.gif => Icons.gif_box_outlined,
  };
}

class LessonMaterialBlock {
  const LessonMaterialBlock({
    required this.id,
    required this.type,
    required this.title,
    this.content = '',
    this.questionsCount,
    this.visualKind,
    this.visualFileName,
    this.visualLocalPath,
  });

  final String id;
  final LessonMaterialType type;
  final String title;
  final String content;
  final int? questionsCount;
  /// Ovozli tushuntirish bilan birga ko‘rsatiladigan rasm yoki GIF turi.
  final AudioVisualKind? visualKind;
  final String? visualFileName;
  final String? visualLocalPath;
}

class TextbookTopic {
  const TextbookTopic({
    required this.id,
    required this.title,
    required this.blocks,
    this.requireTestPassToUnlockNext = false,
    this.passingScorePercent = 70,
    this.maxAttempts = 3,
    this.timeLimitMinutes = 15,
  });

  final String id;
  final String title;
  final List<LessonMaterialBlock> blocks;
  final bool requireTestPassToUnlockNext;
  final int passingScorePercent;
  /// 0 = cheksiz urinish.
  final int maxAttempts;
  /// 0 = vaqt cheklovisiz.
  final int timeLimitMinutes;

  bool get hasTest =>
      blocks.any((block) => block.type == LessonMaterialType.test);

  TextbookTopic copyWith({
    String? title,
    List<LessonMaterialBlock>? blocks,
    bool? requireTestPassToUnlockNext,
    int? passingScorePercent,
    int? maxAttempts,
    int? timeLimitMinutes,
  }) {
    return TextbookTopic(
      id: id,
      title: title ?? this.title,
      blocks: blocks ?? this.blocks,
      requireTestPassToUnlockNext:
          requireTestPassToUnlockNext ?? this.requireTestPassToUnlockNext,
      passingScorePercent: passingScorePercent ?? this.passingScorePercent,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
    );
  }
}

class TextbookSection {
  const TextbookSection({
    required this.id,
    required this.title,
    required this.topics,
  });

  final String id;
  final String title;
  final List<TextbookTopic> topics;

  TextbookSection copyWith({
    String? title,
    List<TextbookTopic>? topics,
  }) {
    return TextbookSection(
      id: id,
      title: title ?? this.title,
      topics: topics ?? this.topics,
    );
  }
}

class TeacherTextbook {
  const TeacherTextbook({
    required this.id,
    required this.title,
    required this.grade,
    required this.published,
    required this.sections,
    this.sequentialLock = true,
    this.inviteCode = 'ILM-4821',
  });

  final String id;
  final String title;
  final String grade;
  final bool published;
  final List<TextbookSection> sections;
  final bool sequentialLock;
  final String inviteCode;

  int get totalTopics =>
      sections.fold<int>(0, (sum, section) => sum + section.topics.length);

  int get gatedTopicsCount => sections.fold<int>(
    0,
    (sum, section) =>
        sum +
        section.topics.where((t) => t.requireTestPassToUnlockNext).length,
  );

  TeacherTextbook copyWith({
    String? title,
    String? grade,
    bool? published,
    List<TextbookSection>? sections,
    bool? sequentialLock,
    String? inviteCode,
  }) {
    return TeacherTextbook(
      id: id,
      title: title ?? this.title,
      grade: grade ?? this.grade,
      published: published ?? this.published,
      sections: sections ?? this.sections,
      sequentialLock: sequentialLock ?? this.sequentialLock,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}

List<TeacherTextbook> buildSampleTextbooks(String subjectTitle) {
  return [
    TeacherTextbook(
      id: 'tb-1',
      title: '$subjectTitle: asosiy mavzular to‘plami',
      grade: '9–11-sinf',
      published: true,
      sequentialLock: true,
      sections: [
        TextbookSection(
          id: 'sec-1',
          title: '1-bo‘lim. Kirish va asosiy tushunchalar',
          topics: [
            const TextbookTopic(
              id: 'top-1',
              title: '1-mavzu. Asosiy qoidalar va formulalar',
              requireTestPassToUnlockNext: true,
              passingScorePercent: 70,
              blocks: [
                LessonMaterialBlock(
                  id: 'blk-1',
                  type: LessonMaterialType.text,
                  title: 'Nazariy konspekt',
                  content: 'Mavzuning asosiy ta’riflari va misollar.',
                ),
                LessonMaterialBlock(
                  id: 'blk-2',
                  type: LessonMaterialType.video,
                  title: 'Video tushuntirish (12 daqiqa)',
                  content: '1-mavzu_video.mp4',
                ),
                LessonMaterialBlock(
                  id: 'blk-3',
                  type: LessonMaterialType.audio,
                  title: 'Ustozning ovozli izohi',
                  content: 'qisqa_eslatma_3min.m4a',
                  visualKind: AudioVisualKind.image,
                  visualFileName: 'formula_chizmasi.png',
                ),
                LessonMaterialBlock(
                  id: 'blk-4',
                  type: LessonMaterialType.test,
                  title: 'Mavzu yakuniy testi',
                  content: 'Keyingi mavzuga o‘tish uchun majburiy sinov',
                  questionsCount: 10,
                ),
              ],
            ),
            const TextbookTopic(
              id: 'top-2',
              title: '2-mavzu. Amaliy mashqlar va grafiklar',
              requireTestPassToUnlockNext: false,
              blocks: [
                LessonMaterialBlock(
                  id: 'blk-5',
                  type: LessonMaterialType.pdf,
                  title: 'Mashqlar to‘plami (PDF)',
                  content: 'amaliy_mashqlar.pdf',
                ),
                LessonMaterialBlock(
                  id: 'blk-6',
                  type: LessonMaterialType.image,
                  title: 'Asosiy sxema va jadval',
                  content: 'sxema_01.png',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    TeacherTextbook(
      id: 'tb-2',
      title: '$subjectTitle: amaliy masalalar daftari',
      grade: 'Abituriyentlar',
      published: false,
      sequentialLock: false,
      sections: const [
        TextbookSection(
          id: 'sec-2',
          title: '1-bo‘lim. Tezkor yechish usullari',
          topics: [
            TextbookTopic(
              id: 'top-3',
              title: '1-mavzu. Murakkab misollar tahlili',
              blocks: [
                LessonMaterialBlock(
                  id: 'blk-7',
                  type: LessonMaterialType.text,
                  title: 'Bosqichma-bosqich yechim',
                  content: 'Namuna masalalar yechimi.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}
