class PreparationLesson {
  const PreparationLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.explanation,
    required this.exampleTitle,
    required this.example,
  });

  final String id;
  final String title;
  final String subtitle;
  final int minutes;
  final String explanation;
  final String exampleTitle;
  final String example;
}

const preparationLessonsByFanId = <String, List<PreparationLesson>>{
  'matematika': [
    PreparationLesson(
      id: 'math-arithmetic',
      title: 'Arifmetika',
      subtitle: 'Kasrlar, foiz va nisbatlar',
      minutes: 12,
      explanation: 'Foiz sonning yuzdan bir qismini bildiradi. Kasrlarni qo‘shishda avval maxrajlarni tenglashtiring, keyin suratlarni qo‘shing.',
      exampleTitle: 'Namuna',
      example: '80 ning 25 foizi: 80 × 25 ÷ 100 = 20.',
    ),
    PreparationLesson(
      id: 'math-algebra',
      title: 'Algebra',
      subtitle: 'Tenglama va ifodalar',
      minutes: 15,
      explanation: 'Tenglamani yechishda noma’lumli hadlarni bir tomonga, sonlarni ikkinchi tomonga o‘tkazing. Tenglik saqlanishi uchun ikki tomonga ham bir xil amal bajariladi.',
      exampleTitle: 'Namuna',
      example: '3x + 5 = 20. Avval 5 ni ayiramiz: 3x = 15. Demak, x = 5.',
    ),
    PreparationLesson(
      id: 'math-geometry',
      title: 'Geometriya',
      subtitle: 'Burchaklar va shakllar',
      minutes: 14,
      explanation: 'Uchburchak ichki burchaklarining yig‘indisi 180° ga teng. Berilgan burchaklarni ayirib, noma’lum burchakni toping.',
      exampleTitle: 'Namuna',
      example: 'Burchaklar 50° va 60° bo‘lsa, uchinchi burchak 180° − 50° − 60° = 70°.',
    ),
    PreparationLesson(
      id: 'math-functions',
      title: 'Funksiyalar',
      subtitle: 'Qiymatlar va grafiklar',
      minutes: 13,
      explanation: 'Funksiya x ning har bir qiymatiga y ning qiymatini mos qo‘yadi. y = 2x + 1 formulada x ma’lum bo‘lsa, o‘rniga qo‘yib y ni hisoblaysiz.',
      exampleTitle: 'Namuna',
      example: 'x = 3 bo‘lsa, y = 2 × 3 + 1 = 7.',
    ),
  ],
  'fizika': [
    PreparationLesson(
      id: 'physics-motion',
      title: 'Kinematika',
      subtitle: 'Masofa, vaqt va tezlik',
      minutes: 12,
      explanation: 'Tekis harakatda tezlik masofaning vaqtga nisbatiga teng: v = s ÷ t. Avval kattaliklarning o‘lchov birliklarini moslang.',
      exampleTitle: 'Namuna',
      example:
          '120 km masofani 2 soatda bosib o‘tsa, tezlik 120 ÷ 2 = 60 km/soat.',
    ),
    PreparationLesson(
      id: 'physics-dynamics',
      title: 'Dinamika',
      subtitle: 'Nyuton qonunlari va kuch',
      minutes: 15,
      explanation: 'Nyutonning ikkinchi qonuni kuch, massa va tezlanishni bog‘laydi: F = m × a. Hisoblashdan oldin birliklarni tekshiring.',
      exampleTitle: 'Namuna',
      example: 'm = 2 kg, a = 4 m/s² bo‘lsa, F = 2 × 4 = 8 N.',
    ),
    PreparationLesson(
      id: 'physics-electricity',
      title: 'Elektr toki',
      subtitle: 'Tok kuchi, kuchlanish va qarshilik',
      minutes: 14,
      explanation: 'Om qonuniga ko‘ra kuchlanish tok kuchi bilan qarshilik ko‘paytmasiga teng: U = I × R.',
      exampleTitle: 'Namuna',
      example: 'I = 2 A va R = 3 Ω bo‘lsa, U = 2 × 3 = 6 V.',
    ),
    PreparationLesson(
      id: 'physics-energy',
      title: 'Energiya',
      subtitle: 'Ish va potensial energiya',
      minutes: 13,
      explanation: 'Yer sirtidan balandlikda turgan jismning potensial energiyasi E = m × g × h formula bilan topiladi.',
      exampleTitle: 'Namuna',
      example: 'm = 2 kg, g = 10 m/s², h = 5 m bo‘lsa, E = 100 J.',
    ),
  ],
};
