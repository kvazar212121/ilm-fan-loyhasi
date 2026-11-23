import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/models/textbook_comment.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class TeacherReportsScreen extends StatelessWidget {
  const TeacherReportsScreen({
    super.key,
    required this.profile,
    this.comments = const [],
    this.onReplyComment,
  });

  final UserProfile profile;
  final List<TextbookComment> comments;
  final void Function(String commentId, String reply)? onReplyComment;

  static const _groupResults = [
    ('10-A guruh', 0.84, '24 o‘quvchi · 18 ta test'),
    ('11-B guruh', 0.72, '19 o‘quvchi · 14 ta test'),
    ('Abituriyent guruhi', 0.65, '31 o‘quvchi · 22 ta test'),
  ];

  static const _lockedStudents = [
    ('Azizbek Karimov', '1-mavzu testi · 50% (shart: 70%)'),
    ('Madina Sobirova', '1-mavzu testi · 60% (shart: 70%)'),
    ('Javohir Aliyev', '2-mavzu testi · urinishlar tugadi'),
  ];

  static const _hardTopics = [
    ('Kvadrat tenglamalar (Viyet)', 0.42),
    ('Foiz va nisbat masalalari', 0.35),
    ('Geometrik yuzalar', 0.28),
  ];

  static const _confusedSignals = [
    ('1-mavzu · Ustozning ovozli izohi (formula_chizmasi.png)', 7),
    ('2-mavzu · Mashqlar to‘plami (PDF)', 4),
  ];

  void _shareReport(BuildContext context, String subjectTitle) {
    final text =
        'Ilm Fan haftalik hisobot ($subjectTitle)\n'
        'O‘quvchilar: 74 · O‘rtacha ball: 76%\n'
        'Qulflanib qolgan o‘quvchilar: ${_lockedStudents.length} nafar\n'
        'Eng ko‘p tushunilmagan blok: ${_confusedSignals.first.$1} (${_confusedSignals.first.$2} nafar)';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hisobot Telegram / PDF ulashish uchun nusxalandi'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openReplySheet(
    BuildContext context,
    TextbookComment comment,
  ) async {
    final controller = TextEditingController(text: comment.teacherReply ?? '');
    final reply = await showModalBottomSheet<String>(
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
              Text(
                '${comment.studentName} savoliga javob',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: IlmColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                comment.text,
                style: const TextStyle(
                  fontSize: 13,
                  color: IlmColors.inkMuted,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('teacherReplyField'),
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Javobingiz',
                  hintText: 'Tushunarli qilib javob yozing...',
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                key: const ValueKey('sendTeacherReplyButton'),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  Navigator.of(sheetContext).pop(text);
                },
                child: const Text('Javobni yuborish'),
              ),
            ],
          ),
        );
      },
    );

    if (reply != null && context.mounted) {
      onReplyComment?.call(comment.id, reply);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${comment.studentName} ga javob yuborildi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectTitle =
        tayyorlovFanById(profile.subjectFanId)?.title ?? 'Umumiy fan';
    final effectiveComments =
        comments.isNotEmpty ? comments : buildSampleTextbookComments();
    final unansweredCount =
        effectiveComments.where((c) => !c.isAnswered).length;

    return ColoredBox(
      color: IlmColors.paper,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: IlmColors.paper,
            surfaceTintColor: Colors.transparent,
            title: const Text('Hisobotlar'),
            actions: [
              IconButton(
                key: const ValueKey('shareReportButton'),
                tooltip: 'Hisobotni ulashish',
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: () => _shareReport(context, subjectTitle),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  '$subjectTitle bo‘yicha o‘quvchilar faolligi va natijalari.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: IlmColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'O‘quvchilar',
                        value: '74',
                        icon: Icons.groups_outlined,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        label: 'O‘rtacha ball',
                        value: '76%',
                        icon: Icons.trending_up_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Yechilgan testlar',
                        value: '54',
                        icon: Icons.fact_check_outlined,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        label: 'Qulflanib qolgan',
                        value: '3',
                        icon: Icons.lock_outline_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ReportCard(
                  title: 'O‘quvchilar savollari va izohlari',
                  subtitle: unansweredCount > 0
                      ? '$unansweredCount ta javobsiz savol kutmoqda'
                      : 'Barcha savollarga javob berilgan',
                  child: Column(
                    children: [
                      for (final comment in effectiveComments)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: IlmColors.paper,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: IlmColors.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      comment.studentName,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: IlmColors.ink,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    comment.createdAtLabel,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: IlmColors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                comment.topicTitle,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: IlmColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                comment.text,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: IlmColors.ink,
                                ),
                              ),
                              if (comment.isAnswered) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Sizning javobingiz: ${comment.teacherReply}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: IlmColors.accent,
                                  ),
                                ),
                              ],
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  key: ValueKey('reply-${comment.id}'),
                                  onPressed: () =>
                                      _openReplySheet(context, comment),
                                  icon: const Icon(
                                    Icons.reply_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    comment.isAnswered
                                        ? 'Javobni tahrirlash'
                                        : 'Javob yozish',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _ReportCard(
                  title: 'Qulflanib qolgan o‘quvchilar',
                  subtitle: 'Testdan o‘tolmay keyingi mavzuga o‘ta olmayotganlar',
                  child: Column(
                    children: [
                      for (final student in _lockedStudents)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 17,
                                backgroundColor:
                                    const Color(0xFFB45309).withValues(alpha: 0.12),
                                child: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 17,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.$1,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: IlmColors.ink,
                                      ),
                                    ),
                                    Text(
                                      student.$2,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: IlmColors.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${student.$1} ga yordam eslatmasi yuborildi',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: const Text('Eslatish'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _ReportCard(
                  title: '«Tushunmadim» signallari',
                  subtitle:
                      'O‘quvchilar darslik ichida qayta tushuntirish so‘ragan joylar',
                  child: Column(
                    children: [
                      for (final signal in _confusedSignals)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.help_outline_rounded,
                                size: 20,
                                color: Color(0xFFB45309),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  signal.$1,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: IlmColors.ink,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB45309)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${signal.$2} nafar',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _ReportCard(
                  title: 'Eng ko‘p xato qilingan mavzular',
                  child: Column(
                    children: [
                      for (final topic in _hardTopics) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                topic.$1,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: IlmColors.ink,
                                ),
                              ),
                            ),
                            Text(
                              '${(topic.$2 * 100).round()}% xato',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: topic.$2,
                            minHeight: 6,
                            backgroundColor: IlmColors.line,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _ReportCard(
                  title: 'Guruhlar bo‘yicha o‘zlashtirish',
                  child: Column(
                    children: [
                      for (final row in _groupResults) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                row.$1,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: IlmColors.ink,
                                ),
                              ),
                            ),
                            Text(
                              '${(row.$2 * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: IlmColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            row.$3,
                            style: const TextStyle(
                              fontSize: 12,
                              color: IlmColors.inkMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: row.$2,
                            minHeight: 7,
                            backgroundColor: IlmColors.line,
                            color: IlmColors.accent,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => _shareReport(context, subjectTitle),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Haftalik hisobotni Telegram / PDF ulashish'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

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
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: IlmColors.ink,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: IlmColors.inkMuted,
                ),
              ),
            ],
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IlmColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: IlmColors.accent),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: IlmColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: IlmColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
