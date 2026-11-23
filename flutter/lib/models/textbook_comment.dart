class TextbookComment {
  const TextbookComment({
    required this.id,
    required this.studentName,
    required this.topicTitle,
    required this.text,
    required this.createdAtLabel,
    this.teacherReply,
  });

  final String id;
  final String studentName;
  final String topicTitle;
  final String text;
  final String createdAtLabel;
  final String? teacherReply;

  bool get isAnswered => teacherReply != null && teacherReply!.trim().isNotEmpty;

  TextbookComment copyWith({String? teacherReply}) {
    return TextbookComment(
      id: id,
      studentName: studentName,
      topicTitle: topicTitle,
      text: text,
      createdAtLabel: createdAtLabel,
      teacherReply: teacherReply ?? this.teacherReply,
    );
  }
}

List<TextbookComment> buildSampleTextbookComments() {
  return const [
    TextbookComment(
      id: 'cmt-1',
      studentName: 'Azizbek Karimov',
      topicTitle: '1-mavzu. Asosiy qoidalar va formulalar',
      text: 'Ustoz, Viyet teoremasida manfiy ishora nega o‘zgaradi?',
      createdAtLabel: '10 daqiqa oldin',
    ),
    TextbookComment(
      id: 'cmt-2',
      studentName: 'Madina Sobirova',
      topicTitle: '2-mavzu. Amaliy mashqlar va grafiklar',
      text: '3-masaladagi grafikni qanday chizish kerak?',
      createdAtLabel: '1 soat oldin',
      teacherReply: 'Avval nol nuqtalarini topib, keyin parabola uchini belgilang.',
    ),
  ];
}
