class SampleCourseLesson {
  const SampleCourseLesson({
    required this.id,
    required this.title,
    required this.minutes,
    required this.summary,
    required this.example,
    this.isPreview = false,
  });

  final String id;
  final String title;
  final int minutes;
  final String summary;
  final String example;
  final bool isPreview;
}

class SampleCourseModule {
  const SampleCourseModule({required this.title, required this.lessons});

  final String title;
  final List<SampleCourseLesson> lessons;
}

class SampleCourse {
  const SampleCourse({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.instructor,
    required this.level,
    required this.category,
    required this.outcomes,
    required this.modules,
  });

  final String id;
  final String subjectId;
  final String title;
  final String subtitle;
  final String description;
  final String instructor;
  final String level;
  final String category;
  final List<String> outcomes;
  final List<SampleCourseModule> modules;

  List<SampleCourseLesson> get lessons => [
    for (final module in modules) ...module.lessons,
  ];

  int get totalMinutes =>
      lessons.fold(0, (total, lesson) => total + lesson.minutes);

  int get lessonCount => lessons.length;

  SampleCourseLesson? get previewLesson {
    for (final lesson in lessons) {
      if (lesson.isPreview) return lesson;
    }
    return lessons.isEmpty ? null : lessons.first;
  }
}

const sampleCourses = <SampleCourse>[
  SampleCourse(
    id: 'math-attestation-demo',
    subjectId: 'matematika',
    title: 'Matematika attestatsiyasiga tayyorlov',
    subtitle: 'Asosiy mavzularni tartibli takrorlang',
    description: 'Attestatsiyaga tayyorgarlik uchun matematikaning muhim mavzularini qisqa darslar, ishlangan misollar va mustahkamlash mashqlari bilan takrorlang.',
    instructor: 'Namuna o‘qituvchi',
    level: 'O‘rta daraja',
    category: 'Attestatsiya',
    outcomes: [
      'Arifmetik amallar va kasrlarni ishonchli yechish',
      'Tenglamalarni bosqichma-bosqich yechish',
      'Geometriya masalalarida kerakli formulani tanlash',
    ],
    modules: [
      SampleCourseModule(
        title: 'Arifmetika',
        lessons: [
          SampleCourseLesson(
            id: 'math-att-intro',
            title: 'Kurs bilan tanishuv',
            minutes: 3,
            summary: 'Kursda nimalar o‘rganilishi va mavzularni qanday ketma-ketlikda takrorlash bilan tanishing.',
            example:
                'Har dars: tushuncha → ishlangan misol → mustahkamlash testi.',
            isPreview: true,
          ),
          SampleCourseLesson(
            id: 'math-att-fractions',
            title: 'Kasrlar va foizlar',
            minutes: 9,
            summary: 'Kasrlarni taqqoslash, qo‘shish va foizga oid masalalarni yechish usullari.',
            example: '80 ning 25 foizi: 80 × 25 ÷ 100 = 20.',
          ),
          SampleCourseLesson(
            id: 'math-att-ratio',
            title: 'Nisbat va proporsiya',
            minutes: 8,
            summary: 'Nisbatni soddalashtirish va proporsiyada noma’lum hadni topish.',
            example: '3 : 5 = x : 20 bo‘lsa, x = 12.',
          ),
        ],
      ),
      SampleCourseModule(
        title: 'Algebra',
        lessons: [
          SampleCourseLesson(
            id: 'math-att-equations',
            title: 'Chiziqli tenglamalar',
            minutes: 10,
            summary: 'Tenglamadagi noma’lumli hadlarni ajratib, tenglikning ikki tomonida bir xil amal bajaring.',
            example: '3x + 5 = 20 → 3x = 15 → x = 5.',
          ),
          SampleCourseLesson(
            id: 'math-att-quadratic',
            title: 'Kvadrat tenglamalar',
            minutes: 12,
            summary: 'Ko‘paytuvchilarga ajratish va diskriminant orqali ildizlarni aniqlash.',
            example: 'x² − 5x + 6 = 0 → (x − 2)(x − 3) = 0.',
          ),
        ],
      ),
      SampleCourseModule(
        title: 'Geometriya',
        lessons: [
          SampleCourseLesson(
            id: 'math-att-triangles',
            title: 'Uchburchaklar',
            minutes: 10,
            summary: 'Uchburchak burchaklari yig‘indisi, perimetr va yuzaga oid masalalar.',
            example: '50° va 60° berilsa, uchinchi burchak 70° bo‘ladi.',
          ),
          SampleCourseLesson(
            id: 'math-att-pythagoras',
            title: 'Pifagor teoremasi',
            minutes: 9,
            summary: 'To‘g‘ri burchakli uchburchakda katetlar orqali gipotenuzani topish.',
            example: 'Katetlar 5 va 12 bo‘lsa, gipotenuza √(25 + 144) = 13.',
          ),
        ],
      ),
    ],
  ),
  SampleCourse(
    id: 'math-algebra-demo',
    subjectId: 'matematika',
    title: 'Algebra: masalalarni yechish usullari',
    subtitle: 'Tenglamalar va funksiyalar bo‘yicha mini-kurs',
    description: 'Algebradagi asosiy qoidalarni misollarda ko‘rib chiqing va har bir mavzudan keyin qisqa mashq bajaring.',
    instructor: 'Namuna o‘qituvchi',
    level: 'Boshlang‘ich',
    category: 'Mavzu kursi',
    outcomes: [
      'Chiziqli tenglamalarni yechish',
      'Kvadrat tenglamaning ildizlarini topish',
      'Funksiya qiymatini hisoblash',
    ],
    modules: [
      SampleCourseModule(
        title: 'Tenglamalar',
        lessons: [
          SampleCourseLesson(
            id: 'math-alg-intro',
            title: 'Algebra kursiga kirish',
            minutes: 3,
            summary: 'Kurs mavzulari va mashq qilish tartibi bilan tanishing.',
            example:
                'Avval qoidani ko‘rib, so‘ng yechilgan misolni tahlil qilamiz.',
            isPreview: true,
          ),
          SampleCourseLesson(
            id: 'math-alg-linear',
            title: 'Chiziqli tenglamalar',
            minutes: 8,
            summary: 'Noma’lumni tenglamaning bir tomonida ajratish.',
            example: '2x − 4 = 10 → 2x = 14 → x = 7.',
          ),
        ],
      ),
      SampleCourseModule(
        title: 'Funksiyalar',
        lessons: [
          SampleCourseLesson(
            id: 'math-alg-functions',
            title: 'Funksiya qiymati',
            minutes: 9,
            summary: 'Berilgan x qiymatini formulaga qo‘yib y ni hisoblash.',
            example: 'y = 2x + 1 va x = 3 bo‘lsa, y = 7.',
          ),
        ],
      ),
    ],
  ),
  SampleCourse(
    id: 'physics-attestation-demo',
    subjectId: 'fizika',
    title: 'Fizika attestatsiyasiga tayyorlov',
    subtitle: 'Mexanika, elektr va energiya',
    description: 'Fizikaning asosiy bo‘limlarini formulalar, sodda izohlar va namunaviy masalalar bilan takrorlang.',
    instructor: 'Namuna o‘qituvchi',
    level: 'O‘rta daraja',
    category: 'Attestatsiya',
    outcomes: [
      'Kinematika masalalarida kattaliklarni ajratish',
      'Nyuton qonunlarini qo‘llash',
      'Elektr zanjirlarida Om qonunidan foydalanish',
    ],
    modules: [
      SampleCourseModule(
        title: 'Mexanika',
        lessons: [
          SampleCourseLesson(
            id: 'physics-att-intro',
            title: 'Kurs bilan tanishuv',
            minutes: 3,
            summary: 'Fizika kursining mavzulari va mashq qilish yo‘li.',
            example: 'Masalani yechishda avval berilgan kattaliklar va birliklarni yozing.',
            isPreview: true,
          ),
          SampleCourseLesson(
            id: 'physics-att-motion',
            title: 'Masofa, vaqt va tezlik',
            minutes: 9,
            summary: 'Tezlikni masofa va vaqt orqali hisoblash.',
            example: '120 km ÷ 2 soat = 60 km/soat.',
          ),
          SampleCourseLesson(
            id: 'physics-att-force',
            title: 'Kuch va tezlanish',
            minutes: 10,
            summary: 'Nyutonning ikkinchi qonuni: F = m × a.',
            example: '2 kg × 4 m/s² = 8 N.',
          ),
        ],
      ),
      SampleCourseModule(
        title: 'Elektr va energiya',
        lessons: [
          SampleCourseLesson(
            id: 'physics-att-ohm',
            title: 'Om qonuni',
            minutes: 9,
            summary: 'Kuchlanish, tok kuchi va qarshilik orasidagi bog‘lanish.',
            example: 'U = I × R; 2 A × 3 Ω = 6 V.',
          ),
          SampleCourseLesson(
            id: 'physics-att-energy',
            title: 'Potensial energiya',
            minutes: 9,
            summary: 'E = m × g × h formulasidan foydalanish.',
            example: '2 kg × 10 m/s² × 5 m = 100 J.',
          ),
        ],
      ),
    ],
  ),
];
