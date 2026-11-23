import 'dart:ui';

class DemoReel {
  const DemoReel({
    required this.author,
    required this.caption,
    required this.topColor,
    required this.bottomColor,
    this.initialLikes = 12,
    this.initialComments = const [],
  });

  final String author;
  final String caption;
  final Color topColor;
  final Color bottomColor;
  final int initialLikes;
  final List<String> initialComments;
}

const demoReels = <DemoReel>[
  DemoReel(
    author: 'ilm_fan',
    caption: 'Matematika: kvadrat tenglamalar — qisqa eslatma.',
    topColor: Color(0xFF0F6E56),
    bottomColor: Color(0xFF1C1915),
  ),
  DemoReel(
    author: 'ustoz_sarvar',
    caption: 'Fizika formulasini 60 soniyada tushuntirish.',
    topColor: Color(0xFF2B5876),
    bottomColor: Color(0xFF0F6E56),
    initialComments: ['Juda foydali!', 'Rahmat ustoz'],
  ),
  DemoReel(
    author: 'ilm_fan',
    caption: 'Imtihon oldidan test yechish uslubi.',
    topColor: Color(0xFF6B4E71),
    bottomColor: Color(0xFF2B5876),
  ),
];